---
description: Generate a complete Spring Boot CRUD feature — entity, repository, service, controller, DTOs, and tests — from a description or existing entity
argument-hint: "<EntityName> [fields: field:type, ...] [Java version] [Spring Boot version]"
---

# /java-crud — Spring Boot CRUD Generator

You are a Spring Boot code generator. Generate a complete, production-quality CRUD feature from a description or an existing entity class.

## Step 1 — Gather requirements

If the user provided arguments, parse them. Otherwise ask:

1. **Entity name** — e.g., `Product`, `CustomerOrder`
2. **Fields** — name and type, e.g., `name:String, price:BigDecimal, category:String, active:boolean`
3. **Java version** — check `pom.xml` / `build.gradle`; ask if not found
4. **Spring Boot version** — 2.x (`javax.persistence`) or 3.x (`jakarta.persistence`)
5. **Pagination needed?** — yes/no (default: yes for list endpoints)
6. **Soft delete?** — yes/no (adds `deleted:boolean` + `@Where` filter)

Confirm the plan before generating:
```
I'll generate a CRUD feature for: Product
Fields: id (auto), name (String), price (BigDecimal), category (String), active (boolean)
Java: 17 | Spring Boot: 3.2
Layers: Entity → Repository → Service → Controller → DTOs (Request/Response) → Tests
Soft delete: no | Pagination: yes
Generate? (yes to proceed)
```

## Step 2 — Generate each layer

Generate files in this order. For each file, state the full path before the code block.

---

### 2a. Entity

**File:** `src/main/java/com/example/domain/{Entity}.java`

```java
// Java 17+ with Spring Boot 3.x template
package com.example.domain;

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
    protected void onCreate() {
        createdAt = updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // getters and setters (or Lombok @Getter @Setter)
}
```

For Java 16+ with Spring Boot 3.x, offer a Record-based DTO but keep the Entity as a class (JPA requires it).

For soft delete, add:
```java
@Column(nullable = false)
private boolean deleted = false;

// Add @SQLRestriction("deleted = false") on the class (Spring Boot 3.2+)
// or @Where(clause = "deleted = false") (Spring Boot 2.x / Hibernate 5)
```

---

### 2b. Repository

**File:** `src/main/java/com/example/repository/{Entity}Repository.java`

```java
package com.example.repository;

import com.example.domain.{Entity};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

@Repository
public interface {Entity}Repository extends JpaRepository<{Entity}, Long>,
        JpaSpecificationExecutor<{Entity}> {
}
```

Add `JpaSpecificationExecutor` always — enables dynamic filtering without boilerplate later.

---

### 2c. DTOs

**File:** `src/main/java/com/example/dto/{Entity}Request.java`

For Java 16+:
```java
// Record — immutable, no boilerplate
public record {Entity}Request(
    @NotBlank String name,
    @NotNull @Positive BigDecimal price,
    String category,
    boolean active
) {}
```

For Java 8–15:
```java
public class {Entity}Request {
    @NotBlank
    private String name;
    // ... fields, constructor, getters
}
```

**File:** `src/main/java/com/example/dto/{Entity}Response.java`

```java
public record {Entity}Response(
    Long id,
    String name,
    BigDecimal price,
    String category,
    boolean active,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
    public static {Entity}Response from({Entity} entity) {
        return new {Entity}Response(
            entity.getId(),
            entity.getName(),
            entity.getPrice(),
            entity.getCategory(),
            entity.isActive(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
}
```

---

### 2d. Service

**File:** `src/main/java/com/example/service/{Entity}Service.java`

```java
package com.example.service;

import com.example.domain.{Entity};
import com.example.dto.{Entity}Request;
import com.example.dto.{Entity}Response;
import com.example.repository.{Entity}Repository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
        if (!repository.existsById(id)) {
            throw new EntityNotFoundException("{Entity} not found: " + id);
        }
        repository.deleteById(id);
    }

    private void mapRequestToEntity({Entity}Request request, {Entity} entity) {
        entity.setName(request.name());
        entity.setPrice(request.price());
        entity.setCategory(request.category());
        entity.setActive(request.active());
    }
}
```

For soft delete, replace `deleteById` with:
```java
entity.setDeleted(true);
repository.save(entity);
```

---

### 2e. Controller

**File:** `src/main/java/com/example/controller/{Entity}Controller.java`

```java
package com.example.controller;

import com.example.dto.{Entity}Request;
import com.example.dto.{Entity}Response;
import com.example.service.{Entity}Service;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
    public ResponseEntity<{Entity}Response> create(@Valid @RequestBody {Entity}Request request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<{Entity}Response> update(
            @PathVariable Long id,
            @Valid @RequestBody {Entity}Request request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
```

---

### 2f. Service Unit Test

**File:** `src/test/java/com/example/service/{Entity}ServiceTest.java`

```java
package com.example.service;

import com.example.domain.{Entity};
import com.example.dto.{Entity}Request;
import com.example.dto.{Entity}Response;
import com.example.repository.{Entity}Repository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class {Entity}ServiceTest {

    @Mock
    private {Entity}Repository repository;

    @InjectMocks
    private {Entity}Service service;

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
    void create_validRequest_savesAndReturnsResponse() {
        {Entity}Request request = new {Entity}Request("Product", new BigDecimal("9.99"), "A", true);
        {Entity} saved = new {Entity}();
        saved.setId(1L);
        saved.setName("Product");
        when(repository.save(any())).thenReturn(saved);

        {Entity}Response response = service.create(request);

        assertThat(response.id()).isEqualTo(1L);
        verify(repository).save(any({Entity}.class));
    }
}
```

---

## Step 3 — Post-generation checklist

After generating, remind the user to:
- [ ] Replace `com.example` with the actual base package
- [ ] Add `spring-boot-starter-validation` dependency if `@Valid` is used
- [ ] Add `lombok` dependency if `@RequiredArgsConstructor` / `@Slf4j` is used
- [ ] Add a global `@RestControllerAdvice` exception handler for `EntityNotFoundException` if not already present
- [ ] Run `mvn compile` or `./gradlew build` to verify

## Step 4 — Next Steps

After generating, offer:
- *"Run `/java-test` to generate Testcontainers integration tests for this CRUD feature"*
- *"Run `/java-jpa` to review the JPA entity and repository for performance issues"*
- *"Run `/java-security` to check the controller for input validation and auth gaps"*
