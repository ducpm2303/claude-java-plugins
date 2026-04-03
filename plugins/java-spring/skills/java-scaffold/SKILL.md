---
description: Scaffold a new Spring Boot project or feature (REST layer, service, repository, tests)
argument-hint: "[describe what to scaffold, e.g. 'user management REST API']"
---

Scaffold the Spring Boot project or feature I've described. Before generating any code, ask the following questions (all at once, in a single message):

1. **Java version:** What Java version are you targeting? (8, 11, 17, 21)
2. **Spring Boot version:** What Spring Boot version? (2.7.x, 3.0.x, 3.1.x, 3.2.x, or latest)
3. **Build tool:** Maven or Gradle?
4. **What to scaffold:** Choose one:
   - (A) New project from scratch (generates full directory structure + pom.xml/build.gradle)
   - (B) New feature in existing project (generates layers for a specific domain entity)
5. **Layers needed:** Which layers? (Controller, Service, Repository, DTOs, Tests — default: all)
6. **Domain entity name:** What is the main entity? (e.g., "User", "Order", "Product")

Once answers are provided, generate the following (adjusted for chosen options):

## For option A — New project

**`pom.xml` or `build.gradle`** with:
- Spring Boot parent/plugin at specified version
- `spring-boot-starter-web`
- `spring-boot-starter-data-jpa`
- `spring-boot-starter-validation`
- `spring-boot-starter-test` (test scope)
- Java version set correctly

**Package structure:**
```
src/main/java/com/example/<projectname>/
├── <ProjectName>Application.java
├── controller/
├── service/
│   └── impl/
├── repository/
├── entity/
├── dto/
└── exception/
src/main/resources/
└── application.yml
src/test/java/com/example/<projectname>/
└── controller/
└── service/
```

## For option B — New feature

Generate these files for the named entity (e.g., `User`):

**Entity** (`entity/User.java`):
- `@Entity`, `@Table(name = "users")`
- `@Id`, `@GeneratedValue(strategy = GenerationType.IDENTITY)`
- Fields with appropriate JPA annotations
- Use records for Java 16+; use a standard class with Lombok-style getters for Java 8–15

**Repository** (`repository/UserRepository.java`):
- `extends JpaRepository<User, Long>`
- One example custom query method

**Service interface** (`service/UserService.java`) and **implementation** (`service/impl/UserServiceImpl.java`):
- Constructor injection of `UserRepository`
- `findById`, `findAll`, `create`, `update`, `delete` methods
- `@Transactional(readOnly = true)` on read methods
- Throw `ResourceNotFoundException` (custom) when entity not found

**DTO** (`dto/UserRequest.java` and `dto/UserResponse.java`):
- Use records for Java 16+; plain classes with constructors for Java 8–15
- Bean Validation annotations on request DTO (`@NotBlank`, `@Email`, etc.)

**Controller** (`controller/UserController.java`):
- `@RestController`, `@RequestMapping("/api/users")`
- Constructor injection of `UserService`
- `GET /api/users`, `GET /api/users/{id}`, `POST /api/users`, `PUT /api/users/{id}`, `DELETE /api/users/{id}`
- Returns `ResponseEntity<UserResponse>` with correct status codes

**Exception handler** (`exception/GlobalExceptionHandler.java`):
- `@RestControllerAdvice`
- Handles `ResourceNotFoundException` → 404
- Handles `MethodArgumentNotValidException` → 400 with field errors

**Unit test** (`test/.../service/UserServiceTest.java`):
- JUnit 5 + Mockito
- Tests for `findById` (found and not found cases)

**`application.yml`** with H2 in-memory DB config for development.

After generating, list the files created and suggest running `mvn spring-boot:run` or `./gradlew bootRun`.

## Next Steps
After scaffolding:
- Run `/java-review` on the generated code to catch any issues
- Run `/java-test` to generate tests for the scaffolded service layer
- If security is critical → ask the `java-security-reviewer` agent to review the controller
- Start the app: `mvn spring-boot:run` or `./gradlew bootRun`
