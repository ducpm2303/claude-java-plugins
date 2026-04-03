---
globs: ["**/*Test.java", "**/*Tests.java", "**/*IT.java", "**/*IntegrationTest.java"]
---

# Java Test Conventions

Apply these rules whenever editing or reviewing test files.

## Naming
- Test method: `methodName_stateUnderTest_expectedBehavior`
  - `findById_existingId_returnsUser`
  - `save_duplicateEmail_throwsDataIntegrityViolationException`
- Test class: mirrors the class under test — `UserServiceTest`, `ProductControllerTest`
- Integration tests: suffix `IT` — `OrderRepositoryIT`, `PaymentServiceIT`

## Structure (AAA Pattern)
Each test must follow Arrange → Act → Assert with blank lines separating them:
```java
@Test
void findById_existingId_returnsUser() {
    // Arrange
    User user = userRepository.save(new User("alice@example.com"));

    // Act
    Optional<User> result = userService.findById(user.getId());

    // Assert
    assertThat(result).isPresent();
    assertThat(result.get().getEmail()).isEqualTo("alice@example.com");
}
```

## Assertions
- Use **AssertJ** (`assertThat`) — not JUnit `assertEquals` / `assertTrue`
- One logical assertion concept per test — multiple `assertThat` calls on the same object are fine
- For exceptions: `assertThatThrownBy(() -> ...).isInstanceOf(X.class).hasMessage("...")`

## Unit Tests
- Mock external dependencies with `@ExtendWith(MockitoExtension.class)` and `@Mock` / `@InjectMocks`
- Never mock the class under test
- Never mock value objects or simple POJOs — construct them directly

## Integration Tests
- Use **Testcontainers** for database tests, not H2 — H2 dialect differences mask real bugs
- `@SpringBootTest` for full context; `@DataJpaTest` for repository slice tests
- Use `@ServiceConnection` (Spring Boot 3.1+) or `@DynamicPropertySource` to wire container URLs

## Coverage Expectations
- Service layer: aim for 80%+ line coverage
- Controller layer: test success path, validation failure, and not-found for each endpoint
- Repository layer: integration tests for custom queries; skip for derived query methods
