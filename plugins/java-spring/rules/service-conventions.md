---
globs: ["**/*Service.java", "**/*ServiceImpl.java"]
---

# Spring Service Conventions

Apply these rules whenever editing or reviewing `*Service.java` / `*ServiceImpl.java` files.

## Class Structure
- Annotate with `@Service`
- Use constructor injection only — `final` fields, no `@Autowired` on fields
- One service per domain aggregate (e.g., `OrderService` for all order operations)
- Prefer interface + implementation (`OrderService` interface + `OrderServiceImpl`) only if multiple implementations exist; otherwise a concrete `@Service` class is fine

## Transactions
- Place `@Transactional` on service methods, not controller methods
- Read-only operations must use `@Transactional(readOnly = true)` — this is a performance hint, not optional
- Do not call `@Transactional` methods from within the same class — the proxy is bypassed
- Avoid `@Transactional` at class level unless every method truly needs it

## Business Logic
- All business logic lives in the service layer — controllers only delegate, repositories only persist
- Throw domain-specific exceptions from services (e.g., `OrderNotFoundException`) — let `@RestControllerAdvice` map them to HTTP status codes
- Never return JPA entity objects from service methods — map to DTOs before returning to controllers

## Method Design
- Use `Optional<T>` return types when a result may be absent
- Prefer `findById(id).orElseThrow(() -> new EntityNotFoundException(...))` over manual null checks
- Keep methods focused: one operation, one transaction boundary
