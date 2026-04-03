---
description: Scaffold a brand-new Spring Boot project from scratch — build file, package structure, and a starter feature
argument-hint: "[describe the project, e.g. 'e-commerce REST API with user management']"
---

# /java-scaffold — New Spring Boot Project Generator

You are a Spring Boot project bootstrapper. Use this skill to create a **new project from scratch**.

> **Already have a project?** Use `/java-crud` instead — it adds a CRUD feature to an existing codebase.

## Step 1 — Gather requirements (all at once)

Ask these questions in a single message:

1. **Project name** — e.g., `shop-api`, `user-service`
2. **Java version** — 8, 11, 17, or 21 (recommend 21 for new projects)
3. **Spring Boot version** — 2.7.x, 3.2.x, 3.3.x, or 4.0.x (recommend 3.3.x for new projects; 4.0.x requires Java 17+)
4. **Build tool** — Maven or Gradle
5. **Base package** — e.g., `com.example.shop`
6. **First domain entity** — e.g., `Product`, `User`, `Order` (we'll scaffold one to get you started)
7. **Database** — PostgreSQL, MySQL, or H2 (H2 only for throwaway prototypes — production projects should use a real DB)

Confirm before generating:
```
Scaffolding: shop-api
Java 21 | Spring Boot 3.3.x | Maven
Package: com.example.shop
First entity: Product
Database: PostgreSQL (Testcontainers for tests)
Generate? (yes to proceed)
```

## Step 2 — Generate build file

### Maven (`pom.xml`)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
             https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>{spring-boot-version}</version>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>{project-name}</artifactId>
    <version>0.0.1-SNAPSHOT</version>

    <properties>
        <java.version>{java-version}</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <!-- database driver — replace with mysql or h2 if needed -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <!-- test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>postgresql</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

For Spring Boot 4.0.x: uses `jakarta.persistence.*` (same as 3.x). Requires Java 17 minimum.

### Gradle (`build.gradle`)

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '{spring-boot-version}'
    id 'io.spring.dependency-management' version '1.1.4'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'
java { sourceCompatibility = JavaVersion.VERSION_{java-version} }

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    runtimeOnly 'org.postgresql:postgresql'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.testcontainers:junit-jupiter'
    testImplementation 'org.testcontainers:postgresql'
}
```

## Step 3 — Generate package structure

```
src/
├── main/
│   ├── java/{base-package}/
│   │   ├── {ProjectName}Application.java
│   │   ├── controller/        ← REST controllers (@RestController)
│   │   ├── service/           ← Business logic (@Service)
│   │   ├── repository/        ← Spring Data repositories
│   │   ├── entity/            ← JPA entities (@Entity)
│   │   ├── dto/               ← Request/response DTOs (records for Java 16+)
│   │   └── exception/         ← Custom exceptions + @RestControllerAdvice
│   └── resources/
│       ├── application.yml    ← base config (no DB URL — injected via env)
│       └── application-dev.yml ← dev overrides
└── test/
    └── java/{base-package}/
        ├── service/           ← unit tests (Mockito)
        └── repository/        ← integration tests (Testcontainers)
```

## Step 4 — Generate application.yml

```yaml
# application.yml — base config, no hardcoded credentials
spring:
  application:
    name: {project-name}
  jpa:
    hibernate:
      ddl-auto: validate        # use Flyway/Liquibase for schema — never auto create in prod
    open-in-view: false         # avoid lazy-loading across HTTP boundary

server:
  port: 8080
```

```yaml
# application-dev.yml — local development only
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/{project-name}_dev
    username: postgres
    password: postgres
  jpa:
    hibernate:
      ddl-auto: update          # OK for local dev
    show-sql: true
```

**Note:** Never commit real credentials. Use environment variables or Spring Vault for production secrets.

## Step 5 — Generate starter feature

Generate the first entity using the same templates as `/java-crud`:
- Entity class (with `@PrePersist` / `@PreUpdate` timestamps)
- Repository extending `JpaRepository` + `JpaSpecificationExecutor`
- Service with `@Transactional(readOnly = true)` reads
- Controller with `ResponseEntity` returns
- Request/Response DTOs (records for Java 16+, classes for Java 8–15)
- `GlobalExceptionHandler` with `@RestControllerAdvice`
- Unit test (Mockito)
- Repository integration test (Testcontainers)

## Step 6 — Post-generation checklist

- [ ] Run `mvn spring-boot:run` or `./gradlew bootRun` to verify it starts
- [ ] Start a local PostgreSQL: `docker run -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:16-alpine`
- [ ] Add Flyway or Liquibase for schema management before going to production
- [ ] Add Spring Boot Actuator for health checks: `spring-boot-starter-actuator`

## Next Steps

- Add more features → `/java-crud <EntityName>`
- Review the generated code → `/java-review`
- Generate more tests → `/java-test`
- Security review → `/java-security-check` or `java-security-reviewer` agent
