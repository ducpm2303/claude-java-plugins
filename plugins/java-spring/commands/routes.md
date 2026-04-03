---
description: List all REST endpoints in the Spring Boot project — scans controllers and prints a route table
---

# /java-spring:routes

Scan the project and print all REST API endpoints.

## Instructions

1. Find all `@RestController` and `@Controller` classes in `src/main/java/`

2. For each controller, extract:
   - Class-level `@RequestMapping` prefix (if any)
   - Method-level `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, `@PatchMapping`
   - Method signature (parameter names and types)
   - Return type

3. Print a route table:

```
METHOD   PATH                          HANDLER
------   ----                          -------
GET      /api/products                 ProductController#findAll
GET      /api/products/{id}            ProductController#findById
POST     /api/products                 ProductController#create
PUT      /api/products/{id}            ProductController#update
DELETE   /api/products/{id}            ProductController#delete
```

4. After the table, note any issues:
   - Missing `@Valid` on `@RequestBody` parameters
   - Methods returning `void` or raw types instead of `ResponseEntity<T>`
   - Endpoints with no authentication that look sensitive (e.g., `/admin`, `/actuator`)

5. Summary line: total endpoint count, controllers scanned.
