---
name: java-resilience
description: Use when the user asks to add resilience patterns, handle service failures, implement circuit breaker, retry, rate limiter, bulkhead, or timeout in a Spring Boot project using Resilience4J.
version: 1.0.0
authors: [java-plugins contributors]
tags: [java, spring-boot, resilience4j, circuit-breaker, retry, rate-limiter, bulkhead, timeout]
allowed-tools: [Read, Glob, Grep, Edit, Write]
---

# Resilience4J Skill

Detect the existing setup, then apply the correct pattern.

## Step 1 — Detect setup

Check `pom.xml` or `build.gradle`:
- `resilience4j-spring-boot3` → Spring Boot 3.x (use `io.github.resilience4j:resilience4j-spring-boot3`)
- `resilience4j-spring-boot2` → Spring Boot 2.x
- `spring-cloud-starter-circuitbreaker-resilience4j` → Spring Cloud Circuit Breaker abstraction
- None present → offer to add (recommend `resilience4j-spring-boot3` for Boot 3.x)

Check Java version: Java 17+ enables records for fallback DTOs; Java 8+ supported throughout.

---

## Mode: `review`

User asks to review existing Resilience4J config. Check for:

- [ ] Circuit breaker thresholds are tuned — `slidingWindowSize`, `failureRateThreshold`, `waitDurationInOpenState` set explicitly (not defaults)
- [ ] `slowCallDurationThreshold` and `slowCallRateThreshold` configured — slow calls should also trip the breaker
- [ ] Fallback methods match the same signature as the guarded method (same return type + `Throwable` param)
- [ ] `@CircuitBreaker` and `@Retry` not stacked without `fallbackMethod` on the outer annotation — will swallow exceptions silently
- [ ] Retry has `ignoreExceptions` for business errors (e.g. `IllegalArgumentException`, `EntityNotFoundException`) — don't retry 4xx errors
- [ ] `RateLimiter` uses `limitForPeriod` appropriate for downstream SLA — not an arbitrary number
- [ ] Bulkhead `maxConcurrentCalls` sized against thread pool or reactive scheduler
- [ ] Actuator endpoints exposed: `management.endpoints.web.exposure.include=health,circuitbreakers,retries,ratelimiters`
- [ ] Circuit breaker state changes logged via `CircuitBreakerEvent` listener — not silent
- [ ] No `@Retry` on `@Transactional` methods — retries after a rolled-back transaction reopen a new transaction

---

## Mode: `circuit-breaker`

User asks to add a circuit breaker to protect a downstream call.

1. Add dependency (see `references/patterns.md` → Setup)
2. Configure in `application.yml` — set `sliding-window-size`, `failure-rate-threshold`, `wait-duration-in-open-state`
3. Annotate the method with `@CircuitBreaker(name = "serviceName", fallbackMethod = "fallback")`
4. Write the fallback method — same return type, extra `Throwable` parameter
5. Expose circuit breaker health: `management.health.circuitbreakers.enabled=true`
6. Add event listener to log state transitions (CLOSED→OPEN→HALF_OPEN)

Version note:
- Spring Boot 3.x → `resilience4j-spring-boot3`
- Spring Boot 2.x → `resilience4j-spring-boot2`

---

## Mode: `retry`

User asks to add automatic retry for flaky remote calls.

1. Configure retry in `application.yml` — `max-attempts`, `wait-duration`, `exponential-backoff-multiplier`
2. Set `ignore-exceptions` for non-retryable errors (validation errors, 4xx responses)
3. Set `retry-exceptions` explicitly (e.g. `IOException`, `TimeoutException`)
4. Annotate with `@Retry(name = "serviceName", fallbackMethod = "fallback")`
5. For HTTP clients: check response status before retrying — use `retryOnResultPredicate` to retry on 5xx, not 4xx
6. Warn if stacking with `@CircuitBreaker` — retry fires first, circuit breaker wraps it; set `retry.max-attempts` lower than circuit breaker `sliding-window-size`

---

## Mode: `rate-limiter`

User asks to limit how often a method can be called (outgoing rate limiting or incoming API protection).

1. Configure `limit-for-period` (requests per window), `limit-refresh-period`, `timeout-duration`
2. Annotate with `@RateLimiter(name = "serviceName", fallbackMethod = "fallback")`
3. For incoming API protection: place on controller method or use a filter
4. For outgoing: place on the service/client method calling the downstream

---

## Mode: `bulkhead`

User asks to limit concurrent calls to isolate failures (prevent thread starvation).

Two types — choose based on context:
- **Semaphore bulkhead** (default): limits concurrent calls via a counter — lightweight, same thread pool
- **ThreadPool bulkhead**: executes in a dedicated pool — true isolation, for blocking I/O

Configure `max-concurrent-calls` and `max-wait-duration` (semaphore) or pool size (thread pool).
Annotate with `@Bulkhead(name = "serviceName", type = Bulkhead.Type.SEMAPHORE)`.

---

## Mode: `timeout`

User asks to add a timeout to a method.

1. Use `@TimeLimiter` for reactive/async methods (returns `CompletableFuture` or `Flux`/`Mono`)
2. For blocking methods: use `@CircuitBreaker` with `slowCallDurationThreshold` instead
3. Configure `timeout-duration` in `application.yml`
4. `@TimeLimiter` requires the method to return `CompletableFuture<T>` — wrap synchronous calls if needed

---

## Output format

For **review mode**: list findings as `[CRITICAL] / [HIGH] / [MEDIUM] / [LOW]` with file:line references.

For **implementation modes**: show exact Maven/Gradle snippet, full `application.yml` config block, and complete annotated Java example. State minimum Spring Boot version where relevant.
