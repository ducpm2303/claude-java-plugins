---
globs: ["**/*Controller.java"]
---

# Spring Controller Conventions

Apply these rules whenever editing or reviewing `*Controller.java` files.

## Class-Level
- Annotate with `@RestController` (not `@Controller` + `@ResponseBody`)
- Use `@RequestMapping("/api/resource-name")` at class level for the base path
- Keep controllers thin — no business logic, no repository calls, no `@Transactional`
- One controller per resource domain (e.g., `ProductController` for `/api/products`)

## Method-Level Annotations
- Use specific HTTP method annotations: `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, `@PatchMapping`
- Never use `@RequestMapping` without `method` at the method level
- Always specify `produces = MediaType.APPLICATION_JSON_VALUE` on endpoints that return JSON bodies

## Return Types
- Return `ResponseEntity<T>` — never return raw `T` from controller methods
- `GET` by ID → `ResponseEntity<Dto>` with `404` if not found
- `POST` (create) → `ResponseEntity<Dto>` with `201 Created` and `Location` header
- `DELETE` → `ResponseEntity<Void>` with `204 No Content`
- List endpoints → `ResponseEntity<Page<Dto>>` or `ResponseEntity<List<Dto>>`

## Input Validation
- Annotate `@RequestBody` parameters with `@Valid`
- Annotate `@PathVariable` with `@NotBlank` or type constraints where appropriate
- Never trust user input without validation

## Error Handling
- Do not catch exceptions in controllers — delegate to a `@RestControllerAdvice` class
- Never return `200 OK` with an error body — use proper HTTP status codes
