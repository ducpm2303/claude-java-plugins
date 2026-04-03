# Java Plugins for Claude Code

A Claude Code plugin marketplace with 3 focused plugins for Java developers. All plugins support **Java 8 through Java 21** and tailor advice to your target Java version.

## Plugins

| Plugin | Skills | Agents | Install when |
|---|---|---|---|
| `java-core` | 13 skills | `java-architect`, `java-build-resolver` | Every Java project |
| `java-spring` | 4 skills | `java-spring-expert` | Spring Boot projects |
| `java-quality` | 3 skills | `java-security-reviewer`, `java-performance-reviewer`, `java-test-engineer` | Quality enforcement |

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

## Skills (slash commands)

### java-core

| Command | What it does |
|---|---|
| `/java-review` | Review Java code for bugs, naming issues, and version-appropriate idioms |
| `/java-refactor` | Suggest and apply version-gated refactorings |
| `/java-explain` | Explain Java code in plain language |
| `/java-fix` | Diagnose compile errors or stack traces |
| `/java-docs` | Generate Javadoc for classes and methods |
| `/java-health` | Structural health score across Security, Tests, Performance, Quality (A–F) |
| `/java-concurrency-review` | Review thread safety, race conditions, and Java 21 virtual thread compatibility |
| `/java-api-review` | Review REST API design — HTTP methods, status codes, naming, versioning |
| `/java-migrate` | Interactive migration guide: Java 8→11, 11→17, or 17→21 |
| `/java-commit` | Generate a Conventional Commits message for staged Java changes |
| `/java-solid` | Check all 5 SOLID principles with Java-specific patterns |
| `/java-design-pattern` | Detect GoF patterns in code or recommend a pattern for a problem |
| `/java-adr` | Create, list, and manage Architecture Decision Records |

### java-spring

| Command | What it does |
|---|---|
| `/java-scaffold` | Scaffold a brand-new Spring Boot project (2.7.x – 4.0.x) |
| `/java-jpa` | Deep JPA review — N+1 queries, fetch strategies, projections, Specifications |
| `/java-logging` | Review logging — SLF4J, MDC, structured logging, PII safety |
| `/java-crud` | Generate a complete CRUD feature in an existing project |

### java-quality

| Command | What it does |
|---|---|
| `/java-security-check` | Quick OWASP scan — secrets, injection, weak crypto, Spring Security misconfigs |
| `/java-perf-check` | Quick performance scan — N+1, memory, threading, algorithmic hotspots |
| `/java-test` | Generate JUnit 5 + Mockito unit or Testcontainers integration tests (auto-detects project) |

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

## Contributing

1. Create `plugins/java-<ecosystem>/` following the same structure as an existing plugin
2. Add an entry to `.claude-plugin/marketplace.json`
3. Bump the marketplace `version` field
4. Open a PR

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=ducpm2303/claude-java-plugins&type=Date)](https://star-history.com/#ducpm2303/claude-java-plugins&Date)

## Requirements

- Claude Code CLI installed and configured
- Git (for marketplace installation from GitHub)
