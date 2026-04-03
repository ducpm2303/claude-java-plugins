---
globs: ["**/*.java", "**/pom.xml", "**/build.gradle", "**/build.gradle.kts"]
---

# Java Security — Security Defaults

These rules apply whenever the java-security plugin is active.

## Logging
- Never log passwords, API keys, tokens, session IDs, or PII (names, emails, SSNs, credit card numbers)
- If sensitive data must be referenced in a log, use a masked form: `user-***` not `user-john@example.com`
- Flag any `log.debug(...)` or `log.info(...)` calls that include request/response bodies without redaction

## Input Validation
- Validate all user-supplied input at the controller boundary using Bean Validation (`@NotNull`, `@Size`, `@Pattern`, etc.)
- Never trust query parameters, path variables, or request bodies without validation
- Reject input that does not match expected patterns before processing

## SQL Safety
- Use Spring Data JPA repositories or named parameters with `@Query` — never string-concatenated SQL
- If using `JdbcTemplate`, always use `?` placeholders or named parameters — never `+` concatenation
- Flag any use of `createNativeQuery(String sql)` where `sql` contains user input

## Secrets Management
- Never commit secrets (passwords, API keys, DB credentials) to source code
- Read secrets from environment variables (`System.getenv()`), Spring `@Value("${...}")` from externally injected properties, or a secrets manager (HashiCorp Vault via Spring Vault)
- Flag any hardcoded string that looks like a secret (long alphanumeric strings, strings containing "password", "secret", "key", "token")

## Password Hashing
- Always hash passwords with `BCryptPasswordEncoder` or `Argon2PasswordEncoder`
- Never use `MD5`, `SHA-1`, or `SHA-256` for password storage — these are not password hashing functions
- Never store passwords in plaintext

## Dependencies
- Flag the use of known vulnerable libraries when spotted in `pom.xml` or `build.gradle`
- Recommend running `mvn dependency-check:check` (OWASP Dependency Check) or `./gradlew dependencyCheckAnalyze`
