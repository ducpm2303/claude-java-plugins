---
globs: ["**/*.java", "**/*Test.java", "**/*Tests.java", "**/*IT.java"]
---

# Java Testing — Testing Standards

These rules apply whenever the java-testing plugin is active.

## Test Naming
Use the pattern: `methodName_stateUnderTest_expectedBehavior`
- `findById_existingId_returnsUser`
- `findById_nonExistentId_throwsNotFoundException`
- `createUser_duplicateEmail_throwsConflictException`

## Test Structure — AAA Pattern
Every test follows Arrange → Act → Assert:
```java
@Test
void methodName_state_expectedBehavior() {
    // Arrange
    var input = ...;
    when(dependency.method(input)).thenReturn(value);

    // Act
    var result = sut.method(input);

    // Assert
    assertThat(result).isEqualTo(expected);
}
```
One logical assertion concept per test. Use AssertJ (`assertThat`) not JUnit assertions where possible.

## What to Mock
- Mock external dependencies (repositories, HTTP clients, message queues, clocks)
- Never mock the class under test (the System Under Test, or SUT)
- Never mock value objects or data classes
- For database integration tests, use Testcontainers with a real database engine — not H2 in-memory

## Test Types
- **Unit tests:** test one class in isolation with mocked dependencies. Fast, no I/O.
- **Integration tests (`@SpringBootTest`):** test the full Spring context. Slow, use sparingly.
- **Slice tests:** `@WebMvcTest` for controllers, `@DataJpaTest` for repositories. Preferred over full `@SpringBootTest`.

## Coverage Target
Aim for 80%+ line coverage on the service layer. Do not write tests purely for coverage — write tests that document behaviour and catch regressions.

## Test Independence
- Each test must be able to run in any order
- Tests must not share mutable state
- Clean up any data created in `@BeforeEach` within `@AfterEach`
