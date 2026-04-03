---
description: Generate a meaningful git commit message based on the Java files changed
argument-hint: "[leave empty to use git diff, or describe the change]"
---

Generate a git commit message for the current Java changes. Use the Conventional Commits format tailored to Java/Spring projects.

## Step 1 — Gather context
Run (or ask Claude to run): `git diff --staged --stat` to see which files changed.
If nothing is staged, check `git diff --stat` for unstaged changes.

## Step 2 — Analyse the changes
Based on the changed files, determine:
- **Type of change**: feat, fix, refactor, test, docs, chore, perf, security
- **Scope**: the Java package, module, or layer affected (e.g., `service`, `controller`, `repository`, `security`)
- **What changed**: specific class names, method names, or behaviours

## Step 3 — Generate commit message

Use this format:
```
<type>(<scope>): <imperative summary under 72 chars>

[optional body — what changed and why, not how]

[optional footer — breaking changes, issue references]
```

### Java-specific type rules:
- `feat`: new class, method, endpoint, or feature
- `fix`: bug fix in logic, null check, exception handling
- `refactor`: extract method, rename, restructure — no behaviour change
- `perf`: N+1 fix, index added, caching, virtual threads
- `test`: new or updated JUnit/Mockito/Testcontainers tests
- `security`: OWASP fix, auth change, secret handling improvement
- `chore`: dependency update, build config, version bump

### Java-specific scope examples:
- `user-service`, `order-controller`, `payment-repository`
- `auth`, `security`, `jpa`, `api`, `dto`
- `pom`, `gradle`, `ci`

### Examples:
```
feat(user-service): add findByEmail with case-insensitive search

Adds UserService.findByEmail() using Spring Data derived query.
Returns Optional<User> to handle missing users without null checks.
```
```
fix(order-controller): return 404 when order not found instead of 500

Previously threw NullPointerException when order ID did not exist.
Now throws ResourceNotFoundException mapped to 404 by GlobalExceptionHandler.
```
```
perf(product-repository): fix N+1 query with @EntityGraph on findAll

Each product was triggering a separate query for its category.
Added @EntityGraph(attributePaths = "category") to load in one JOIN.
```
```
refactor(auth-service): replace field injection with constructor injection

Removes @Autowired field injection on JwtTokenProvider and UserDetailsService.
Constructor injection makes dependencies explicit and improves testability.
```

## Step 4 — Output
Provide:
1. The commit message (ready to copy)
2. The git command: `git commit -m "$(cat <<'EOF'\n[message]\nEOF\n)"`

If multiple logical changes are staged together, suggest splitting into separate commits.
