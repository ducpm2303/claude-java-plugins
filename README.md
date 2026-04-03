# Java Plugins for Claude Code

A Claude Code plugin marketplace with 5 independently installable plugins for Java developers.

## Plugins

| Plugin | Skills | Agents | Description |
|---|---|---|---|
| `java-core` | `/java-review`, `/java-refactor`, `/java-explain`, `/java-fix`, `/java-docs`, `/java-health`, `/java-concurrency-review`, `/java-api-review`, `/java-migrate`, `/java-commit`, `/java-solid`, `/java-design-pattern` | `java-architect`, `java-build-resolver` | General Java — code review, refactoring, explanation, fix, docs, health scoring, concurrency, API design, migration, commits, SOLID, design patterns |
| `java-spring` | `/java-scaffold`, `/java-jpa`, `/java-logging`, `/java-crud` | `java-spring-expert` | Spring Boot — scaffolding, JPA review, logging review, CRUD generation |
| `java-security` | — | `java-security-reviewer` | Security — OWASP Top 10 review and hooks |
| `java-testing` | `/java-test` | `java-test-engineer` | Testing — test generation and strategy |
| `java-performance` | — | `java-performance-reviewer` | Performance — N+1, memory, threading review |

All plugins support **Java 8 through Java 21** and tailor advice to your target Java version.

## Installation

### Step 1 — Add the marketplace

```shell
/plugin marketplace add ducpm2303/claude-java-plugins
```

This registers the marketplace once. Claude Code will fetch the plugin catalog from `https://github.com/ducpm2303/claude-java-plugins`.

### Step 2 — Install plugins

Install only what you need:

```shell
/plugin install java-core@java-plugins
/plugin install java-spring@java-plugins
/plugin install java-security@java-plugins
/plugin install java-testing@java-plugins
/plugin install java-performance@java-plugins
```

Or install the full suite at once:

```shell
/plugin install java-core@java-plugins && \
/plugin install java-spring@java-plugins && \
/plugin install java-security@java-plugins && \
/plugin install java-testing@java-plugins && \
/plugin install java-performance@java-plugins
```

### Step 3 — Verify installation

```shell
/plugin list
```

You should see all installed java-* plugins listed.

### Updating

To get the latest plugin versions:

```shell
/plugin marketplace update java-plugins
```

## Usage

### Skills (slash commands)
| Command | Plugin | What it does |
|---|---|---|
| `/java-review` | `java-core` | Review Java code for bugs, naming issues, and version-appropriate idioms |
| `/java-refactor` | `java-core` | Suggest and apply version-gated refactorings |
| `/java-explain` | `java-core` | Explain Java code in plain language |
| `/java-fix` | `java-core` | Diagnose compile errors or stack traces |
| `/java-docs` | `java-core` | Generate Javadoc for classes and methods |
| `/java-health` | `java-core` | Score codebase across Security, Tests, Performance, Quality (A–F grades) |
| `/java-concurrency-review` | `java-core` | Review thread safety, race conditions, and Java 21 virtual thread compatibility |
| `/java-api-review` | `java-core` | Review REST API design — HTTP methods, status codes, naming, versioning |
| `/java-migrate` | `java-core` | Interactive migration guide: Java 8→11, 11→17, or 17→21 |
| `/java-commit` | `java-core` | Generate a Conventional Commits message for staged Java changes |
| `/java-solid` | `java-core` | Check all 5 SOLID principles with Java-specific patterns |
| `/java-design-pattern` | `java-core` | Detect GoF patterns in code or recommend a pattern for a problem |
| `/java-scaffold` | `java-spring` | Scaffold a Spring Boot project or feature |
| `/java-jpa` | `java-spring` | Deep JPA review — N+1 queries, fetch strategies, projections, Specifications |
| `/java-logging` | `java-spring` | Review logging — SLF4J best practices, MDC, structured logging, PII safety |
| `/java-crud` | `java-spring` | Generate a complete CRUD feature (entity, repo, service, controller, DTOs, tests) |
| `/java-test` | `java-testing` | Generate JUnit 5 + Mockito unit or Testcontainers integration tests |

### Agents
Agents are specialist sub-agents Claude can delegate to. Reference them by name in conversation:
- *"Ask the java-architect agent to design a package structure for this domain"*
- *"Use the java-security-reviewer agent to check this controller for OWASP vulnerabilities"*
- *"Have the java-test-engineer agent write a test strategy for this service"*

## Adding a new ecosystem plugin (for contributors)

1. Create `plugins/java-<ecosystem>/` following the same structure as an existing plugin
2. Add an entry to `.claude-plugin/marketplace.json`
3. Bump the marketplace `version` field
4. Open a PR

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=ducpm2303/claude-java-plugins&type=Date)](https://star-history.com/#ducpm2303/claude-java-plugins&Date)

## Requirements

- Claude Code CLI installed and configured
- Git (for marketplace installation from GitHub)
