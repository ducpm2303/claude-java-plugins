---
description: Generates a complete Spring Boot CRUD feature (entity, repository, service, controller, DTOs, tests) in an existing project. Use when user asks to "add CRUD for", "generate entity", "create a feature for", "add REST endpoints for", "scaffold a feature", or "build CRUD for".
argument-hint: "<EntityName> [fields: field:type, ...] [Java version] [Spring Boot version]"
---

# /java-crud — Spring Boot CRUD Generator

You are a Spring Boot code generator. Add a complete CRUD feature to an **existing** project.

> **Starting a new project from scratch?** Use `/java-scaffold` instead.

## Step 1 — Gather requirements

Parse arguments if provided. Otherwise ask (in a single message):

1. **Entity name** — e.g., `Product`, `CustomerOrder`
2. **Fields** — name and type, e.g., `name:String, price:BigDecimal, category:String, active:boolean`
3. **Soft delete?** — yes/no
4. **Java version** — check `pom.xml` / `build.gradle`, ask if not found
5. **Spring Boot version** — 2.x (`javax.persistence`) or 3.x+ (`jakarta.persistence`)

Confirm before generating:
```
Adding CRUD feature: Product
Fields: id (auto), name (String), price (BigDecimal), category (String), active (boolean)
Java: 17 | Spring Boot: 3.2 | Soft delete: no
Generate? (yes to proceed)
```

## Step 2 — Detect base package

Check `src/main/java/` for the existing package structure. Match the project's conventions.

## Step 3 — Generate all layers

Use the templates in `references/templates.md`. Generate files in this order, stating the full path before each:

1. `src/main/java/{package}/entity/{Entity}.java`
2. `src/main/java/{package}/repository/{Entity}Repository.java`
3. `src/main/java/{package}/dto/{Entity}Request.java` + `{Entity}Response.java`
4. `src/main/java/{package}/service/{Entity}Service.java`
5. `src/main/java/{package}/controller/{Entity}Controller.java`
6. `src/test/java/{package}/service/{Entity}ServiceTest.java`

**Spring Boot version rules:**
- 3.x+: use `jakarta.persistence.*`, `@SQLRestriction` for soft delete
- 2.x: use `javax.persistence.*`, `@Where(clause = "deleted = false")` for soft delete

**Java version rules:**
- 16+: use records for DTOs
- 8–15: use plain classes with constructors and getters

## Step 4 — Post-generation checklist

- [ ] Replace `com.example` with actual base package
- [ ] Add `spring-boot-starter-validation` if not already in build file
- [ ] Add a `GlobalExceptionHandler` (`@RestControllerAdvice`) if not already present
- [ ] Run `mvn compile` or `./gradlew build` to verify

## Step 5 — Next Steps

- Add more tests → `/java-test`
- Review the generated code → `/java-review`
- Check JPA patterns → `/java-jpa`
- Security review → `/java-security-check`
