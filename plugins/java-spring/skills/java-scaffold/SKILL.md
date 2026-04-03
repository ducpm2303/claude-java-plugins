---
description: Scaffolds a brand-new Spring Boot project from scratch — build file, package structure, and a starter feature. Use when user asks to "create a new Spring Boot project", "bootstrap a project", "start a new project", "generate a new app", or "scaffold a new service".
argument-hint: "[describe the project, e.g. 'e-commerce REST API with user management']"
---

# /java-scaffold — New Spring Boot Project Generator

You are a Spring Boot project bootstrapper. Use this skill to create a **new project from scratch**.

> **Already have a project?** Use `/java-crud` instead — it adds a CRUD feature to an existing codebase.

## Step 1 — Gather requirements (all at once)

Ask these questions in a single message:

1. **Project name** — e.g., `shop-api`, `user-service`
2. **Java version** — 8, 11, 17, or 21 (recommend 21 for new projects)
3. **Spring Boot version** — 2.7.x, 3.2.x, 3.3.x, or 4.0.x (recommend 3.3.x; 4.0.x requires Java 17+)
4. **Build tool** — Maven or Gradle
5. **Base package** — e.g., `com.example.shop`
6. **First domain entity** — e.g., `Product`, `User`, `Order`
7. **Database** — PostgreSQL, MySQL, or H2 (H2 only for throwaway prototypes)

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

Use the Maven or Gradle template from `references/templates.md`. Fill in `{spring-boot-version}`, `{project-name}`, and `{java-version}`.

For Spring Boot 4.0.x: uses `jakarta.persistence.*` (same as 3.x). Requires Java 17 minimum.

## Step 3 — Generate package structure

Use the directory layout from `references/templates.md`.

## Step 4 — Generate application.yml

Use the `application.yml` and `application-dev.yml` templates from `references/templates.md`.

**Note:** Never commit real credentials. Use environment variables or Spring Vault for production secrets.

## Step 5 — Generate starter feature

Generate the first entity using the same templates as `/java-crud`:
- Entity class (with `@PrePersist` / `@PreUpdate` timestamps)
- Repository extending `JpaRepository`
- Service with `@Transactional(readOnly = true)` reads
- Controller with `ResponseEntity` returns
- Request/Response DTOs (records for Java 16+, classes for Java 8–15)
- `GlobalExceptionHandler` with `@RestControllerAdvice` — see `references/templates.md`
- Unit test (Mockito)
- Repository integration test (Testcontainers)

**Spring Boot version rules:**
- 3.x+: use `jakarta.persistence.*`, `@SQLRestriction` for soft delete
- 2.x: use `javax.persistence.*`, `@Where(clause = "deleted = false")` for soft delete

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
