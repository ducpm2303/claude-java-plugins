---
description: Generates or reviews OpenAPI / Swagger documentation for Spring Boot REST APIs — adds @Operation, @Schema, @ApiResponse annotations and configures Swagger UI. Use when user asks to "add Swagger", "document this API", "generate OpenAPI spec", "add @Operation annotations", "set up Swagger UI", or "document endpoints".
argument-hint: "[generate | review | config] [Spring Boot version]"
allowed-tools: Read, Grep, Glob
---

# /java-openapi — OpenAPI / Swagger Documentation

You are an OpenAPI documentation specialist for Spring Boot. Generate annotations, review existing docs, or configure Swagger UI.

## Step 1 — Detect context

1. Check Spring Boot version and choose the right library:
   - Spring Boot 3.x → `springdoc-openapi-starter-webmvc-ui` (v2.x)
   - Spring Boot 2.x → `springdoc-openapi-ui` (v1.x)
2. Check if `springdoc` is already on the classpath
3. Determine mode from argument: `generate` (default), `review`, or `config`

---

## Step 2 — Add dependency (if not present)

Show the user the correct dependency to add:

**Spring Boot 3.x (`pom.xml`):**
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.5.0</version>
</dependency>
```

**Spring Boot 2.x (`pom.xml`):**
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-ui</artifactId>
    <version>1.8.0</version>
</dependency>
```

After adding: Swagger UI is available at `http://localhost:8080/swagger-ui.html`.

---

## Step 3 — Generate mode: annotate controllers

Scan all `@RestController` classes. For each one, add annotations following the rules below.

**Controller class level — `@Tag`:**
```java
@Tag(name = "Products", description = "Product catalogue management")
@RestController
@RequestMapping("/api/products")
public class ProductController { ... }
```

**Each endpoint method — `@Operation` + `@ApiResponse`:**

Use the templates in `references/annotations.md`. Key rules:
- `@Operation(summary = ...)` — one short line, verb phrase (e.g. "Get product by ID")
- `@Operation(description = ...)` — optional, only when behaviour is non-obvious
- Always document: `200`, the main error codes (`400`, `404`, `409`, `500`)
- Use `@ApiResponse(responseCode = "404", description = "Product not found")` not just the status code

**Request/Response DTOs — `@Schema`:**
- Annotate every field with `@Schema(description = "...", example = "...")`
- For required fields: `@Schema(requiredMode = Schema.RequiredMode.REQUIRED)`
- For enums: `@Schema(allowableValues = {"ACTIVE", "INACTIVE"})`

---

## Step 4 — Review mode: audit existing docs

Check for these issues:

| Issue | Severity |
|---|---|
| `@Operation` with empty or generic summary ("string", "TODO") | HIGH |
| Missing `@ApiResponse` for error codes the method actually throws | HIGH |
| DTO fields with no `@Schema` description | MEDIUM |
| No `@Tag` on controller class | MEDIUM |
| Sensitive fields exposed in response schema (passwords, tokens) | HIGH |
| `@Hidden` missing on internal/admin endpoints that shouldn't be in public docs | MEDIUM |

---

## Step 5 — Config mode: OpenAPI bean + Swagger UI setup

Use the config template in `references/annotations.md`. Covers:
- Global API info (title, version, description, contact, license)
- Security scheme (Bearer JWT in "Authorize" button)
- Environment-specific Swagger UI (disable in production)

**application.yml for Swagger UI:**
```yaml
springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html
    operations-sorter: method
    tags-sorter: alpha
  # Disable in production:
  # swagger-ui.enabled: false
  # api-docs.enabled: false
```

---

## Step 6 — Post-generation checklist

- [ ] Swagger UI loads at `/swagger-ui.html`
- [ ] All controllers have `@Tag`
- [ ] All endpoints have `@Operation(summary = ...)`
- [ ] All error responses are documented
- [ ] JWT "Authorize" button works (if security is configured)
- [ ] Sensitive fields are not in public API docs (`@JsonIgnore` or `@Schema(hidden = true)`)

## Next Steps

- Review REST API design → `/java-api-review`
- Add Spring Security → `/java-security`
- Review the full service → `/java-review`
