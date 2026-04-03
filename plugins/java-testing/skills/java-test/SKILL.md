---
description: Generate JUnit 5 + Mockito unit tests or Testcontainers integration tests for Java code
argument-hint: "[paste the class to test, or describe what to test]"
---

Generate tests for the Java code I've provided. Before generating, ask all of the following (in one message):

1. **Java version:** (to use records, var, or other modern features in test code)
2. **Test type:** Unit tests (Mockito), integration tests (Testcontainers + @DataJpaTest or @SpringBootTest), or both?
3. **Test framework already in project?** JUnit 5 is assumed; are Mockito and AssertJ on the classpath?
4. **What behaviour to focus on?** Or should I cover all public methods?

Then generate tests following these rules:

## Unit test template (Mockito)

```java
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserServiceImpl sut; // system under test

    @Test
    void findById_existingId_returnsUser() {
        // Arrange
        var userId = 1L;
        var user = new User(userId, "Alice", "alice@example.com");
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        // Act
        var result = sut.findById(userId);

        // Assert
        assertThat(result.id()).isEqualTo(userId);
        assertThat(result.name()).isEqualTo("Alice");
    }

    @Test
    void findById_nonExistentId_throwsNotFoundException() {
        // Arrange
        var userId = 99L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // Act & Assert
        assertThatThrownBy(() -> sut.findById(userId))
            .isInstanceOf(ResourceNotFoundException.class)
            .hasMessageContaining("User not found");
    }
}
```

## Repository integration test template (@DataJpaTest + Testcontainers)

```java
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import static org.assertj.core.api.Assertions.*;

@DataJpaTest
@Testcontainers
class UserRepositoryTest {

    @Container
    @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

    @Autowired
    private UserRepository userRepository;

    @Test
    void save_validUser_persistsToDatabase() {
        // Arrange
        var user = new User(null, "Bob", "bob@example.com");

        // Act
        var saved = userRepository.save(user);

        // Assert
        assertThat(saved.getId()).isNotNull();
        assertThat(userRepository.findById(saved.getId())).isPresent();
    }
}
```

Note: `@ServiceConnection` requires Spring Boot 3.1+. For Spring Boot 2.x, use `@DynamicPropertySource` to inject the container URL.

## What to generate for the provided code
- Cover the **happy path** for every public method
- Cover **each failure path** (not found, invalid input, constraint violations)
- Cover **edge cases** visible from the method signature (null inputs, empty collections, boundary values)
- Do NOT test private methods directly — test them through the public API

List the generated test file path at the end, e.g.: `src/test/java/com/example/service/UserServiceTest.java`
