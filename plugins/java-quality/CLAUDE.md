---
globs: ["**/*.java", "**/pom.xml", "**/build.gradle", "**/build.gradle.kts"]
---

# Java Quality — Security, Performance, and Testing Standards

These rules apply whenever the java-quality plugin is active and Java/build files are in context.

## Security Defaults

- Never log passwords, API keys, tokens, session IDs, or PII (names, emails, SSNs, credit card numbers)
- Validate all user-supplied input at the controller boundary using Bean Validation (`@NotNull`, `@Size`, `@Pattern`, etc.)
- Use Spring Data JPA repositories or named parameters with `@Query` — never string-concatenated SQL
- Store secrets in environment variables or Spring Vault; never in source code
- Hash passwords with `BCryptPasswordEncoder` or `Argon2PasswordEncoder` — never MD5, SHA-1, or plaintext
- Flag `@CrossOrigin(origins = "*")` in production — restrict to known origins

## Performance Defaults

- Flag `@OneToMany` or `@ManyToMany` without `FetchType.LAZY` — eager on collections causes N+1
- Flag loops that call a repository method per iteration — suggest `@EntityGraph` or `JOIN FETCH`
- Flag `findAll()` without `Pageable` on entities that may have large data sets
- Flag `String` concatenation inside loops — prefer `StringBuilder`
- Flag `synchronized` on entire methods where a smaller critical section suffices
- Flag creating `DateTimeFormatter`, `Pattern`, or `ObjectMapper` inside frequently-called methods — make them `static final`

## Testing Standards

- Test method naming: `methodName_stateUnderTest_expectedBehavior`
- Follow AAA pattern (Arrange, Act, Assert) with comments; one logical assertion concept per test
- Use AssertJ (`assertThat`) over JUnit `assertEquals`
- Prefer Testcontainers over H2 for database integration tests — use `@ServiceConnection` (Spring Boot 3.1+) or `@DynamicPropertySource` (2.x)
- Mock external dependencies (repositories, HTTP clients, message queues); never mock the class under test
- Recommend JaCoCo for real coverage numbers: `mvn test jacoco:report` or `./gradlew test jacocoTestReport`
- Aim for 80%+ line coverage on the service layer; consider PITest for mutation testing
