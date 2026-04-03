# Contributing to claude-java-plugins

Thank you for contributing. This guide covers how to add or improve skills, agents, commands, rules, and hooks.

---

## Plugin Overview

| Plugin | Purpose |
|--------|---------|
| `java-core` | General Java skills, architect agent, build-resolver agent, coding standards |
| `java-spring` | Spring Boot skills, Spring expert agent |
| `java-quality` | Security, performance, and testing skills + specialist agents |

---

## Skill Authoring Guide

### File location

```
plugins/<plugin-name>/skills/<skill-name>/SKILL.md
```

### Required frontmatter

```markdown
---
description: <verb phrase describing what it does and when to invoke it>. Use when user asks to "<trigger phrase 1>", "<trigger phrase 2>", or "<trigger phrase 3>".
argument-hint: "<EntityName> [optional args]"
allowed-tools: Read, Grep, Glob     # only for read-only skills
---
```

### Description guidelines

- Start with a **verb** in third person: "Reviews", "Generates", "Analyzes"
- Include 3–5 natural language trigger phrases after "Use when user asks to"
- Keep under 200 characters

### Skill structure

1. **Heading** — `# /skill-name — Short Title`
2. **Persona line** — one sentence describing the role
3. **Numbered steps** — one step per logical phase
4. **Version-gated blocks** — prefix version-specific advice with `(Java X+:)` or `(Spring Boot X+:)`
5. **Next Steps** — cross-link to related skills

### Templates in `references/`

For skills with large code templates, split them:
- `SKILL.md` — instructions and steps only (keep under 80 lines)
- `references/templates.md` — reusable code templates

Reference from SKILL.md: `Use the templates in references/templates.md`

### Java version awareness

Always check the detected Java version before making version-specific suggestions. State the minimum required version in brackets: `(Java 16+)`, `(Spring Boot 3.x)`.

---

## Rule Authoring Guide

### File location

```
plugins/<plugin-name>/rules/<topic>.md
```

### Required frontmatter

```markdown
---
globs: ["**/*Controller.java"]
---
```

- Use the most specific glob possible — `**/*Controller.java` is better than `**/*.java`
- Rules activate automatically when a file matching the glob is in context

### Rule content

- Focused on one concern (naming, structure, security)
- Include concrete examples (bad → good code pairs where helpful)
- Flag anti-patterns explicitly so Claude knows what to look for

---

## Command Authoring Guide

### File location

```
plugins/<plugin-name>/commands/<command-name>.md
```

### Required frontmatter

```markdown
---
description: <what the command does, one sentence>
---
```

### When to add a command vs a skill

| Use a **command** when | Use a **skill** when |
|---|---|
| Explicitly triggered only (`/java-core:build`) | Can auto-invoke from context |
| Orchestrates multiple steps or shell commands | Provides passive domain knowledge |
| Produces a structured artifact (report, table) | Guides Claude's behavior inline |

---

## Agent Authoring Guide

### File location

```
plugins/<plugin-name>/agents/<agent-name>.md
```

### Structure

```markdown
---
description: One-sentence role description
---

# Agent Name

You are a <role>. Your focus is <domain>.

## Expertise
- Area 1
- Area 2

## Behavior
1. ...
2. ...

## Response Format
...
```

---

## Testing Your Changes

Before submitting a PR:

1. **Validate** — run the validation script:
   ```bash
   ./scripts/validate-plugins.sh
   ```

2. **Install locally** and test the skill or command:
   ```bash
   claude --plugin-dir ./plugins/java-core
   ```

3. **Check that the skill description triggers correctly** — the `description` field controls auto-invocation

---

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(java-core): add /java-core:lint command
fix(java-spring): correct entity-conventions glob pattern
docs: add CONTRIBUTING guide
chore: bump versions to v2.3.0
```

---

## Pull Request Checklist

- [ ] Skill description starts with a verb and includes trigger phrases
- [ ] Version-specific content is gated with `(Java X+:)` or `(Spring Boot X+:)`
- [ ] Large templates are in `references/templates.md`, not inline
- [ ] Rules use the most specific `globs:` pattern possible
- [ ] Validation script passes
- [ ] Tested locally with `claude --plugin-dir`
