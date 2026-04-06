# Event-Driven — Reference Patterns

## Spring Application Events

### Event class (Boot 3.x — plain record)
```java
public record OrderPlacedEvent(Long orderId, String customerId, BigDecimal total) {}
```

### Event class (Boot 2.x — extend ApplicationEvent)
```java
public class OrderPlacedEvent extends ApplicationEvent {
    private final Long orderId;
    private final String customerId;

    public OrderPlacedEvent(Object source, Long orderId, String customerId) {
        super(source);
        this.orderId = orderId;
        this.customerId = customerId;
    }
}
```

### Publisher
```java
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository repository;
    private final ApplicationEventPublisher eventPublisher;

    @Transactional
    public Order placeOrder(OrderRequest request) {
        Order order = repository.save(Order.from(request));
        // Publish AFTER saving — but still inside transaction
        eventPublisher.publishEvent(new OrderPlacedEvent(order.getId(), request.getCustomerId(), order.getTotal()));
        return order;
    }
}
```

### Synchronous listener
```java
@Component
@Slf4j
public class OrderEventListener {

    @EventListener
    public void onOrderPlaced(OrderPlacedEvent event) {
        log.info("Order placed: {}", event.orderId());
        // runs in same thread, same transaction as publisher
    }
}
```

### Async listener (non-blocking I/O)
```java
@Configuration
@EnableAsync
public class AsyncConfig {}

@Component
@Slf4j
public class NotificationListener {

    @Async
    @EventListener
    public void sendConfirmationEmail(OrderPlacedEvent event) {
        // runs in separate thread — publisher doesn't wait
        emailService.sendOrderConfirmation(event.customerId(), event.orderId());
    }
}
```

### Post-commit listener (fires AFTER transaction commits)
```java
@Component
@Slf4j
public class AuditListener {

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void auditOrderPlaced(OrderPlacedEvent event) {
        // Safe — only fires if transaction committed successfully
        auditLog.record("ORDER_PLACED", event.orderId());
    }
}
```

---

## Domain Events via AbstractAggregateRoot

```java
@Entity
public class Order extends AbstractAggregateRoot<Order> {

    @Id @GeneratedValue
    private Long id;
    private OrderStatus status;

    public Order confirm() {
        this.status = OrderStatus.CONFIRMED;
        registerEvent(new OrderConfirmedEvent(this.id));  // queued, not published yet
        return this;
    }
}

// In service — events published automatically after save()
@Transactional
public Order confirmOrder(Long orderId) {
    Order order = repository.findById(orderId).orElseThrow();
    order.confirm();
    return repository.save(order);  // ← events published here by Spring Data
}
```

---

## Kafka

### Maven
```xml
<dependency>
  <groupId>org.springframework.kafka</groupId>
  <artifactId>spring-kafka</artifactId>
</dependency>
```

### application.yml
```yaml
spring:
  kafka:
    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS:localhost:9092}
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
      acks: all
      properties:
        enable.idempotence: true
        max.in.flight.requests.per.connection: 5
    consumer:
      group-id: order-service
      auto-offset-reset: earliest
      enable-auto-commit: false
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer
      properties:
        spring.json.trusted.packages: "com.example.events"
    listener:
      ack-mode: MANUAL_IMMEDIATE
```

### Producer
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class OrderEventProducer {

    private final KafkaTemplate<String, OrderPlacedEvent> kafkaTemplate;

    public void publishOrderPlaced(OrderPlacedEvent event) {
        kafkaTemplate.send("orders.placed", event.orderId().toString(), event)
            .whenComplete((result, ex) -> {
                if (ex != null) {
                    log.error("Failed to publish OrderPlacedEvent for order {}", event.orderId(), ex);
                } else {
                    log.debug("Published OrderPlacedEvent: partition={}, offset={}",
                        result.getRecordMetadata().partition(),
                        result.getRecordMetadata().offset());
                }
            });
    }
}
```

### Consumer with manual ack + DLT
```java
@Component
@Slf4j
public class OrderEventConsumer {

    @KafkaListener(topics = "orders.placed", groupId = "notification-service")
    public void handleOrderPlaced(
            @Payload OrderPlacedEvent event,
            @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
            @Header(KafkaHeaders.OFFSET) long offset,
            Acknowledgment ack) {

        try {
            notificationService.sendConfirmation(event);
            ack.acknowledge();
        } catch (Exception ex) {
            log.error("Failed to process order event offset={}", offset, ex);
            // Don't ack — will be retried or sent to DLT by error handler
            throw ex;
        }
    }
}
```

### Error handler with Dead Letter Topic
```java
@Configuration
public class KafkaErrorHandlerConfig {

    @Bean
    public DefaultErrorHandler errorHandler(KafkaTemplate<Object, Object> template) {
        // Retry 3 times with 1s backoff, then send to <topic>.DLT
        DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template);
        ExponentialBackOffWithMaxRetries backOff = new ExponentialBackOffWithMaxRetries(3);
        backOff.setInitialInterval(1000L);
        backOff.setMultiplier(2.0);
        return new DefaultErrorHandler(recoverer, backOff);
    }
}
```

---

## RabbitMQ

### Maven
```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
```

### application.yml
```yaml
spring:
  rabbitmq:
    host: ${RABBITMQ_HOST:localhost}
    port: 5672
    username: ${RABBITMQ_USER:guest}
    password: ${RABBITMQ_PASSWORD:guest}
    publisher-confirm-type: correlated   # for publisher confirms
    publisher-returns: true
    listener:
      simple:
        prefetch: 10                     # process 10 messages before ack
        acknowledge-mode: manual
```

### Exchange, Queue & DLX config
```java
@Configuration
public class RabbitMQConfig {

    public static final String ORDER_EXCHANGE   = "orders.exchange";
    public static final String ORDER_QUEUE      = "orders.placed";
    public static final String ORDER_ROUTING    = "order.placed";
    public static final String DLX_EXCHANGE     = "orders.dlx";
    public static final String DLQ              = "orders.placed.dlq";

    // Dead letter exchange
    @Bean
    public DirectExchange deadLetterExchange() {
        return new DirectExchange(DLX_EXCHANGE);
    }

    @Bean
    public Queue deadLetterQueue() {
        return QueueBuilder.durable(DLQ).build();
    }

    @Bean
    public Binding dlqBinding() {
        return BindingBuilder.bind(deadLetterQueue()).to(deadLetterExchange()).with(ORDER_ROUTING);
    }

    // Main exchange and queue
    @Bean
    public TopicExchange orderExchange() {
        return new TopicExchange(ORDER_EXCHANGE);
    }

    @Bean
    public Queue orderQueue() {
        return QueueBuilder.durable(ORDER_QUEUE)
            .withArgument("x-dead-letter-exchange", DLX_EXCHANGE)
            .withArgument("x-dead-letter-routing-key", ORDER_ROUTING)
            .withArgument("x-message-ttl", 300_000)   // 5 min TTL
            .build();
    }

    @Bean
    public Binding orderBinding() {
        return BindingBuilder.bind(orderQueue()).to(orderExchange()).with(ORDER_ROUTING);
    }

    // JSON message converter
    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(jsonMessageConverter());
        return template;
    }
}
```

### Publisher
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class OrderEventPublisher {

    private final RabbitTemplate rabbitTemplate;

    public void publishOrderPlaced(OrderPlacedEvent event) {
        rabbitTemplate.convertAndSend(
            RabbitMQConfig.ORDER_EXCHANGE,
            RabbitMQConfig.ORDER_ROUTING,
            event
        );
        log.debug("Published OrderPlacedEvent for order {}", event.orderId());
    }
}
```

### Consumer
```java
@Component
@Slf4j
public class OrderEventConsumer {

    @RabbitListener(queues = RabbitMQConfig.ORDER_QUEUE)
    public void handleOrderPlaced(
            OrderPlacedEvent event,
            Channel channel,
            @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag) throws IOException {

        try {
            notificationService.sendConfirmation(event);
            channel.basicAck(deliveryTag, false);
        } catch (Exception ex) {
            log.error("Failed to process order event, sending to DLQ", ex);
            channel.basicNack(deliveryTag, false, false);  // false = don't requeue → goes to DLX
        }
    }
}
```

---

## Outbox Pattern (guaranteed event delivery)

Prevents lost events when the service crashes after DB write but before publishing:

```java
@Entity
@Table(name = "outbox_events")
public class OutboxEvent {
    @Id @GeneratedValue
    private Long id;
    private String aggregateType;
    private Long aggregateId;
    private String eventType;
    @Column(columnDefinition = "json")
    private String payload;
    private boolean published = false;
    private Instant createdAt = Instant.now();
}

// In service — save event to DB in same transaction as entity change
@Transactional
public Order placeOrder(OrderRequest request) {
    Order order = orderRepository.save(Order.from(request));
    outboxRepository.save(new OutboxEvent("Order", order.getId(), "OrderPlaced",
        objectMapper.writeValueAsString(new OrderPlacedEvent(order.getId(), ...))));
    return order;
}

// Scheduler polls and publishes unpublished events
@Scheduled(fixedDelay = 1000)
@Transactional
public void publishPendingEvents() {
    outboxRepository.findByPublishedFalse().forEach(event -> {
        kafkaTemplate.send(event.getEventType(), event.getPayload());
        event.setPublished(true);
    });
}
```
