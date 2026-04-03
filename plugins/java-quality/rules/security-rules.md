---
globs: ["**/*.java"]
---

# Java Security Rules

Apply these rules when editing or reviewing any `.java` file.

## Never Log Sensitive Data
Do not log: passwords, API keys, tokens, session IDs, credit card numbers, SSNs, emails in error messages.
```java
// Bad
log.info("Login attempt for user: {} with password: {}", username, password);

// Good
log.info("Login attempt for user: {}", username);
```

## SQL Injection Prevention
- Never concatenate user input into SQL strings
- Always use Spring Data repository methods, JPQL with named parameters (`@Query`), or `JdbcTemplate` with `?` placeholders
```java
// Bad
String query = "SELECT * FROM users WHERE email = '" + email + "'";

// Good
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);
```

## Input Validation at Boundaries
- Every `@RequestBody`, `@RequestParam`, and `@PathVariable` must be validated
- Use Bean Validation: `@NotNull`, `@NotBlank`, `@Size`, `@Email`, `@Pattern`
- Validate the `@RequestBody` object with `@Valid` in the controller

## Secrets in Code
- Flag any hardcoded credentials, tokens, or keys in source files
- All secrets must come from environment variables, `application.yml` with `${ENV_VAR}` notation, or a secrets manager

## Cryptography
- Never use MD5, SHA-1, or `DESede` for password hashing or data integrity
- Passwords: `BCryptPasswordEncoder` (strength 12+) or `Argon2PasswordEncoder`
- Tokens: use `java.security.SecureRandom`, not `java.util.Random`

## CORS
- Flag `@CrossOrigin(origins = "*")` in any non-local-dev context
- Restrict origins to known domains in production Spring Security config
