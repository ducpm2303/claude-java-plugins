---
description: Reviews Spring Data JPA for N+1 queries, fetch strategies, projections, and Specifications. Use when user asks to "review JPA", "check for N+1", "JPA performance", "review my entities", "check fetch strategy", or "review my repositories".
argument-hint: "[file or class to review, optional]"
---

# /java-jpa — Spring Data JPA Deep Review

You are a Spring Data JPA specialist. Review JPA code for common performance and correctness problems.

## Step 1 — Detect Java and Spring Boot version

Check `pom.xml` or `build.gradle` for:
- Java version (affects stream/record usage)
- Spring Boot version (2.x uses `javax.persistence.*`, 3.x uses `jakarta.persistence.*`)

If neither is found, ask the user.

## Step 2 — Identify scope

If the user provided a file or class name, focus on that. Otherwise, scan for:
- `@Entity`, `@Repository`, `@Service` classes
- `JpaRepository` / `CrudRepository` / `PagingAndSortingRepository` extensions
- JPQL and native queries (`@Query`)
- `@Transactional` annotations

## Step 3 — Review for these issues

### N+1 Query Detection (HIGH PRIORITY)
Look for:
- `@OneToMany` or `@ManyToMany` without `fetch = FetchType.LAZY` (lazy is required; eager causes N+1 on collections)
- Loops that call a repository method or access a lazy collection on each iteration
- Missing `@EntityGraph` or JOIN FETCH when a relationship is always needed together

For each N+1 found, show:
```
⚠️  N+1 DETECTED: UserService.getUsersWithOrders()
    Problem: orders collection loaded lazily inside a loop (line 42)
    Fix:
      Option A — @EntityGraph on the repository method:
        @EntityGraph(attributePaths = {"orders"})
        List<User> findAll();

      Option B — JOIN FETCH in JPQL:
        @Query("SELECT u FROM User u JOIN FETCH u.orders")
        List<User> findAllWithOrders();
```

### Fetch Strategy Review
- Flag `FetchType.EAGER` on `@OneToMany` / `@ManyToMany` — always wrong
- Flag missing `@BatchSize` when lazy collections will be accessed in loops
- Suggest `@EntityGraph` for use-case-specific eager loading without global EAGER

### Projection Usage
Check if entities are returned where only a subset of fields is needed:
```
💡  PROJECTION OPPORTUNITY: UserRepository.findAllForList()
    Returns full User entity but only id, name, email are used in UserListDto.
    Fix: Use an interface projection or record projection (Java 16+):

    // Interface projection (Java 8+)
    public interface UserSummary {
        Long getId();
        String getName();
        String getEmail();
    }
    List<UserSummary> findAllBy();

    // Record projection (Java 16+, Spring Boot 2.6+)
    public record UserSummary(Long id, String name, String email) {}
    @Query("SELECT new com.example.UserSummary(u.id, u.name, u.email) FROM User u")
    List<UserSummary> findAllSummaries();
```

### Specification / Criteria API
If dynamic queries are constructed with string concatenation or if/else JPQL building:
```
💡  SPECIFICATION OPPORTUNITY: ProductRepository
    Dynamic query built with string concatenation is brittle and not type-safe.
    Fix: Use JpaSpecificationExecutor<Product> + Specification<Product>:

    public static Specification<Product> hasCategory(String category) {
        return (root, query, cb) ->
            category == null ? null : cb.equal(root.get("category"), category);
    }
    public static Specification<Product> priceBetween(BigDecimal min, BigDecimal max) {
        return (root, query, cb) ->
            cb.between(root.get("price"), min, max);
    }
    // Usage:
    repo.findAll(hasCategory(cat).and(priceBetween(min, max)));
```

### Transaction Boundaries
- Flag `@Transactional` on controller methods — belongs at service layer only
- Flag `@Transactional(readOnly = true)` missing on read-only service methods (enables Hibernate optimizations)
- Flag calling a `@Transactional` method from within the same bean (self-invocation bypasses proxy)
- Flag long transactions that include external HTTP calls or file I/O

### Entity Design
- Flag mutable `List`/`Set` fields without `@Column(nullable = false)` / proper constraints
- Flag missing `equals()` and `hashCode()` on entities used in Sets or as Map keys
- Flag `@GeneratedValue(strategy = GenerationType.AUTO)` — prefer `IDENTITY` (MySQL/PostgreSQL) or `SEQUENCE` for performance
- Flag bidirectional relationships without the owning side's `mappedBy` set correctly

### Pagination
- Flag `findAll()` without `Pageable` when the table could be large
- Suggest `Page<T>` vs `Slice<T>` (use Slice when total count is not needed — avoids COUNT query)

### Native Queries
- Flag native `@Query` with `nativeQuery = true` when JPQL would suffice
- Flag string-interpolated table/column names in native queries (SQL injection risk)

## Step 4 — Output

Produce a structured report:

```
## JPA Review — [ClassName or scope]

### Critical Issues
[N+1 problems, missing transactions on writes]

### Performance Improvements
[Fetch strategies, projections, pagination]

### Design Suggestions
[Entity design, Specifications, equals/hashCode]

### Minor Notes
[readOnly transactions, GenerationType, etc.]

### Summary
X critical · Y performance · Z design · W minor
```

For each issue include: what was found, why it matters, and the exact fix with code.

## Step 5 — Next Steps

After the report, offer:
- *"Run `/java-performance` for a broader performance review including non-JPA issues"*
- *"Use the `java-performance-reviewer` agent for an in-depth performance analysis"*
- *"Run `/java-review` for general code quality review"*
