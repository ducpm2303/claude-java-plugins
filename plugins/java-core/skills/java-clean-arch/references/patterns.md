# Clean Architecture Reference Patterns

---

## Use Case interface (driving port)

```java
// domain/port/in/CreateProductUseCase.java
public interface CreateProductUseCase {
    Product createProduct(CreateProductCommand command);

    record CreateProductCommand(String name, BigDecimal price, String currency, String category) {
        public CreateProductCommand {
            Objects.requireNonNull(name, "name required");
            Objects.requireNonNull(price, "price required");
        }
    }
}
```

---

## Application service (implements use case)

```java
// application/service/ProductService.java
@Service
@Transactional
@RequiredArgsConstructor
public class ProductService implements CreateProductUseCase, GetProductUseCase {

    private final ProductRepository productRepository;          // domain port
    private final ApplicationEventPublisher eventPublisher;     // Spring, but only here

    @Override
    public Product createProduct(CreateProductCommand cmd) {
        Money price = new Money(cmd.price(), cmd.currency());
        Product product = Product.create(cmd.name(), price);
        Product saved = productRepository.save(product);
        saved.pullDomainEvents().forEach(eventPublisher::publishEvent);
        return saved;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Product> getProduct(ProductId id) {
        return productRepository.findById(id);
    }
}
```

---

## REST adapter (driving adapter — calls use case)

```java
// infrastructure/adapter/in/web/ProductController.java
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final CreateProductUseCase createProduct;
    private final GetProductUseCase getProduct;

    @PostMapping
    public ResponseEntity<ProductResponse> create(@Valid @RequestBody ProductRequest request) {
        var command = new CreateProductUseCase.CreateProductCommand(
            request.name(), request.price(), request.currency(), request.category());
        Product product = createProduct.createProduct(command);
        return ResponseEntity.status(HttpStatus.CREATED).body(ProductResponse.from(product));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductResponse> findById(@PathVariable Long id) {
        return getProduct.getProduct(new ProductId(id))
            .map(ProductResponse::from)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}
```

---

## JPA entity (infrastructure only — separate from domain entity)

```java
// infrastructure/adapter/out/persistence/ProductJpaEntity.java
@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
public class ProductJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, precision = 19, scale = 4)
    private BigDecimal price;

    @Column(nullable = false, length = 3)
    private String currency;

    @Column(nullable = false)
    private boolean active;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void prePersist() { this.createdAt = LocalDateTime.now(); }
}
```

---

## Domain event

```java
// domain/event/ProductCreatedEvent.java
public record ProductCreatedEvent(ProductId productId, String name, Instant occurredOn) {
    public ProductCreatedEvent(ProductId productId, String name) {
        this(productId, name, Instant.now());
    }
}
```

---

## ArchUnit test (enforce dependency rules)

```java
@AnalyzeClasses(packagesOf = Application.class)
public class ArchitectureTest {

    @ArchTest
    static final ArchRule domain_must_not_depend_on_spring =
        noClasses().that().resideInAPackage("..domain..")
            .should().dependOnClassesThat()
            .resideInAnyPackage("org.springframework..", "jakarta.persistence..");

    @ArchTest
    static final ArchRule application_must_not_depend_on_infrastructure =
        noClasses().that().resideInAPackage("..application..")
            .should().dependOnClassesThat()
            .resideInAPackage("..infrastructure..");

    @ArchTest
    static final ArchRule adapters_must_not_depend_on_each_other =
        noClasses().that().resideInAPackage("..adapter.in..")
            .should().dependOnClassesThat()
            .resideInAPackage("..adapter.out..");
}
```

Add to `pom.xml`:
```xml
<dependency>
    <groupId>com.tngtech.archunit</groupId>
    <artifactId>archunit-junit5</artifactId>
    <version>1.3.0</version>
    <scope>test</scope>
</dependency>
```
