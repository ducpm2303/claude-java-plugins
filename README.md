# Java Plugins for Claude Code

A Claude Code plugin marketplace with 3 focused plugins for Java developers. All plugins support **Java 8 through Java 21** and tailor advice to your target Java version.

## Plugins

| Plugin | Skills | Commands | Agents | Install when |
|---|---|---|---|---|
| `java-core` | 13 | 2 | `java-architect`, `java-build-resolver` | Every Java project |
| `java-spring` | 4 | 2 | `java-spring-expert` | Spring Boot projects |
| `java-quality` | 3 | 1 | `java-security-reviewer`, `java-performance-reviewer`, `java-test-engineer` | Quality enforcement |

## Installation

### Step 1 — Add the marketplace

```shell
/plugin marketplace add ducpm2303/claude-java-plugins
```

### Step 2 — Install plugins

```shell
/plugin install java-core@java-plugins       # every Java project
/plugin install java-spring@java-plugins     # Spring Boot projects
/plugin install java-quality@java-plugins    # security + performance + testing
```

### Updating

```shell
/plugin marketplace update java-plugins
```

---

## Skills (auto-invoked)

Skills activate automatically based on context, or invoke them explicitly.

### java-core

| Skill | What it does |
|---|---|
| `/java-core:java-review` | Review Java code for bugs, naming issues, and version-appropriate idioms |
| `/java-core:java-refactor` | Suggest and apply version-gated refactorings |
| `/java-core:java-explain` | Explain Java code in plain language |
| `/java-core:java-fix` | Diagnose compile errors or stack traces |
| `/java-core:java-docs` | Generate Javadoc for classes and methods |
| `/java-core:java-health` | Structural health score across Security, Tests, Performance, Quality (A–F) |
| `/java-core:java-concurrency-review` | Review thread safety, race conditions, and Java 21 virtual thread compatibility |
| `/java-core:java-api-review` | Review REST API design — HTTP methods, status codes, naming, versioning |
| `/java-core:java-migrate` | Interactive migration guide: Java 8→11, 11→17, or 17→21 |
| `/java-core:java-commit` | Generate a Conventional Commits message for staged Java changes |
| `/java-core:java-solid` | Check all 5 SOLID principles with Java-specific patterns |
| `/java-core:java-design-pattern` | Detect GoF patterns in code or recommend a pattern for a problem |
| `/java-core:java-adr` | Create, list, and manage Architecture Decision Records |

### java-spring

| Skill | What it does |
|---|---|
| `/java-spring:java-scaffold` | Scaffold a brand-new Spring Boot project (2.7.x – 4.0.x) |
| `/java-spring:java-jpa` | Deep JPA review — N+1 queries, fetch strategies, projections, Specifications |
| `/java-spring:java-logging` | Review logging — SLF4J, MDC, structured logging, PII safety |
| `/java-spring:java-crud` | Generate a complete CRUD feature in an existing project |

### java-quality

| Skill | What it does |
|---|---|
| `/java-quality:java-security-check` | Quick OWASP scan — secrets, injection, weak crypto, Spring Security misconfigs |
| `/java-quality:java-perf-check` | Quick performance scan — N+1, memory, threading, algorithmic hotspots |
| `/java-quality:java-test` | Generate JUnit 5 + Mockito unit or Testcontainers integration tests |

---

## Commands (explicit slash commands)

Commands are explicitly triggered workflows — builds, analysis runs, and reports.

### java-core

| Command | What it does |
|---|---|
| `/java-core:build` | Run a clean Maven/Gradle build and report test results or compile errors |
| `/java-core:check` | Run configured static analysis (Checkstyle, SpotBugs, PMD) and report findings |

### java-spring

| Command | What it does |
|---|---|
| `/java-spring:run` | Start the Spring Boot app locally with pre-flight checks (env vars, DB) |
| `/java-spring:routes` | Print a REST endpoint table scanned from all `@RestController` classes |

### java-quality

| Command | What it does |
|---|---|
| `/java-quality:audit` | Full quality audit: security + performance + test coverage in one combined report |

---

## Agents

Agents are specialist sub-agents Claude can delegate to:

| Agent | Plugin | Use for |
|---|---|---|
| `java-architect` | `java-core` | Project structure, hexagonal/layered architecture, multi-module Maven, design patterns |
| `java-build-resolver` | `java-core` | Fix Maven/Gradle/javac build errors with minimal changes |
| `java-spring-expert` | `java-spring` | Spring Boot best practices, Spring Data JPA, Spring Security, REST API design |
| `java-security-reviewer` | `java-quality` | Full OWASP Top 10 deep-dive, Spring Security misconfig, secrets audit |
| `java-performance-reviewer` | `java-quality` | Deep JPA/memory/threading performance analysis with before/after fixes |
| `java-test-engineer` | `java-quality` | Test strategy, coverage analysis, Testcontainers setup, PITest mutation testing |

**Example usage:**
- *"Ask the `java-architect` agent to design a hexagonal architecture for this order service"*
- *"Use the `java-security-reviewer` agent to do a full OWASP audit of this controller"*
- *"Have the `java-test-engineer` agent write a test strategy for this service layer"*

---

## Auto-activating Rules

Each plugin includes path-scoped rules that activate automatically when you open matching files — no manual invocation needed.

| Rule file | Activates for | Enforces |
|---|---|---|
| `java-core` naming-conventions | `**/*.java` | Class/method/variable/package naming |
| `java-core` project-structure | `**/pom.xml`, `**/build.gradle*` | Dependency scopes, version pinning, Java toolchain |
| `java-spring` controller-conventions | `**/*Controller.java` | `ResponseEntity` returns, `@Valid`, HTTP status codes |
| `java-spring` service-conventions | `**/*Service.java` | Constructor injection, `@Transactional(readOnly)`, DTO mapping |
| `java-spring` entity-conventions | `**/*Entity.java`, `**/entity/*.java` | Fetch types, auditing timestamps, soft delete, equality |
| `java-quality` security-rules | `**/*.java` | No secrets in logs, no SQL concat, input validation |
| `java-quality` test-conventions | `**/*Test.java`, `**/*IT.java` | AAA pattern, AssertJ, Testcontainers, naming |

---

## LSP Integration

`java-core` includes a `.lsp.json` configuring [Eclipse JDT Language Server (jdtls)](https://github.com/eclipse-jdtls/eclipse.jdt.ls) for real-time code intelligence:
- Diagnostics and type checking
- Auto import organization
- Inlay parameter hints
- Google Style formatting

**Install jdtls:**
```shell
brew install jdtls        # macOS
# or download from https://github.com/eclipse-jdtls/eclipse.jdt.ls/releases
```

---

## GitHub Actions — Automated PR Review

Use the same skills that run locally to automatically review every Java PR in CI.

### Quick setup

1. Copy [`templates/java-pr-review.yml`](templates/java-pr-review.yml) to `.github/workflows/java-pr-review.yml` in your Java project
2. Add `ANTHROPIC_API_KEY` to your repo secrets (Settings → Secrets → Actions)
3. Push — every PR touching `.java` or build files gets an automated review

### What gets reviewed

Every PR automatically checks:
- **Code quality** — naming, logic errors, null risks, resource leaks
- **Security** — OWASP Top 10, hardcoded secrets, SQL injection, missing `@Valid`
- **Performance** — N+1 queries, eager fetch on collections, missing pagination

Results are posted as a single structured comment with severity-coded findings.

### Our own CI

This repo runs `.github/workflows/validate.yml` on every push — it runs `validate-plugins.sh` and verifies version consistency across all plugin manifests.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for a full authoring guide covering skills, rules, commands, and agents.

Quick steps:
1. Follow the structure in an existing plugin
2. Run `./scripts/validate-plugins.sh` — must pass with zero errors
3. Add an entry to `.claude-plugin/marketplace.json`
4. Open a PR

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=ducpm2303/claude-java-plugins&type=Date)](https://star-history.com/#ducpm2303/claude-java-plugins&Date)

## Requirements

- Claude Code CLI installed and configured
- Git (for marketplace installation from GitHub)
- (Optional) [jdtls](https://github.com/eclipse-jdtls/eclipse.jdt.ls) for LSP code intelligence
