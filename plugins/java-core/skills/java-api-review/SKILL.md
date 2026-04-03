---
description: Review Java REST API design — HTTP status codes, naming, pagination, versioning, error responses, and validation
argument-hint: "[paste controller or API code]"
---

Review the REST API design of the provided Java controller or endpoint code. Detect Spring Boot version from `pom.xml` to tailor advice.

## Step 1 — HTTP method and status code correctness
- `GET` must be idempotent and return `200 OK` (or `404` if not found) — never `201`
- `POST` for creation → return `201 Created` with `Location` header pointing to the new resource
- `PUT` for full replacement → `200 OK` or `204 No Content`
- `PATCH` for partial update → `200 OK` with updated resource or `204 No Content`
- `DELETE` → `204 No Content` (not `200` with body)
- Flag returning `200 OK` with `null` body when resource not found → must be `404`
- Flag returning `200 OK` for all errors → each error needs an appropriate 4xx/5xx code

## Step 2 — URL naming conventions
- Use plural nouns for resources: `/users` not `/user`, `/orders` not `/getOrders`
- Use kebab-case for multi-word paths: `/user-profiles` not `/userProfiles`
- Flag verbs in URLs: `/getUser`, `/createOrder`, `/deleteItem` → use HTTP method instead
- Nested resources: `/users/{userId}/orders` — max 2 levels deep; beyond that use query params
- Flag `/api/v1/users` inconsistency — version should be consistent across all endpoints

## Step 3 — Request/response design
- Flag endpoints returning raw entity classes (`@Entity`) directly → use DTOs
- Flag missing `@Valid` on `@RequestBody` parameters → no input validation
- Flag `@RequestBody Map<String, Object>` → use typed DTOs instead
- Flag missing pagination on list endpoints that could return large datasets → add `Pageable`
- Flag response bodies that differ in structure between success and error cases → standardize

## Step 4 — Error response format
Recommend a consistent error response format:
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "status": 400,
  "error": "Validation Failed",
  "message": "name must not be blank",
  "path": "/api/users"
}
```
Flag endpoints returning plain strings or stack traces as error responses.

## Step 5 — API versioning
- Flag no versioning on public APIs → suggest URL versioning (`/api/v1/`) or header versioning
- Flag breaking changes in existing versioned endpoints (removing fields, changing types)

## Step 6 — Security basics
- Flag endpoints missing `@PreAuthorize` or security config that should be protected
- Flag sensitive data (passwords, tokens, SSN) returned in responses
- Flag `@CrossOrigin(origins = "*")` on production endpoints

## Output format
1. **Summary** — overall API quality assessment
2. **Issues** by severity: 🔴 Critical / 🟡 Warning / 🔵 Suggestion
3. **Each issue**: endpoint + problem + corrected code

## Next Steps
- For security findings → ask `java-security-reviewer` agent for full OWASP review
- For missing tests → run `/java-test` to generate controller tests with MockMvc
