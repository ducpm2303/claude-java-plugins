---
name: java-event-driven
description: Use when the user asks to implement event-driven architecture, decouple services with events, use Spring Application Events, integrate Kafka or RabbitMQ, publish domain events, or review existing messaging/eventing code in a Spring Boot project.
version: 1.0.0
authors: [java-plugins contributors]
tags: [java, spring-boot, events, kafka, rabbitmq, event-driven, messaging, domain-events]
allowed-tools: [Read, Glob, Grep, Edit, Write]
---

# Event-Driven Skill

Detect the messaging infrastructure in use, then apply the correct pattern.

## Step 1 — Detect setup

Check `pom.xml` or `build.gradle`:
- `spring-kafka` → Apache Kafka
- `spring-boot-starter-amqp` → RabbitMQ (AMQP)
- `spring-cloud-starter-stream-kafka` → Spring Cloud Stream (Kafka binder)
- `spring-cloud-starter-stream-rabbit` → Spring Cloud Stream (RabbitMQ binder)
- None of the above → Spring Application Events (in-process, no broker)

---

## Mode: `review`

User asks to review existing event-driven code. Check for:

**Spring Application Events:**
- [ ] `@EventListener` methods are not `private` — Spring proxies can't intercept private methods
- [ ] `@Async` on event listeners that do I/O or send emails — synchronous listeners block the publisher
- [ ] `@TransactionalEventListener(phase = AFTER_COMMIT)` used for post-commit side effects — not plain `@EventListener` (which fires mid-transaction)
- [ ] Domain events published via `AbstractAggregateRoot.registerEvent()` + `save()` — not manual `ApplicationEventPublisher.publishEvent()` from repositories
- [ ] No business logic in event publishers — events carry data, not decisions

**Kafka:**
- [ ] `@KafkaListener` has explicit `groupId` — missing it uses random ID, losing consumer group semantics
- [ ] Deserialization error handler configured — `DefaultErrorHandler` with `DeadLetterPublishingRecoverer`
- [ ] `acks=all` and `min.insync.replicas≥2` for producers in production
- [ ] `enable.auto.commit=false` — use manual ack (`AckMode.MANUAL_IMMEDIATE`) for at-least-once
- [ ] `@KafkaListener` is idempotent — duplicate messages will be delivered (at-least-once guarantee)
- [ ] Kafka consumer uses `@Payload` + `@Header` instead of raw `ConsumerRecord` where appropriate
- [ ] Topic partition count and replication factor set for production (not defaults of 1/1)

**RabbitMQ:**
- [ ] Queues declared as `durable=true` — survive broker restart
- [ ] Dead-letter exchange (DLX) configured — failed messages don't disappear
- [ ] `@RabbitListener` has a `containerFactory` with error handler
- [ ] `MessageConverter` set to `Jackson2JsonMessageConverter` — not default Java serialization
- [ ] Prefetch count (`prefetch`) tuned — default 250 is too high for slow consumers
- [ ] Publisher confirms enabled for critical messages (`spring.rabbitmq.publisher-confirm-type=correlated`)

---

## Mode: `app-events`

User asks to decouple components using Spring Application Events (in-process, no broker needed).

1. Define event class — a simple POJO or `record` extending nothing (Boot 3.x) or `ApplicationEvent` (Boot 2.x)
2. Inject `ApplicationEventPublisher` into the publisher service
3. Call `publisher.publishEvent(new MyEvent(...))` after the business operation
4. Create listener with `@EventListener` — or `@TransactionalEventListener(phase = AFTER_COMMIT)` for post-commit side effects
5. Add `@Async` + `@EnableAsync` for non-blocking listeners (I/O, emails, notifications)

When to use vs Kafka/RabbitMQ: use app events for in-process decoupling within a single service; use a broker when events must cross service boundaries or survive restarts.

---

## Mode: `domain-events`

User asks to publish domain events from JPA entities (DDD pattern).

1. Entity extends `AbstractAggregateRoot<T>` (Spring Data)
2. Call `registerEvent(new DomainEvent(...))` inside entity business methods
3. Events are automatically published by Spring Data when `repository.save(entity)` is called
4. Listener uses `@TransactionalEventListener(phase = AFTER_COMMIT)` — fires after the transaction commits, not during

This guarantes events are only published when the entity change is persisted — no phantom events on rollback.

---

## Mode: `kafka`

User asks to integrate Apache Kafka.

1. Add `spring-kafka` dependency
2. Configure `bootstrap-servers`, serializers/deserializers in `application.yml`
3. Define `@Bean KafkaTemplate<String, T>` for publishing (or use auto-configured one)
4. Create `@KafkaListener(topics = "...", groupId = "...")` for consuming
5. Configure `DefaultErrorHandler` with `DeadLetterPublishingRecoverer` for failed messages
6. For JSON: use `JsonSerializer` / `JsonDeserializer` with trusted packages set

See `references/patterns.md` for full producer/consumer/DLT examples.

---

## Mode: `rabbitmq`

User asks to integrate RabbitMQ.

1. Add `spring-boot-starter-amqp`
2. Declare exchange, queue, and binding as `@Bean` (or via `@RabbitListener` + `@Queue` annotations)
3. Configure `Jackson2JsonMessageConverter` bean — set on both template and listener container factory
4. Use `RabbitTemplate` to publish; `@RabbitListener` to consume
5. Declare dead-letter exchange + DLQ for failed message handling
6. Enable publisher confirms for critical messages

See `references/patterns.md` for full exchange/queue/DLX setup and listener examples.

---

## Output format

For **review mode**: list findings as `[CRITICAL] / [HIGH] / [MEDIUM] / [LOW]` with file:line references.

For **implementation modes**: show exact Maven/Gradle dependency, full `application.yml`, and complete Java examples. Note version-specific differences (Boot 2.x vs 3.x, Kafka 3.x API changes).
