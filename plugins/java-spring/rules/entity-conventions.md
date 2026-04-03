---
globs: ["**/*Entity.java", "**/entity/*.java", "**/domain/*.java"]
---

# JPA Entity Conventions

Apply these rules whenever editing or reviewing JPA entity files.

## Class Annotations
- `@Entity` is required
- `@Table(name = "table_name")` — use snake_case table names; do not rely on the default JPA name derivation
- Spring Boot 3.x: `jakarta.persistence.*` | Spring Boot 2.x: `javax.persistence.*`

## Primary Key
- Use `@Id` + `@GeneratedValue(strategy = GenerationType.IDENTITY)` for auto-increment PKs
- Prefer `Long` over `int`/`Integer` for IDs
- Never expose the PK strategy in DTOs sent to clients

## Fetch Types
- `@OneToMany` and `@ManyToMany` must use `FetchType.LAZY` — never `EAGER` (causes N+1 and cartesian explosions)
- `@ManyToOne` defaults to `EAGER` — keep it, it's a single JOIN and safe
- `@OneToOne` → prefer `LAZY` when the association is not always needed

## Auditing
- Add `createdAt` and `updatedAt` timestamps:
  - Use `@PrePersist` / `@PreUpdate` callbacks, or
  - Use Spring Data `@CreatedDate` / `@LastModifiedDate` with `@EnableJpaAuditing`
- Mark `createdAt` as `updatable = false`

## Soft Delete
- Add `deleted boolean` with `@Column(nullable = false)`
- Spring Boot 3.2+: `@SQLRestriction("deleted = false")` on the class
- Spring Boot 2.x: `@Where(clause = "deleted = false")`
- Provide a `softDelete()` method instead of exposing the field directly

## Equality
- Do not use Lombok `@EqualsAndHashCode` on JPA entities — implement based on the business key, not the ID
- Use `Objects.equals()` in `equals()` and avoid calling `getId()` in `hashCode()` before the entity is persisted
