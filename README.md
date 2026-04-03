# Java Plugins for Claude Code

A Claude Code plugin marketplace with 5 independently installable plugins for Java developers.

## Plugins

| Plugin | Skills | Agents | Description |
|---|---|---|---|
| `java-core` | `/java-review`, `/java-refactor`, `/java-explain`, `/java-fix`, `/java-docs` | `java-architect` | General Java — code review, refactoring, explanation, fix, docs |
| `java-spring` | `/java-scaffold` | `java-spring-expert` | Spring Boot — scaffolding and expert guidance |
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
| Command | What it does |
|---|---|
| `/java-review` | Review Java code for bugs, naming issues, and version-appropriate idioms |
| `/java-refactor` | Suggest and apply version-gated refactorings |
| `/java-explain` | Explain Java code in plain language |
| `/java-fix` | Diagnose compile errors or stack traces |
| `/java-docs` | Generate Javadoc for classes and methods |
| `/java-scaffold` | Scaffold a Spring Boot project or feature |
| `/java-test` | Generate JUnit 5 + Mockito unit or Testcontainers integration tests |

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

## Requirements

- Claude Code CLI installed and configured
- Git (for marketplace installation from GitHub)
