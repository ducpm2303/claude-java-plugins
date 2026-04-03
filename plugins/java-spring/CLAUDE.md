---
globs: ["**/*.java", "**/pom.xml", "**/build.gradle", "**/build.gradle.kts", "**/application.yml", "**/application.properties"]
---

# Java Spring — Spring Boot Best Practices

These rules apply whenever the java-spring plugin is active.

## Dependency Injection
- Always use **constructor injection**. Never use field injection (`@Autowired` on a field).
- Mark constructor-injected fields as `final`.
- For optional dependencies, use setter injection with `@Autowired(required = false)`.

## Layered Architecture
Enforce the Controller → Service → Repository flow:
- `@RestController` classes call `@Service` classes only — never repositories directly
- `@Service` classes call `@Repository` interfaces only — never other controllers
- Domain/entity classes have no Spring annotations

## Transactions
- Place `@Transactional` on `@Service` methods, never on `@RestController` methods
- Use `@Transactional(readOnly = true)` for read-only service methods (performance benefit)
- Avoid calling `@Transactional` methods from within the same class (proxy bypass)

## Configuration
- All configuration values come from `application.yml` or `application.properties`
- Inject config values with `@Value("${property.key}")` or via `@ConfigurationProperties` classes
- Never hardcode URLs, credentials, timeouts, or feature flags in Java code

## REST API Design
- Return `ResponseEntity<T>` from controller methods to control HTTP status codes explicitly
- Use `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, `@PatchMapping` — not `@RequestMapping`
- Return `404 Not Found` when a resource does not exist; do not return `200` with a null body
- Validate request bodies with `@Valid` and Bean Validation annotations (`@NotNull`, `@Size`, etc.)

## Spring Data JPA
- Prefer Spring Data repository query methods or `@Query` over `EntityManager` directly
- Use `@Transactional(readOnly = true)` in the service for queries
- Never call `save()` on an already-managed entity within a transaction — changes are auto-flushed
