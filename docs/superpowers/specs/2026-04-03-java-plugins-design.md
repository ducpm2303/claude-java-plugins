# Java Plugins Marketplace — Design Spec

**Date:** 2026-04-03  
**Status:** Approved  
**Scope:** v1.0 — Spring Boot + General Java; extensible to Android, Quarkus, Micronaut in future releases

---

## Overview

A Claude Code plugin marketplace hosted as a GitHub monorepo. Users add the marketplace once and install individual plugins as needed. Each plugin targets a specific Java concern (core conventions, Spring Boot, security, testing, performance). All plugins are Java 8+ aware — suggestions are version-gated and tailored to the user's declared or detected Java version.

---

## Repository Structure

```
java-plugins/                          ← GitHub repo root (marketplace)
├── .claude-plugin/
│   └── marketplace.json               ← catalog of all plugins
├── plugins/
│   ├── java-core/                     ← general Java skills + rules
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── java-review/SKILL.md
│   │   │   ├── java-refactor/SKILL.md
│   │   │   ├── java-explain/SKILL.md
│   │   │   ├── java-fix/SKILL.md
│   │   │   └── java-docs/SKILL.md
│   │   ├── agents/
│   │   │   └── java-architect.md
│   │   ├── hooks/hooks.json
│   │   └── CLAUDE.md
│   │
│   ├── java-spring/                   ← Spring Boot skills + agent
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   └── java-scaffold/SKILL.md
│   │   ├── agents/
│   │   │   └── java-spring-expert.md
│   │   └── CLAUDE.md
│   │
│   ├── java-security/                 ← security agent + hooks
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/
│   │   │   └── java-security-reviewer.md
│   │   ├── hooks/hooks.json
│   │   └── CLAUDE.md
│   │
│   ├── java-testing/                  ← test skill + agent
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   └── java-test/SKILL.md
│   │   ├── agents/
│   │   │   └── java-test-engineer.md
│   │   └── CLAUDE.md
│   │
│   └── java-performance/              ← performance agent + hooks
│       ├── .claude-plugin/plugin.json
│       ├── agents/
│       │   └── java-performance-reviewer.md
│       └── CLAUDE.md
│
├── README.md
└── docs/
    └── superpowers/specs/
```

### Installation

```shell
/plugin marketplace add your-github/java-plugins
/plugin install java-core@java-plugins
/plugin install java-spring@java-plugins
/plugin install java-security@java-plugins
/plugin install java-testing@java-plugins
/plugin install java-performance@java-plugins
```

---

## Marketplace File

`.claude-plugin/marketplace.json`:

```json
{
  "name": "java-plugins",
  "owner": { "name": "Your Name" },
  "metadata": { "description": "Java developer toolkit for Claude Code — Spring Boot, security, testing, and performance" },
  "plugins": [
    { "name": "java-core",        "source": "./plugins/java-core",        "description": "General Java skills, architect agent, and coding standards" },
    { "name": "java-spring",      "source": "./plugins/java-spring",      "description": "Spring Boot scaffold skill and Spring expert agent" },
    { "name": "java-security",    "source": "./plugins/java-security",    "description": "Java security reviewer agent and post-edit security hooks" },
    { "name": "java-testing",     "source": "./plugins/java-testing",     "description": "Java test generation skill and test engineer agent" },
    { "name": "java-performance", "source": "./plugins/java-performance", "description": "Java performance reviewer agent" }
  ]
}
```

---

## Skills

All skills are Java 8+ aware. Each SKILL.md instructs Claude to:
1. Detect or ask for the Java version (from `pom.xml`, `build.gradle`, or user input)
2. Tailor all suggestions to that version
3. When a newer idiom is available, mention it and state the minimum Java version required

### java-core skills

| Command | File | Purpose |
|---|---|---|
| `/java-review` | `skills/java-review/SKILL.md` | Review selected Java code for bugs, code smells, naming issues, and version-appropriate idioms |
| `/java-refactor` | `skills/java-refactor/SKILL.md` | Suggest and apply refactorings: extract method, simplify streams, modernize syntax (version-gated) |
| `/java-explain` | `skills/java-explain/SKILL.md` | Explain selected Java code in plain language, including any design patterns used |
| `/java-fix` | `skills/java-fix/SKILL.md` | Diagnose compile errors or stack traces and propose a fix |
| `/java-docs` | `skills/java-docs/SKILL.md` | Generate Javadoc for selected classes and methods |

### java-spring skills

| Command | File | Purpose |
|---|---|---|
| `/java-scaffold` | `skills/java-scaffold/SKILL.md` | Scaffold a Spring Boot project or feature (asks for Java version, Spring Boot version, and desired layers) |

### java-testing skills

| Command | File | Purpose |
|---|---|---|
| `/java-test` | `skills/java-test/SKILL.md` | Generate JUnit 5 + Mockito unit tests and/or Testcontainers integration tests for selected code |

---

## Agents

Each agent `.md` file contains a frontmatter description and a detailed system prompt. All agents are Java 8+ version-aware.

| Agent | Plugin | File | Expertise |
|---|---|---|---|
| `java-architect` | `java-core` | `agents/java-architect.md` | System design, class hierarchies, Maven/Gradle structure, design patterns |
| `java-spring-expert` | `java-spring` | `agents/java-spring-expert.md` | Spring Boot, Spring Data JPA, Spring Security, Spring AI, REST API design |
| `java-security-reviewer` | `java-security` | `agents/java-security-reviewer.md` | OWASP Top 10 for Java, injection attacks, Spring Security misconfigs, secret handling |
| `java-performance-reviewer` | `java-performance` | `agents/java-performance-reviewer.md` | N+1 queries, memory leaks, thread safety, inefficient collections, JVM tuning hints |
| `java-test-engineer` | `java-testing` | `agents/java-test-engineer.md` | JUnit 5, Mockito, Testcontainers, test coverage strategy, mocking vs integration trade-offs |

---

## Hooks

Hooks are reminder-style (echo commands injecting context into Claude), keeping them safe and cross-platform.

### java-core hooks (`plugins/java-core/hooks/hooks.json`)

| Event | Matcher | Action |
|---|---|---|
| `PostToolUse` | `Write\|Edit` on `*.java` | Remind Claude to suggest running `mvn compile` or `./gradlew build` |
| `PostToolUse` | `Write\|Edit` on `*.java` | Remind Claude to check if tests exist for the modified class |
| `PostToolUse` | `Bash` matching `git commit` | Remind Claude to check code quality before committing |
| `PostToolUse` | `Bash` matching `mvn\|gradle` | If output contains failure keywords, remind Claude to invoke `/java-fix` |

### java-security hooks (`plugins/java-security/hooks/hooks.json`)

| Event | Matcher | Action |
|---|---|---|
| `PostToolUse` | `Write\|Edit` on `*.java` | Remind Claude to flag security concerns or delegate to `java-security-reviewer` |

---

## CLAUDE.md Rules

### java-core/CLAUDE.md — Java conventions & idioms
- Naming: `camelCase` methods/variables, `PascalCase` classes, `SCREAMING_SNAKE_CASE` constants
- Always state minimum Java version when suggesting version-gated features:
  - `var` → Java 10+
  - Text blocks → Java 15+
  - Records → Java 16+
  - Sealed classes / pattern matching → Java 17+
- Prefer immutability: `final` fields, unmodifiable collections
- Use streams and lambdas where they improve clarity (Java 8+)
- Avoid raw types; always parameterize generics

### java-spring/CLAUDE.md — Spring Boot best practices
- Always use constructor injection; never field injection with `@Autowired`
- Layered architecture: Controller → Service → Repository; no cross-layer skipping
- Use `@Transactional` at service layer only, never at controller layer
- Externalize config to `application.yml`; never hardcode values
- Return `ResponseEntity` for REST endpoints; use proper HTTP status codes

### java-security/CLAUDE.md — Security defaults
- Never log passwords, tokens, or PII
- Validate and sanitize all user input at controller boundaries
- Use parameterized queries / Spring Data; never string-concatenated SQL
- Store secrets in environment variables or Spring Vault; never in source code
- Flag use of `MD5` or `SHA-1` for passwords; require `BCrypt` or `Argon2`

### java-testing/CLAUDE.md — Testing standards
- Test method naming: `methodName_stateUnderTest_expectedBehavior`
- Follow AAA pattern (Arrange, Act, Assert); one assertion concept per test
- Prefer Testcontainers over H2 for database integration tests
- Mock external dependencies; never mock the class under test
- Aim for 80%+ line coverage on service layer

### java-performance/CLAUDE.md — Performance defaults
- Flag any JPA `@OneToMany` / `@ManyToMany` without `FetchType.LAZY`
- Flag loops that make DB calls; suggest batch operations
- Prefer `StringBuilder` over `String` concatenation in loops
- Flag `synchronized` on entire methods where fine-grained locking suffices

---

## Extensibility

To add a new Java ecosystem (Android, Quarkus, Micronaut, etc.):
1. Create `plugins/java-<ecosystem>/` with the same structure
2. Add an entry to `.claude-plugin/marketplace.json`
3. Bump marketplace version

No changes needed to existing plugins.

---

## Version Strategy

- Each plugin is independently versioned in its `plugin.json`
- Marketplace version tracks catalog changes only
- Semantic versioning: `MAJOR.MINOR.PATCH`
  - MAJOR: breaking changes to skill/agent interface
  - MINOR: new skills, agents, or hooks added
  - PATCH: prompt improvements, bug fixes

---

## Success Criteria

- [ ] All 7 skills work correctly across Java 8, 11, 17, and 21
- [ ] All 5 agents provide version-appropriate advice
- [ ] Hooks fire correctly on `.java` file edits and `mvn`/`gradle` commands
- [ ] CLAUDE.md rules are injected into context when plugins are active
- [ ] Marketplace installs cleanly from GitHub
- [ ] Each plugin can be installed independently without the others
