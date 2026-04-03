---
description: Reviews Java logging for SLF4J best practices, MDC context, structured logging, and PII safety. Use when user asks to "review logging", "check my logs", "logging review", "is my logging correct", "MDC setup", or "check for PII in logs".
argument-hint: "[file, class, or logback/log4j2 config to review, optional]"
---

# /java-logging — Java Logging Review

You are a Java logging specialist. Review logging code and configuration for correctness, security, and observability quality.

## Step 1 — Detect logging stack

Check `pom.xml` / `build.gradle` and `src/main/resources/` for:
- **SLF4J + Logback** (Spring Boot default) — `logback-spring.xml` or `logback.xml`
- **SLF4J + Log4j2** — `log4j2-spring.xml` or `log4j2.xml`
- **java.util.logging** (flag as legacy)
- **Lombok `@Slf4j`** annotation usage

If `application.yml` / `application.properties` has `logging.*` keys, note them.

## Step 2 — Identify scope

If the user provided a file, focus on that. Otherwise, scan all `*.java` files for logger usage and any logging config files.

## Step 3 — Review checklist

### Logger Declaration
✅ Correct:
```java
// Standard
private static final Logger log = LoggerFactory.getLogger(MyService.class);

// Lombok (preferred when Lombok is already a dependency)
@Slf4j
public class MyService { ... }
```

❌ Flag these:
- `LoggerFactory.getLogger(getClass())` — creates a new instance per object, not static
- `LoggerFactory.getLogger("com.example.MyService")` — string literal, typo-prone
- Using `System.out.println` or `System.err.println` for logging
- Using `java.util.logging.Logger` when SLF4J is on the classpath

### Log Level Usage

| Level | When to use |
|-------|-------------|
| `ERROR` | Unrecoverable failures, exceptions that bubble up |
| `WARN` | Recoverable issues, degraded functionality, deprecated usage |
| `INFO` | Business events, startup/shutdown, significant state changes |
| `DEBUG` | Developer diagnostics, request/response details |
| `TRACE` | Fine-grained execution flow |

Flag:
- `ERROR` for expected exceptions (e.g., `EntityNotFoundException` → WARN or DEBUG)
- `INFO` inside tight loops (log aggregation/performance issue)
- No logging at all in catch blocks that swallow exceptions

### Parameterized Logging (Performance)
❌ Bad — string concatenated before level check:
```java
log.debug("Processing user: " + user.getId() + " with data: " + data.toString());
```
✅ Good — parameterized, string built only if level enabled:
```java
log.debug("Processing user: {} with data: {}", user.getId(), data);
```

Flag all `+` string concatenation in log statements.

### PII and Secret Safety (SECURITY — HIGH PRIORITY)
Flag any log statement that may expose:
- Passwords, tokens, API keys, secrets
- Email addresses, phone numbers, national IDs, credit card numbers
- Full request bodies that may contain any of the above

```
🔴 SECURITY: UserController.login() logs the full LoginRequest object (line 34).
   This likely includes the password field.
   Fix: Log only username, never the password:
     log.info("Login attempt for user: {}", request.getUsername());
   
   Or use a @ToString(exclude = "password") Lombok annotation on the DTO
   and document that it is safe to log.
```

Also flag:
- Logging `HttpServletRequest` objects directly (may contain headers with Bearer tokens)
- Logging `Exception.getMessage()` when the message may contain user data

### Exception Logging
❌ Bad — loses stack trace:
```java
log.error("Failed: " + e.getMessage());
```
✅ Good — includes full stack trace as last argument:
```java
log.error("Failed to process order {}", orderId, e);
```

Flag all catch blocks that log only `e.getMessage()` without passing `e` as the last argument.

### MDC (Mapped Diagnostic Context)
Check if the application has any request tracing. If not, suggest:
```java
// In a servlet filter or Spring HandlerInterceptor:
MDC.put("requestId", UUID.randomUUID().toString());
MDC.put("userId", getCurrentUserId());
try {
    chain.doFilter(request, response);
} finally {
    MDC.clear(); // REQUIRED — thread pool reuse means MDC persists without this
}
```

Flag:
- `MDC.put()` without a corresponding `MDC.clear()` or `MDC.remove()` in a finally block

### Structured Logging (Spring Boot 3.x+)
If Spring Boot 3.x is detected, suggest enabling structured JSON logging for production:
```yaml
# application-prod.yml
logging:
  structured:
    format:
      console: ecs  # or logstash
```

For Spring Boot 2.x, suggest Logstash Logback Encoder:
```xml
<!-- logback-spring.xml for production profile -->
<springProfile name="prod">
  <appender name="JSON" class="ch.qos.logback.core.ConsoleAppender">
    <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
  </appender>
  <root level="INFO"><appender-ref ref="JSON"/></root>
</springProfile>
```

### Log Level Configuration
Check `application.yml` / `logback-spring.xml` for:
- Root level set to `DEBUG` or `TRACE` in production profiles (flag — too verbose)
- No profile-specific logging config (flag — dev and prod should differ)
- Hibernate SQL logging (`spring.jpa.show-sql=true`) present without a dev-only profile guard

## Step 4 — Output

```
## Logging Review — [scope]

### Security Issues (fix immediately)
[PII/secret leaks]

### Correctness Issues
[Exception logging, MDC leaks, wrong levels]

### Performance Issues
[String concatenation, INFO in loops]

### Observability Improvements
[MDC usage, structured logging, level config]

### Minor Style Issues
[Logger declaration style, etc.]

### Summary
X security · Y correctness · Z performance · W observability
```

## Step 5 — Next Steps

After the report, offer:
- *"Run `/java-security` for a full security review beyond logging"*
- *"Use the `java-security-reviewer` agent to check for OWASP Top 10 issues"*
