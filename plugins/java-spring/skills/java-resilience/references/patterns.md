# Resilience4J — Reference Patterns

## Setup

### Maven (Spring Boot 3.x)
```xml
<dependency>
  <groupId>io.github.resilience4j</groupId>
  <artifactId>resilience4j-spring-boot3</artifactId>
  <version>2.2.0</version>
</dependency>
<!-- Required for @CircuitBreaker/@Retry annotations -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
<!-- Optional: actuator for /actuator/circuitbreakers -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

### Maven (Spring Boot 2.x)
```xml
<dependency>
  <groupId>io.github.resilience4j</groupId>
  <artifactId>resilience4j-spring-boot2</artifactId>
  <version>1.7.1</version>
</dependency>
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

---

## Circuit Breaker

### application.yml
```yaml
resilience4j:
  circuitbreaker:
    instances:
      paymentService:
        sliding-window-type: COUNT_BASED
        sliding-window-size: 10
        failure-rate-threshold: 50          # trip at 50% failures
        slow-call-duration-threshold: 2s
        slow-call-rate-threshold: 80        # trip if 80% calls are slow
        wait-duration-in-open-state: 30s
        permitted-number-of-calls-in-half-open-state: 3
        automatic-transition-from-open-to-half-open-enabled: true
        record-exceptions:
          - java.io.IOException
          - java.util.concurrent.TimeoutException
          - feign.FeignException.ServiceUnavailable
        ignore-exceptions:
          - com.example.exception.BusinessException

management:
  health:
    circuitbreakers:
      enabled: true
  endpoints:
    web:
      exposure:
        include: health,circuitbreakers,retries,ratelimiters
```

### Service
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {

    private final PaymentClient paymentClient;

    @CircuitBreaker(name = "paymentService", fallbackMethod = "processPaymentFallback")
    public PaymentResponse processPayment(PaymentRequest request) {
        return paymentClient.process(request);
    }

    // Fallback — same return type, extra Throwable param
    private PaymentResponse processPaymentFallback(PaymentRequest request, Throwable ex) {
        log.warn("Payment service unavailable, using fallback. Cause: {}", ex.getMessage());
        return PaymentResponse.queued(request.getOrderId());
    }
}
```

### Event listener (log state transitions)
```java
@Component
@RequiredArgsConstructor
@Slf4j
public class CircuitBreakerEventListener {

    @EventListener
    public void onStateTransition(CircuitBreakerOnStateTransitionEvent event) {
        log.warn("CircuitBreaker '{}' state: {} → {}",
            event.getCircuitBreakerName(),
            event.getStateTransition().getFromState(),
            event.getStateTransition().getToState());
    }
}
```

---

## Retry

### application.yml
```yaml
resilience4j:
  retry:
    instances:
      inventoryService:
        max-attempts: 3
        wait-duration: 500ms
        enable-exponential-backoff: true
        exponential-backoff-multiplier: 2   # 500ms, 1s, 2s
        retry-exceptions:
          - java.io.IOException
          - java.util.concurrent.TimeoutException
        ignore-exceptions:
          - com.example.exception.ResourceNotFoundException
          - com.example.exception.ValidationException
```

### Service
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class InventoryService {

    private final InventoryClient inventoryClient;

    @Retry(name = "inventoryService", fallbackMethod = "checkStockFallback")
    @CircuitBreaker(name = "inventoryService", fallbackMethod = "checkStockFallback")
    public StockResponse checkStock(String sku) {
        return inventoryClient.getStock(sku);
    }

    private StockResponse checkStockFallback(String sku, Throwable ex) {
        log.error("Inventory check failed for SKU: {} after retries. Cause: {}", sku, ex.getMessage());
        return StockResponse.unknown(sku);
    }
}
```

### Retry on HTTP response status (RestClient / WebClient)
```java
resilience4j:
  retry:
    instances:
      externalApi:
        result-predicate: com.example.resilience.ServerErrorPredicate

// Predicate class
public class ServerErrorPredicate implements Predicate<HttpResponse> {
    @Override
    public boolean test(HttpResponse response) {
        return response.getStatusCode().is5xxServerError();
    }
}
```

---

## Rate Limiter

### application.yml
```yaml
resilience4j:
  ratelimiter:
    instances:
      smsService:
        limit-for-period: 10          # 10 requests
        limit-refresh-period: 1s      # per second
        timeout-duration: 500ms       # wait up to 500ms for a permit
```

### Service
```java
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final SmsClient smsClient;

    @RateLimiter(name = "smsService", fallbackMethod = "sendSmsFallback")
    public void sendSms(String phone, String message) {
        smsClient.send(phone, message);
    }

    private void sendSmsFallback(String phone, String message, RequestNotPermitted ex) {
        log.warn("SMS rate limit exceeded for phone: {}", phone);
        // Queue for later or drop
    }
}
```

---

## Bulkhead (Semaphore)

### application.yml
```yaml
resilience4j:
  bulkhead:
    instances:
      reportService:
        max-concurrent-calls: 5     # max 5 concurrent calls
        max-wait-duration: 100ms    # wait 100ms for a slot, then fail
```

### Service
```java
@Service
@RequiredArgsConstructor
public class ReportService {

    @Bulkhead(name = "reportService", fallbackMethod = "generateReportFallback")
    public ReportResponse generateReport(ReportRequest request) {
        // heavy operation
        return reportEngine.generate(request);
    }

    private ReportResponse generateReportFallback(ReportRequest request, BulkheadFullException ex) {
        throw new ServiceBusyException("Report service at capacity, try again later");
    }
}
```

---

## TimeLimiter (Async Timeout)

### application.yml
```yaml
resilience4j:
  timelimiter:
    instances:
      asyncService:
        timeout-duration: 3s
        cancel-running-future: true
```

### Service
```java
@Service
@RequiredArgsConstructor
public class AsyncProcessingService {

    private final HeavyProcessor processor;

    @TimeLimiter(name = "asyncService", fallbackMethod = "processFallback")
    @CircuitBreaker(name = "asyncService")
    public CompletableFuture<ProcessResult> process(ProcessRequest request) {
        return CompletableFuture.supplyAsync(() -> processor.run(request));
    }

    private CompletableFuture<ProcessResult> processFallback(
            ProcessRequest request, TimeoutException ex) {
        return CompletableFuture.completedFuture(ProcessResult.timeout());
    }
}
```

---

## Combining Patterns (recommended order)

When stacking multiple annotations, the execution order is:
`TimeLimiter → CircuitBreaker → Bulkhead → RateLimiter → Retry`

```java
@RateLimiter(name = "externalApi")
@Bulkhead(name = "externalApi")
@CircuitBreaker(name = "externalApi", fallbackMethod = "fallback")
@Retry(name = "externalApi")
public ApiResponse callExternalApi(ApiRequest request) {
    return externalClient.call(request);
}
```

Control order explicitly in `application.yml`:
```yaml
resilience4j:
  annotation-aware-order:
    - RateLimiter
    - Bulkhead
    - CircuitBreaker
    - TimeLimiter
    - Retry
```

---

## Actuator Endpoints

```
GET /actuator/health                    # includes circuit breaker states
GET /actuator/circuitbreakers           # all circuit breakers + metrics
GET /actuator/circuitbreakerevents      # recent events (state changes, calls)
GET /actuator/retries                   # retry stats
GET /actuator/ratelimiters              # rate limiter stats
```
