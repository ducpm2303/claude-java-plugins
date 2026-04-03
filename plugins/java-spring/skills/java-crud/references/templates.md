# CRUD Code Templates

Reference templates for each layer. Replace `{Entity}`, `{entity_path}`, `{entity_table}` with actual names.

---

## Entity

```java
package com.example.domain;

// Spring Boot 3.x: jakarta.persistence.*
// Spring Boot 2.x: javax.persistence.*
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "{entity_table}")
public class {Entity} {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // --- fields ---

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() { createdAt = updatedAt = LocalDateTime.now(); }

    @PreUpdate
    protected void onUpdate() { updatedAt = LocalDateTime.now(); }

    // getters and setters
}
```

**Soft delete addition:**
```java
@Column(nullable = false)
private boolean deleted = false;

// Spring Boot 3.2+:
@SQLRestriction("deleted = false")

// Spring Boot 2.x / Hibernate 5:
@Where(clause = "deleted = false")
```

---

## Repository

```java
@Repository
public interface {Entity}Repository extends JpaRepository<{Entity}, Long>,
        JpaSpecificationExecutor<{Entity}> {
}
```

---

## DTOs

**Java 16+ (records):**
```java
public record {Entity}Request(
    @NotBlank String name,
    @NotNull @Positive BigDecimal price,
    String category,
    boolean active
) {}

public record {Entity}Response(Long id, String name, BigDecimal price,
        String category, boolean active,
        LocalDateTime createdAt, LocalDateTime updatedAt) {
    public static {Entity}Response from({Entity} e) {
        return new {Entity}Response(e.getId(), e.getName(), e.getPrice(),
            e.getCategory(), e.isActive(), e.getCreatedAt(), e.getUpdatedAt());
    }
}
```

**Java 8–15 (classes):**
```java
public class {Entity}Request {
    @NotBlank private String name;
    // fields, constructor, getters
}
```

---

## Service

```java
@Service
@RequiredArgsConstructor
public class {Entity}Service {

    private final {Entity}Repository repository;

    @Transactional(readOnly = true)
    public Page<{Entity}Response> findAll(Pageable pageable) {
        return repository.findAll(pageable).map({Entity}Response::from);
    }

    @Transactional(readOnly = true)
    public {Entity}Response findById(Long id) {
        return repository.findById(id)
            .map({Entity}Response::from)
            .orElseThrow(() -> new EntityNotFoundException("{Entity} not found: " + id));
    }

    @Transactional
    public {Entity}Response create({Entity}Request request) {
        {Entity} entity = new {Entity}();
        mapRequestToEntity(request, entity);
        return {Entity}Response.from(repository.save(entity));
    }

    @Transactional
    public {Entity}Response update(Long id, {Entity}Request request) {
        {Entity} entity = repository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("{Entity} not found: " + id));
        mapRequestToEntity(request, entity);
        return {Entity}Response.from(repository.save(entity));
    }

    @Transactional
    public void delete(Long id) {
        if (!repository.existsById(id)) throw new EntityNotFoundException("{Entity} not found: " + id);
        repository.deleteById(id);
    }

    private void mapRequestToEntity({Entity}Request req, {Entity} entity) {
        entity.setName(req.name());
        // map remaining fields
    }
}
```

---

## Controller

```java
@RestController
@RequestMapping("/api/v1/{entity_path}")
@RequiredArgsConstructor
public class {Entity}Controller {

    private final {Entity}Service service;

    @GetMapping
    public ResponseEntity<Page<{Entity}Response>> list(Pageable pageable) {
        return ResponseEntity.ok(service.findAll(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<{Entity}Response> get(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @PostMapping
    public ResponseEntity<{Entity}Response> create(@Valid @RequestBody {Entity}Request req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(req));
    }

    @PutMapping("/{id}")
    public ResponseEntity<{Entity}Response> update(@PathVariable Long id,
            @Valid @RequestBody {Entity}Request req) {
        return ResponseEntity.ok(service.update(id, req));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
```

---

## Unit Test

```java
@ExtendWith(MockitoExtension.class)
class {Entity}ServiceTest {

    @Mock private {Entity}Repository repository;
    @InjectMocks private {Entity}Service service;

    @Test
    void findById_existingId_returnsResponse() {
        {Entity} entity = new {Entity}();
        entity.setId(1L);
        entity.setName("Test");
        when(repository.findById(1L)).thenReturn(Optional.of(entity));

        {Entity}Response response = service.findById(1L);

        assertThat(response.id()).isEqualTo(1L);
        assertThat(response.name()).isEqualTo("Test");
    }

    @Test
    void findById_missingId_throwsEntityNotFound() {
        when(repository.findById(99L)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.findById(99L))
            .isInstanceOf(EntityNotFoundException.class);
    }

    @Test
    void create_validRequest_savesAndReturns() {
        {Entity}Request req = new {Entity}Request("Item", new BigDecimal("9.99"), "A", true);
        {Entity} saved = new {Entity}(); saved.setId(1L); saved.setName("Item");
        when(repository.save(any())).thenReturn(saved);

        {Entity}Response resp = service.create(req);

        assertThat(resp.id()).isEqualTo(1L);
        verify(repository).save(any({Entity}.class));
    }
}
```
