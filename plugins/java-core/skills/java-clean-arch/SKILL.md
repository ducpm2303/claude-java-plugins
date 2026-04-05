---
description: Reviews or implements Clean Architecture / Hexagonal Architecture (Ports & Adapters) and DDD tactical patterns for Java projects. Use when user asks to "apply clean architecture", "implement hexagonal architecture", "add ports and adapters", "apply DDD", "refactor to clean arch", "review architecture", or "add value objects".
argument-hint: "[review | implement | ddd] [module or package name]"
allowed-tools: Read, Grep, Glob
---

# /java-clean-arch — Clean / Hexagonal Architecture Advisor

You are a Java architecture specialist. Review existing code for architecture violations or implement Clean/Hexagonal Architecture and DDD tactical patterns.

## Step 1 — Understand the current structure

Scan `src/main/java/` and map the existing package layout. Identify the architecture style:

| Pattern | Signs |
|---|---|
| **Layered** | `controller/`, `service/`, `repository/`, `entity/` |
| **Package-by-feature** | `order/`, `user/`, `product/` with sub-packages |
| **Hexagonal** | `domain/`, `application/`, `infrastructure/`, `adapter/` |
| **Mixed / unclear** | None of the above clearly |

Then determine mode from argument: `review` (default), `implement`, or `ddd`.

---

## Step 2 — Review mode: audit for violations

**Dependency rule violations** (inner layers must not know outer layers):

| Violation | Example | Severity |
|---|---|---|
| Domain imports Spring annotations | `@Entity`, `@Service` in domain classes | HIGH |
| Domain imports infrastructure types | `JpaRepository`, `HttpServletRequest` in domain | HIGH |
| Use case / service imports controller types | `ResponseEntity` in service layer | HIGH |
| Repository interface in domain returns JPA entity | Domain leaks persistence model | MEDIUM |
| Business logic in controller | `if/else` rules in `@RestController` | MEDIUM |
| Business logic in JPA entity | Complex calculations in `@Entity` | MEDIUM |

**DDD tactical pattern opportunities:**

- Plain `String` for IDs → suggest `ProductId` value object
- Primitive obsession (e.g., `String email`, `String phone`) → suggest value objects with validation
- Anemic domain model (entities are just getters/setters, all logic in services) → suggest moving behaviour to domain
- Missing domain events for side effects → suggest `ProductCreatedEvent`, etc.

Report each finding with file:line, violation type, and a concrete refactoring suggestion.

---

## Step 3 — Implement mode: scaffold hexagonal structure

Generate the target package layout and explain the role of each layer:

```
src/main/java/{base-package}/
├── domain/                        ← innermost, no dependencies
│   ├── model/                     ← entities, value objects, aggregates
│   │   ├── Product.java           ← rich domain entity
│   │   ├── ProductId.java         ← value object
│   │   └── Money.java             ← value object
│   ├── port/
│   │   ├── in/                    ← use case interfaces (driving ports)
│   │   │   ├── CreateProductUseCase.java
│   │   │   └── GetProductUseCase.java
│   │   └── out/                   ← repository/external interfaces (driven ports)
│   │       └── ProductRepository.java
│   └── event/                     ← domain events
│       └── ProductCreatedEvent.java
│
├── application/                   ← orchestrates domain, no framework code
│   └── service/
│       └── ProductService.java    ← implements use case interfaces
│
└── infrastructure/                ← outermost, all framework/DB/HTTP code
    ├── adapter/
    │   ├── in/
    │   │   └── web/
    │   │       └── ProductController.java   ← REST adapter
    │   └── out/
    │       └── persistence/
    │           ├── ProductJpaEntity.java    ← JPA model (separate from domain entity)
    │           ├── ProductJpaRepository.java
    │           └── ProductPersistenceAdapter.java  ← implements domain port
    └── config/
        └── BeanConfig.java
```

Use the templates in `references/patterns.md` for each layer.

---

## Step 4 — DDD mode: implement tactical patterns

### Value Objects (Java 16+: use records)

```java
// Java 16+
public record ProductId(Long value) {
    public ProductId {
        Objects.requireNonNull(value, "ProductId cannot be null");
        if (value <= 0) throw new IllegalArgumentException("ProductId must be positive");
    }
}

public record Money(BigDecimal amount, String currency) {
    public static final String DEFAULT_CURRENCY = "USD";
    public Money {
        Objects.requireNonNull(amount);
        if (amount.compareTo(BigDecimal.ZERO) < 0)
            throw new IllegalArgumentException("Money cannot be negative");
    }
    public Money add(Money other) {
        if (!this.currency.equals(other.currency))
            throw new IllegalArgumentException("Currency mismatch");
        return new Money(this.amount.add(other.amount), this.currency);
    }
}
```

### Rich Domain Entity

```java
public class Product {                          // NO @Entity here — pure domain
    private final ProductId id;
    private String name;
    private Money price;
    private boolean active;
    private final List<DomainEvent> domainEvents = new ArrayList<>();

    public static Product create(String name, Money price) {
        Product p = new Product(ProductId.generate(), name, price, true);
        p.domainEvents.add(new ProductCreatedEvent(p.id, p.name));
        return p;
    }

    public void deactivate() {
        if (!this.active) throw new IllegalStateException("Already inactive");
        this.active = false;
        domainEvents.add(new ProductDeactivatedEvent(this.id));
    }

    public List<DomainEvent> pullDomainEvents() {
        var events = List.copyOf(domainEvents);
        domainEvents.clear();
        return events;
    }
    // ... getters only, no setters
}
```

### Domain Port (interface in domain layer)

```java
// in domain/port/out/
public interface ProductRepository {
    Optional<Product> findById(ProductId id);
    Product save(Product product);
    List<Product> findAll();
    void delete(ProductId id);
}
```

### Persistence Adapter (in infrastructure)

```java
// Implements domain port, lives in infrastructure
@Component
@RequiredArgsConstructor
public class ProductPersistenceAdapter implements ProductRepository {

    private final ProductJpaRepository jpaRepository;

    @Override
    public Optional<Product> findById(ProductId id) {
        return jpaRepository.findById(id.value()).map(this::toDomain);
    }

    @Override
    public Product save(Product product) {
        ProductJpaEntity entity = toJpa(product);
        return toDomain(jpaRepository.save(entity));
    }

    private Product toDomain(ProductJpaEntity e) { ... }  // mapping logic
    private ProductJpaEntity toJpa(Product p) { ... }
}
```

---

## Step 5 — Migration path (layered → hexagonal)

If the project is currently layered, suggest a phased migration:

1. **Phase 1** — Extract domain interfaces (ports): create `ProductRepository` interface in domain; keep Spring Data impl in infrastructure
2. **Phase 2** — Decouple domain entity from JPA: create separate `ProductJpaEntity`, map in adapter
3. **Phase 3** — Move business logic from service into domain entity; service becomes thin orchestrator
4. **Phase 4** — Add value objects for primitive types
5. **Phase 5** — Add domain events for cross-aggregate side effects

Each phase is independently deployable and testable — do not attempt all at once.

---

## Step 6 — Post-review checklist

- [ ] Domain layer has zero imports from `org.springframework`, `jakarta.persistence`
- [ ] Use case interfaces define inputs/outputs as domain types, not DTOs or JPA entities
- [ ] Each aggregate has a single point of creation (factory method or constructor)
- [ ] Domain events are used for cross-aggregate side effects (not direct calls)
- [ ] Persistence adapter tests use `@DataJpaTest` (infrastructure); domain tests are plain JUnit

## Next Steps

- Review code quality → `/java-review`
- Check SOLID compliance → `/java-solid`
- Review JPA layer → `/java-jpa`
- Generate architecture decision record → `/java-adr`
