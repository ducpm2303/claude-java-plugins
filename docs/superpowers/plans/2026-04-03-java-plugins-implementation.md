# Java Plugins Marketplace Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Claude Code plugin marketplace monorepo with 5 independently installable plugins covering general Java, Spring Boot, security, testing, and performance — all Java 8+ version-aware.

**Architecture:** GitHub monorepo with a root marketplace catalog (`marketplace.json`) and one plugin per subdirectory under `plugins/`. Each plugin is self-contained with its own `plugin.json`, skills (`SKILL.md`), agents (`.md`), hooks (`hooks.json`), and `CLAUDE.md` rules. No shared code between plugins — each installs independently.

**Tech Stack:** Claude Code plugin system (markdown files, JSON manifests). No runtime dependencies. Validated with `claude plugin validate`.

---

## File Map

All 26 files to be created:

```
.claude-plugin/marketplace.json
plugins/java-core/.claude-plugin/plugin.json
plugins/java-core/CLAUDE.md
plugins/java-core/skills/java-review/SKILL.md
plugins/java-core/skills/java-refactor/SKILL.md
plugins/java-core/skills/java-explain/SKILL.md
plugins/java-core/skills/java-fix/SKILL.md
plugins/java-core/skills/java-docs/SKILL.md
plugins/java-core/agents/java-architect.md
plugins/java-core/hooks/hooks.json
plugins/java-spring/.claude-plugin/plugin.json
plugins/java-spring/CLAUDE.md
plugins/java-spring/skills/java-scaffold/SKILL.md
plugins/java-spring/agents/java-spring-expert.md
plugins/java-security/.claude-plugin/plugin.json
plugins/java-security/CLAUDE.md
plugins/java-security/agents/java-security-reviewer.md
plugins/java-security/hooks/hooks.json
plugins/java-testing/.claude-plugin/plugin.json
plugins/java-testing/CLAUDE.md
plugins/java-testing/skills/java-test/SKILL.md
plugins/java-testing/agents/java-test-engineer.md
plugins/java-performance/.claude-plugin/plugin.json
plugins/java-performance/CLAUDE.md
plugins/java-performance/agents/java-performance-reviewer.md
README.md
```

---

## Task 1: Scaffold directory structure and marketplace manifest

**Files:**
- Create: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Create all directories**

```bash
mkdir -p .claude-plugin
mkdir -p plugins/java-core/.claude-plugin
mkdir -p plugins/java-core/skills/java-review
mkdir -p plugins/java-core/skills/java-refactor
mkdir -p plugins/java-core/skills/java-explain
mkdir -p plugins/java-core/skills/java-fix
mkdir -p plugins/java-core/skills/java-docs
mkdir -p plugins/java-core/agents
mkdir -p plugins/java-core/hooks
mkdir -p plugins/java-spring/.claude-plugin
mkdir -p plugins/java-spring/skills/java-scaffold
mkdir -p plugins/java-spring/agents
mkdir -p plugins/java-security/.claude-plugin
mkdir -p plugins/java-security/agents
mkdir -p plugins/java-security/hooks
mkdir -p plugins/java-testing/.claude-plugin
mkdir -p plugins/java-testing/skills/java-test
mkdir -p plugins/java-testing/agents
mkdir -p plugins/java-performance/.claude-plugin
mkdir -p plugins/java-performance/agents
```

- [ ] **Step 2: Create `.claude-plugin/marketplace.json`**

```json
{
  "name": "java-plugins",
  "owner": {
    "name": "java-plugins contributors"
  },
  "metadata": {
    "description": "Java developer toolkit for Claude Code — general Java, Spring Boot, security, testing, and performance",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "java-core",
      "source": "./plugins/java-core",
      "description": "General Java skills (review, refactor, explain, fix, docs), architect agent, and Java coding standards",
      "version": "1.0.0",
      "keywords": ["java", "core", "review", "refactor"]
    },
    {
      "name": "java-spring",
      "source": "./plugins/java-spring",
      "description": "Spring Boot scaffold skill and Spring expert agent",
      "version": "1.0.0",
      "keywords": ["java", "spring", "spring-boot", "scaffold"]
    },
    {
      "name": "java-security",
      "source": "./plugins/java-security",
      "description": "Java security reviewer agent and post-edit security hooks",
      "version": "1.0.0",
      "keywords": ["java", "security", "owasp"]
    },
    {
      "name": "java-testing",
      "source": "./plugins/java-testing",
      "description": "Java test generation skill and test engineer agent",
      "version": "1.0.0",
      "keywords": ["java", "testing", "junit", "mockito"]
    },
    {
      "name": "java-performance",
      "source": "./plugins/java-performance",
      "description": "Java performance reviewer agent",
      "version": "1.0.0",
      "keywords": ["java", "performance", "jpa", "optimization"]
    }
  ]
}
```

- [ ] **Step 3: Validate marketplace JSON syntax**

```bash
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json')); print('marketplace.json: valid')"
```
Expected output: `marketplace.json: valid`

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "feat: add marketplace manifest with 5 plugin entries"
```

---

## Task 2: java-core — plugin manifest and CLAUDE.md rules

**Files:**
- Create: `plugins/java-core/.claude-plugin/plugin.json`
- Create: `plugins/java-core/CLAUDE.md`

- [ ] **Step 1: Create `plugins/java-core/.claude-plugin/plugin.json`**

```json
{
  "name": "java-core",
  "description": "General Java skills, architect agent, and coding standards for Java 8+",
  "version": "1.0.0",
  "author": {
    "name": "java-plugins contributors"
  },
  "keywords": ["java", "review", "refactor", "explain", "fix", "docs"],
  "hooks": "./hooks/hooks.json"
}
```

- [ ] **Step 2: Create `plugins/java-core/CLAUDE.md`**

```markdown
# Java Core — Coding Standards

These rules apply whenever the java-core plugin is active.

## Naming Conventions
- Classes and interfaces: `PascalCase` (e.g., `UserService`, `OrderRepository`)
- Methods and variables: `camelCase` (e.g., `getUserById`, `orderCount`)
- Constants: `SCREAMING_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- Packages: all lowercase, dot-separated (e.g., `com.example.service`)

## Java Version Awareness
Always detect the Java version from `pom.xml` (`<java.version>` or `<maven.compiler.source>`) or `build.gradle` (`sourceCompatibility`). If not found, ask the user before making version-specific suggestions.

When suggesting version-gated features, always state the minimum version required:
- Streams and lambdas: Java 8+
- `Optional`: Java 8+
- `var` (local type inference): Java 10+
- Text blocks (multi-line strings): Java 15+
- Records (immutable data classes): Java 16+
- Sealed classes and pattern matching: Java 17+
- Virtual threads (Project Loom): Java 21+

## Immutability
- Prefer `final` fields; only make fields mutable when mutation is required
- Use `Collections.unmodifiableList()` / `List.of()` (Java 9+) for collections that should not change
- Prefer returning copies of mutable collections from public methods

## Generics
- Never use raw types (e.g., use `List<String>` not `List`)
- Use bounded wildcards (`? extends T`, `? super T`) when appropriate

## Code Size
- Methods should do one thing; flag methods longer than 20 lines for extraction
- Classes should have one primary responsibility
- Avoid magic numbers and strings; extract to named constants

## Streams and Lambdas (Java 8+)
- Prefer streams over imperative loops when the intent is clearer
- Avoid side effects in stream operations
- Use method references (`Class::method`) over lambdas when equivalent
```

- [ ] **Step 3: Validate plugin.json**

```bash
python3 -c "import json; json.load(open('plugins/java-core/.claude-plugin/plugin.json')); print('plugin.json: valid')"
```
Expected: `plugin.json: valid`

- [ ] **Step 4: Commit**

```bash
git add plugins/java-core/.claude-plugin/plugin.json plugins/java-core/CLAUDE.md
git commit -m "feat(java-core): add plugin manifest and Java coding standards"
```

---

## Task 3: java-core — /java-review skill

**Files:**
- Create: `plugins/java-core/skills/java-review/SKILL.md`

- [ ] **Step 1: Create `plugins/java-core/skills/java-review/SKILL.md`**

```markdown
---
description: Review Java code for bugs, naming issues, code smells, and version-appropriate idioms
argument-hint: "[paste code or select in editor]"
---

Review the Java code I've selected or provided. Follow these steps:

## Step 1 — Detect Java version
Check the project for `pom.xml` (look for `<java.version>` or `<maven.compiler.source>`) or `build.gradle` (look for `sourceCompatibility`). If not found, ask: "What Java version are you targeting? (8, 11, 17, 21, or other)"

## Step 2 — Review for bugs and correctness
- **Null safety:** flag unguarded dereferences; suggest `Optional<T>` (Java 8+) for values that may be absent
- **Resource leaks:** flag unclosed `InputStream`, `Connection`, `PreparedStatement`; suggest try-with-resources
- **equals/hashCode:** if one is overridden without the other, flag it
- **Collection mutation:** flag modification of a collection while iterating over it
- **Thread safety:** flag shared mutable fields accessed from multiple threads without synchronization
- **Off-by-one:** review loop bounds and index access

## Step 3 — Review naming and style
- Classes/interfaces: must be `PascalCase`
- Methods/variables: must be `camelCase`
- Constants (static final): must be `SCREAMING_SNAKE_CASE`
- Flag single-letter variable names outside of loop counters (`i`, `j`, `k`)
- Flag abbreviations that reduce clarity (e.g., `usr` → `user`, `mgr` → `manager`)

## Step 4 — Review Java idioms (version-aware)
For each suggestion involving a version-gated feature, state: "Requires Java X+"
- Java 8+: suggest streams/lambdas over verbose imperative loops where clarity improves
- Java 8+: suggest try-with-resources for `Closeable` resources
- Java 10+: suggest `var` where the type is obvious from the right-hand side
- Java 16+: suggest records for classes that are pure data holders with no behaviour
- Java 17+: suggest sealed classes for fixed hierarchies; pattern matching for `instanceof` chains

## Step 5 — Review code smells
- Methods longer than 20 lines: suggest extracting to named helper methods
- Classes with more than one clear responsibility: suggest splitting
- Magic numbers/strings: suggest named constants
- Deep nesting (more than 3 levels): suggest early returns or extraction

## Output format
Respond with:
1. **Summary** — 1–2 sentences overall assessment
2. **Issues** — grouped by severity:
   - 🔴 **Critical** (bugs, resource leaks, thread safety)
   - 🟡 **Warning** (naming, missing equals/hashCode, raw types)
   - 🔵 **Suggestion** (idiom improvements, version-gated enhancements)
3. **Strengths** — what is done well (at least one observation)

Be concise. Each issue: one sentence description + one-line fix example.
```

- [ ] **Step 2: Validate SKILL.md has correct frontmatter**

```bash
python3 -c "
import re
content = open('plugins/java-core/skills/java-review/SKILL.md').read()
assert content.startswith('---'), 'Missing frontmatter'
assert 'description:' in content, 'Missing description field'
print('SKILL.md: valid frontmatter')
"
```
Expected: `SKILL.md: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-core/skills/java-review/SKILL.md
git commit -m "feat(java-core): add /java-review skill"
```

---

## Task 4: java-core — /java-refactor skill

**Files:**
- Create: `plugins/java-core/skills/java-refactor/SKILL.md`

- [ ] **Step 1: Create `plugins/java-core/skills/java-refactor/SKILL.md`**

```markdown
---
description: Suggest and apply version-appropriate refactorings to Java code
argument-hint: "[paste code or select in editor]"
---

Refactor the Java code I've selected or provided. Follow these steps:

## Step 1 — Detect Java version
Check `pom.xml` (`<java.version>` or `<maven.compiler.source>`) or `build.gradle` (`sourceCompatibility`). If not found, ask: "What Java version are you targeting? (8, 11, 17, 21, or other)"

## Step 2 — Apply safe refactorings (all Java versions)
These refactorings are safe regardless of Java version:
- **Extract method:** if a method is longer than 20 lines or has a distinct sub-step, extract it with a descriptive name
- **Rename for clarity:** rename variables, methods, or classes with unclear names
- **Remove duplication:** identify repeated logic blocks and extract to a shared method
- **Replace magic literals:** replace inline numbers/strings with named `static final` constants
- **Simplify conditionals:** replace nested if/else chains with early returns or ternary where clearer
- **Remove dead code:** delete unreachable branches, unused variables, unused imports

## Step 3 — Apply version-gated refactorings (only if target version supports it)
State the minimum Java version required for each suggestion:
- **Java 8+ — Replace anonymous classes with lambdas:** e.g., `new Comparator<String>() { ... }` → `(a, b) -> a.compareTo(b)`
- **Java 8+ — Replace imperative loops with streams:** e.g., for-each + list.add → `list.stream().filter(...).collect(Collectors.toList())`
- **Java 8+ — Use Optional instead of null returns:** e.g., `return null` → `return Optional.empty()`
- **Java 9+ — Use List.of / Map.of:** e.g., `new ArrayList<>(Arrays.asList(...))` → `List.of(...)`
- **Java 10+ — Use var for local variables:** where the type is obvious from the right-hand side
- **Java 16+ — Replace data classes with records:** e.g., a class with only final fields, a constructor, and getters → `record`
- **Java 17+ — Replace instanceof + cast chains with pattern matching:** e.g., `if (obj instanceof String) { String s = (String) obj; }` → `if (obj instanceof String s)`

## Output format
For each refactoring:
1. **What:** one sentence describing the change
2. **Why:** one sentence explaining the benefit
3. **Before:** the original code snippet
4. **After:** the refactored code snippet
5. **Java version required:** (e.g., "Java 8+" or "All versions")

Then offer: "Want me to apply these changes to the file?"
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-core/skills/java-refactor/SKILL.md').read()
assert content.startswith('---'), 'Missing frontmatter'
assert 'description:' in content
print('SKILL.md: valid frontmatter')
"
```
Expected: `SKILL.md: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-core/skills/java-refactor/SKILL.md
git commit -m "feat(java-core): add /java-refactor skill"
```

---

## Task 5: java-core — /java-explain skill

**Files:**
- Create: `plugins/java-core/skills/java-explain/SKILL.md`

- [ ] **Step 1: Create `plugins/java-core/skills/java-explain/SKILL.md`**

```markdown
---
description: Explain selected Java code in plain language, including design patterns and idioms used
argument-hint: "[paste code or select in editor]"
---

Explain the Java code I've selected or provided. Tailor the explanation to what the code actually does — avoid generic descriptions.

## What to cover

**1. Purpose (1–3 sentences)**
What is this code trying to accomplish? What problem does it solve?

**2. How it works — step by step**
Walk through the logic in plain English. For each significant block:
- What it does
- Why it does it that way
- Any non-obvious behaviour (e.g., side effects, exception handling, thread interactions)

**3. Java features used**
Identify and briefly explain any Java-specific features present:
- Generics, wildcards
- Streams and lambdas (and what the pipeline does)
- Optional chaining
- Annotations and their effect (e.g., `@Transactional`, `@Override`)
- Records, sealed classes, pattern matching (if Java 16+/17+)
- Concurrency primitives (`synchronized`, `volatile`, `AtomicInteger`, etc.)

**4. Design patterns (if present)**
If the code implements a recognisable design pattern (Factory, Builder, Strategy, Observer, Singleton, Repository, etc.), name it and explain how the code implements it.

**5. Potential gotchas**
Point out anything that a reader might misunderstand or that could cause subtle bugs:
- Unexpected null handling
- Order-dependent behaviour
- Mutable state shared across calls
- Performance implications (e.g., O(n²) loops, eager loading)

## Tone
Write as if explaining to a competent developer who is new to this particular codebase. Assume familiarity with basic Java but not with the specific patterns or domain logic shown.
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-core/skills/java-explain/SKILL.md').read()
assert content.startswith('---')
assert 'description:' in content
print('SKILL.md: valid frontmatter')
"
```
Expected: `SKILL.md: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-core/skills/java-explain/SKILL.md
git commit -m "feat(java-core): add /java-explain skill"
```

---

## Task 6: java-core — /java-fix skill

**Files:**
- Create: `plugins/java-core/skills/java-fix/SKILL.md`

- [ ] **Step 1: Create `plugins/java-core/skills/java-fix/SKILL.md`**

```markdown
---
description: Diagnose Java compile errors or stack traces and propose a targeted fix
argument-hint: "[paste error message or stack trace]"
---

Diagnose the Java error or stack trace I've provided and propose a fix. Be specific — do not give generic advice.

## Step 1 — Identify the error type

**Compile errors (javac / Maven / Gradle output):**
- `cannot find symbol` → missing import, misspelled name, or wrong scope
- `incompatible types` → type mismatch; check generics, autoboxing, widening
- `method X is not applicable` → wrong number or types of arguments
- `variable X might not have been initialized` → missing initialisation on all code paths
- `reached end of file while parsing` → unmatched `{` or `}`
- `class X is public, should be declared in a file named X.java` → filename mismatch

**Runtime exceptions (stack traces):**
- `NullPointerException` → identify the line; determine which reference is null; suggest a null check or Optional
- `ClassCastException` → show the actual vs expected type; fix the cast or use instanceof first
- `ArrayIndexOutOfBoundsException` → check loop bounds and array length
- `StackOverflowError` → identify the recursive call; check base case
- `ConcurrentModificationException` → iterating and modifying a collection simultaneously; suggest iterator.remove() or a copy
- `IllegalArgumentException` / `IllegalStateException` → read the message; check the API contract

## Step 2 — Find the root cause
Read the full error message carefully. The root cause is usually the last "Caused by:" in a stack trace. Show the user:
1. The exact line causing the error (if visible in the stack trace)
2. Why that line fails

## Step 3 — Propose the fix
Show:
1. The problematic code (before)
2. The corrected code (after)
3. One sentence explaining what was wrong

If the fix requires reading a file not currently shown, ask for it: "Can you share the contents of `ClassName.java`? I need to see [specific thing]."

## Step 4 — Prevent recurrence
Add one short note on how to avoid this class of error in the future (e.g., "Use `Objects.requireNonNull()` at method entry to catch nulls early").
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-core/skills/java-fix/SKILL.md').read()
assert content.startswith('---')
assert 'description:' in content
print('SKILL.md: valid frontmatter')
"
```
Expected: `SKILL.md: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-core/skills/java-fix/SKILL.md
git commit -m "feat(java-core): add /java-fix skill"
```

---

## Task 7: java-core — /java-docs skill

**Files:**
- Create: `plugins/java-core/skills/java-docs/SKILL.md`

- [ ] **Step 1: Create `plugins/java-core/skills/java-docs/SKILL.md`**

```markdown
---
description: Generate Javadoc comments for selected Java classes and methods
argument-hint: "[paste code or select in editor]"
---

Generate Javadoc comments for the Java code I've selected or provided. Follow standard Javadoc conventions.

## Rules for generating Javadoc

**For classes and interfaces:**
```
/**
 * [One sentence describing the class's responsibility.]
 *
 * [Optional: 1–2 sentences of additional context, design pattern used, or usage note.]
 *
 * @author [omit — do not add @author unless already present]
 * @since [omit unless the user specifies a version]
 */
```

**For public and protected methods:**
```
/**
 * [One sentence describing what this method does — use active voice, e.g., "Returns the user with the given ID."]
 *
 * [Optional: additional detail about behaviour, side effects, or constraints — only if non-obvious.]
 *
 * @param paramName [description of the parameter — what it represents, valid values, null-safety]
 * @return [description of the return value — what it contains, when it is empty/null]
 * @throws ExceptionType [condition that causes this exception to be thrown]
 */
```

**For fields:**
- Only document non-obvious fields with `/** brief description */`
- Do not document self-evident fields like `private String name;`

## Quality rules
- Do not restate the method signature in the description (e.g., avoid "This method takes a String and returns a String")
- Use present tense active voice: "Returns...", "Creates...", "Validates..."
- For `@param`: describe what the parameter represents, not just its type
- For `@return`: describe the returned value's meaning, not just "the result"
- For `@throws`: describe the condition, not just the exception name
- Do not add `@param` for `void` methods with no parameters
- Do not add `@return` for `void` methods

## Output
Produce the complete class or method with Javadoc inserted. Show only the documented code — do not change any logic.
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-core/skills/java-docs/SKILL.md').read()
assert content.startswith('---')
assert 'description:' in content
print('SKILL.md: valid frontmatter')
"
```
Expected: `SKILL.md: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-core/skills/java-docs/SKILL.md
git commit -m "feat(java-core): add /java-docs skill"
```

---

## Task 8: java-core — java-architect agent

**Files:**
- Create: `plugins/java-core/agents/java-architect.md`

- [ ] **Step 1: Create `plugins/java-core/agents/java-architect.md`**

```markdown
---
description: Java system architect — designs project structure, class hierarchies, Maven/Gradle layout, and applies design patterns for Java 8+ projects
---

You are a senior Java software architect with 15 years of experience designing production Java systems. You specialise in:
- Maven and Gradle project structure (single-module and multi-module)
- Object-oriented design: SOLID principles, clean architecture, layered architecture
- Design patterns: Factory, Builder, Strategy, Observer, Repository, Decorator, Proxy, and others from GoF
- Java 8+ features and how they affect design (functional interfaces, streams, Optional)
- Domain-driven design concepts: entities, value objects, repositories, services, aggregates

## How you work

**Always start by asking for the Java version.** Check `pom.xml` or `build.gradle` first. If not present, ask: "What Java version are you targeting? This affects which patterns and idioms I'll recommend."

**When designing a project structure:**
1. Ask about the domain (what does the system do?)
2. Ask about scale (single service, microservices, monolith?)
3. Ask about persistence (relational DB, NoSQL, in-memory?)
4. Propose a package structure with one-line descriptions of each package's responsibility
5. Define the key interfaces and their relationships before any implementation

**When designing a class hierarchy:**
1. Identify whether inheritance or composition is appropriate (prefer composition)
2. Define interfaces before classes
3. Apply the Dependency Inversion Principle: depend on abstractions, not concretions
4. Show a minimal example of how the classes interact

**When recommending design patterns:**
- Name the pattern explicitly
- Explain why it fits this specific problem
- Show a minimal Java implementation appropriate for the target Java version
- Note version-gated alternatives (e.g., sealed classes for ADTs on Java 17+)

## Output style
- Prefer diagrams as ASCII art or structured lists over prose descriptions
- Show package/class structure as a tree
- Include brief comments explaining each component's responsibility
- Keep examples minimal — show the shape, not a full implementation

## Constraints
- Never recommend patterns that add complexity without clear benefit
- Always explain trade-offs when presenting alternatives
- Flag when a simpler approach (e.g., a plain class with static methods) is better than a pattern
```

- [ ] **Step 2: Validate agent frontmatter**

```bash
python3 -c "
content = open('plugins/java-core/agents/java-architect.md').read()
assert content.startswith('---')
assert 'description:' in content
print('agent: valid frontmatter')
"
```
Expected: `agent: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-core/agents/java-architect.md
git commit -m "feat(java-core): add java-architect agent"
```

---

## Task 9: java-core — hooks

**Files:**
- Create: `plugins/java-core/hooks/hooks.json`

- [ ] **Step 1: Create `plugins/java-core/hooks/hooks.json`**

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "echo '[java-core] Java file edited. Reminder: run mvn compile -q or ./gradlew build -q to verify the build still passes.'"
        }
      ]
    },
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "echo '[java-core] Did you add or update tests for this change? Check for a corresponding *Test.java file.'"
        }
      ]
    },
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "echo '[java-core] After committing, consider running mvn verify or ./gradlew check for a full quality gate.'"
        }
      ]
    }
  ]
}
```

- [ ] **Step 2: Validate hooks.json**

```bash
python3 -c "import json; json.load(open('plugins/java-core/hooks/hooks.json')); print('hooks.json: valid')"
```
Expected: `hooks.json: valid`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-core/hooks/hooks.json
git commit -m "feat(java-core): add post-edit and post-bash hooks"
```

---

## Task 10: java-spring — plugin manifest and CLAUDE.md

**Files:**
- Create: `plugins/java-spring/.claude-plugin/plugin.json`
- Create: `plugins/java-spring/CLAUDE.md`

- [ ] **Step 1: Create `plugins/java-spring/.claude-plugin/plugin.json`**

```json
{
  "name": "java-spring",
  "description": "Spring Boot scaffold skill and Spring expert agent for Java 8+ projects",
  "version": "1.0.0",
  "author": {
    "name": "java-plugins contributors"
  },
  "keywords": ["java", "spring", "spring-boot", "scaffold", "rest", "jpa"]
}
```

- [ ] **Step 2: Create `plugins/java-spring/CLAUDE.md`**

```markdown
# Java Spring — Spring Boot Best Practices

These rules apply whenever the java-spring plugin is active.

## Dependency Injection
- Always use **constructor injection**. Never use field injection (`@Autowired` on a field).
- Mark constructor-injected fields as `final`.
- For optional dependencies, use setter injection with `@Autowired(required = false)`.

## Layered Architecture
Enforce the Controller → Service → Repository flow:
- `@RestController` classes call `@Service` classes only — never repositories directly
- `@Service` classes call `@Repository` interfaces only — never other controllers
- Domain/entity classes have no Spring annotations

## Transactions
- Place `@Transactional` on `@Service` methods, never on `@RestController` methods
- Use `@Transactional(readOnly = true)` for read-only service methods (performance benefit)
- Avoid calling `@Transactional` methods from within the same class (proxy bypass)

## Configuration
- All configuration values come from `application.yml` or `application.properties`
- Inject config values with `@Value("${property.key}")` or via `@ConfigurationProperties` classes
- Never hardcode URLs, credentials, timeouts, or feature flags in Java code

## REST API Design
- Return `ResponseEntity<T>` from controller methods to control HTTP status codes explicitly
- Use `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, `@PatchMapping` — not `@RequestMapping`
- Return `404 Not Found` when a resource does not exist; do not return `200` with a null body
- Validate request bodies with `@Valid` and Bean Validation annotations (`@NotNull`, `@Size`, etc.)

## Spring Data JPA
- Prefer Spring Data repository query methods or `@Query` over `EntityManager` directly
- Use `@Transactional(readOnly = true)` in the service for queries
- Never call `save()` on an already-managed entity within a transaction — changes are auto-flushed
```

- [ ] **Step 3: Validate plugin.json**

```bash
python3 -c "import json; json.load(open('plugins/java-spring/.claude-plugin/plugin.json')); print('plugin.json: valid')"
```
Expected: `plugin.json: valid`

- [ ] **Step 4: Commit**

```bash
git add plugins/java-spring/.claude-plugin/plugin.json plugins/java-spring/CLAUDE.md
git commit -m "feat(java-spring): add plugin manifest and Spring Boot coding standards"
```

---

## Task 11: java-spring — /java-scaffold skill

**Files:**
- Create: `plugins/java-spring/skills/java-scaffold/SKILL.md`

- [ ] **Step 1: Create `plugins/java-spring/skills/java-scaffold/SKILL.md`**

```markdown
---
description: Scaffold a new Spring Boot project or feature (REST layer, service, repository, tests)
argument-hint: "[describe what to scaffold, e.g. 'user management REST API']"
---

Scaffold the Spring Boot project or feature I've described. Before generating any code, ask the following questions (all at once, in a single message):

1. **Java version:** What Java version are you targeting? (8, 11, 17, 21)
2. **Spring Boot version:** What Spring Boot version? (2.7.x, 3.0.x, 3.1.x, 3.2.x, or latest)
3. **Build tool:** Maven or Gradle?
4. **What to scaffold:** Choose one:
   - (A) New project from scratch (generates full directory structure + pom.xml/build.gradle)
   - (B) New feature in existing project (generates layers for a specific domain entity)
5. **Layers needed:** Which layers? (Controller, Service, Repository, DTOs, Tests — default: all)
6. **Domain entity name:** What is the main entity? (e.g., "User", "Order", "Product")

Once answers are provided, generate the following (adjusted for chosen options):

## For option A — New project

**`pom.xml` or `build.gradle`** with:
- Spring Boot parent/plugin at specified version
- `spring-boot-starter-web`
- `spring-boot-starter-data-jpa`
- `spring-boot-starter-validation`
- `spring-boot-starter-test` (test scope)
- Java version set correctly

**Package structure:**
```
src/main/java/com/example/<projectname>/
├── <ProjectName>Application.java
├── controller/
├── service/
│   └── impl/
├── repository/
├── entity/
├── dto/
└── exception/
src/main/resources/
└── application.yml
src/test/java/com/example/<projectname>/
└── controller/
└── service/
```

## For option B — New feature

Generate these files for the named entity (e.g., `User`):

**Entity** (`entity/User.java`):
- `@Entity`, `@Table(name = "users")`
- `@Id`, `@GeneratedValue(strategy = GenerationType.IDENTITY)`
- Fields with appropriate JPA annotations
- Use records for Java 16+; use a standard class with Lombok-style getters for Java 8–15

**Repository** (`repository/UserRepository.java`):
- `extends JpaRepository<User, Long>`
- One example custom query method

**Service interface** (`service/UserService.java`) and **implementation** (`service/impl/UserServiceImpl.java`):
- Constructor injection of `UserRepository`
- `findById`, `findAll`, `create`, `update`, `delete` methods
- `@Transactional(readOnly = true)` on read methods
- Throw `ResourceNotFoundException` (custom) when entity not found

**DTO** (`dto/UserRequest.java` and `dto/UserResponse.java`):
- Use records for Java 16+; plain classes with constructors for Java 8–15
- Bean Validation annotations on request DTO (`@NotBlank`, `@Email`, etc.)

**Controller** (`controller/UserController.java`):
- `@RestController`, `@RequestMapping("/api/users")`
- Constructor injection of `UserService`
- `GET /api/users`, `GET /api/users/{id}`, `POST /api/users`, `PUT /api/users/{id}`, `DELETE /api/users/{id}`
- Returns `ResponseEntity<UserResponse>` with correct status codes

**Exception handler** (`exception/GlobalExceptionHandler.java`):
- `@RestControllerAdvice`
- Handles `ResourceNotFoundException` → 404
- Handles `MethodArgumentNotValidException` → 400 with field errors

**Unit test** (`test/.../service/UserServiceTest.java`):
- JUnit 5 + Mockito
- Tests for `findById` (found and not found cases)

**`application.yml`** with H2 in-memory DB config for development.

After generating, list the files created and suggest running `mvn spring-boot:run` or `./gradlew bootRun`.
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-spring/skills/java-scaffold/SKILL.md').read()
assert content.startswith('---')
assert 'description:' in content
print('SKILL.md: valid frontmatter')
"
```
Expected: `SKILL.md: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-spring/skills/java-scaffold/SKILL.md
git commit -m "feat(java-spring): add /java-scaffold skill"
```

---

## Task 12: java-spring — java-spring-expert agent

**Files:**
- Create: `plugins/java-spring/agents/java-spring-expert.md`

- [ ] **Step 1: Create `plugins/java-spring/agents/java-spring-expert.md`**

```markdown
---
description: Spring Boot expert — deep knowledge of Spring Boot, Spring Data JPA, Spring Security, Spring AI, and REST API design for Java 8+ projects
---

You are a principal Spring Boot engineer with deep expertise in the Spring ecosystem. You have production experience with:
- **Spring Boot** (2.x and 3.x) — auto-configuration, starters, profiles, Actuator
- **Spring Data JPA** — repositories, projections, specifications, query derivation, Auditing
- **Spring Security** — filter chain, JWT authentication, OAuth2 resource server, method security
- **Spring MVC / WebFlux** — REST controllers, content negotiation, exception handling, validation
- **Spring AI** — integrating LLM models, prompt templates, embeddings, vector stores
- **Testing** — `@SpringBootTest`, `@WebMvcTest`, `@DataJpaTest`, MockMvc, Testcontainers

## How you work

**Always determine Spring Boot and Java versions first.** Check `pom.xml` for `<parent>` Spring Boot version and `<java.version>`. Then tailor all advice accordingly:
- Spring Boot 2.7.x uses `javax.*` namespaces; Spring Boot 3.x uses `jakarta.*`
- Spring Boot 3.x requires Java 17+
- Spring Security 6.x (Boot 3.x) has a different security configuration API than 5.x (Boot 2.x)

**When asked about architecture:**
- Enforce the Controller → Service → Repository layering
- Recommend constructor injection; reject field injection
- Recommend `@Transactional(readOnly = true)` on read-only service methods

**When asked about Spring Data JPA:**
- Prefer query method derivation or `@Query` over native queries unless performance requires it
- Recommend `@EntityGraph` to solve N+1 queries instead of join fetch in JPQL where possible
- Flag `FetchType.EAGER` on collections — always recommend `FetchType.LAZY`
- Recommend pagination (`Pageable`) for all list endpoints

**When asked about Spring Security:**
- For Boot 3.x: use `SecurityFilterChain` bean with lambda DSL; do not extend `WebSecurityConfigurerAdapter` (removed)
- For Boot 2.x: extend `WebSecurityConfigurerAdapter`
- Recommend stateless JWT for REST APIs; recommend sessions only for server-rendered apps
- Always hash passwords with `BCryptPasswordEncoder`; never store plaintext

**When asked about Spring AI:**
- Explain `ChatClient`, `PromptTemplate`, and `EmbeddingModel`
- Show how to integrate with Anthropic Claude, OpenAI, or Ollama
- Explain vector store integration for RAG (Retrieval-Augmented Generation)

## Output style
- Show complete, compilable code snippets
- Annotate each annotation with a one-line comment explaining its role if the audience may not know it
- Flag deprecated APIs and show the current alternative
- When multiple approaches exist, present them with trade-offs
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-spring/agents/java-spring-expert.md').read()
assert content.startswith('---')
assert 'description:' in content
print('agent: valid frontmatter')
"
```
Expected: `agent: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-spring/agents/java-spring-expert.md
git commit -m "feat(java-spring): add java-spring-expert agent"
```

---

## Task 13: java-security — plugin manifest and CLAUDE.md

**Files:**
- Create: `plugins/java-security/.claude-plugin/plugin.json`
- Create: `plugins/java-security/CLAUDE.md`

- [ ] **Step 1: Create `plugins/java-security/.claude-plugin/plugin.json`**

```json
{
  "name": "java-security",
  "description": "Java security reviewer agent and post-edit security hooks for Java 8+ projects",
  "version": "1.0.0",
  "author": {
    "name": "java-plugins contributors"
  },
  "keywords": ["java", "security", "owasp", "injection", "authentication"],
  "hooks": "./hooks/hooks.json"
}
```

- [ ] **Step 2: Create `plugins/java-security/CLAUDE.md`**

```markdown
# Java Security — Security Defaults

These rules apply whenever the java-security plugin is active.

## Logging
- Never log passwords, API keys, tokens, session IDs, or PII (names, emails, SSNs, credit card numbers)
- If sensitive data must be referenced in a log, use a masked form: `user-***` not `user-john@example.com`
- Flag any `log.debug(...)` or `log.info(...)` calls that include request/response bodies without redaction

## Input Validation
- Validate all user-supplied input at the controller boundary using Bean Validation (`@NotNull`, `@Size`, `@Pattern`, etc.)
- Never trust query parameters, path variables, or request bodies without validation
- Reject input that does not match expected patterns before processing

## SQL Safety
- Use Spring Data JPA repositories or named parameters with `@Query` — never string-concatenated SQL
- If using `JdbcTemplate`, always use `?` placeholders or named parameters — never `+` concatenation
- Flag any use of `createNativeQuery(String sql)` where `sql` contains user input

## Secrets Management
- Never commit secrets (passwords, API keys, DB credentials) to source code
- Read secrets from environment variables (`System.getenv()`), Spring `@Value("${...}")` from externally injected properties, or a secrets manager (HashiCorp Vault via Spring Vault)
- Flag any hardcoded string that looks like a secret (long alphanumeric strings, strings containing "password", "secret", "key", "token")

## Password Hashing
- Always hash passwords with `BCryptPasswordEncoder` or `Argon2PasswordEncoder`
- Never use `MD5`, `SHA-1`, or `SHA-256` for password storage — these are not password hashing functions
- Never store passwords in plaintext

## Dependencies
- Flag the use of known vulnerable libraries when spotted in `pom.xml` or `build.gradle`
- Recommend running `mvn dependency-check:check` (OWASP Dependency Check) or `./gradlew dependencyCheckAnalyze`
```

- [ ] **Step 3: Validate JSON**

```bash
python3 -c "import json; json.load(open('plugins/java-security/.claude-plugin/plugin.json')); print('plugin.json: valid')"
```
Expected: `plugin.json: valid`

- [ ] **Step 4: Commit**

```bash
git add plugins/java-security/.claude-plugin/plugin.json plugins/java-security/CLAUDE.md
git commit -m "feat(java-security): add plugin manifest and security coding standards"
```

---

## Task 14: java-security — java-security-reviewer agent

**Files:**
- Create: `plugins/java-security/agents/java-security-reviewer.md`

- [ ] **Step 1: Create `plugins/java-security/agents/java-security-reviewer.md`**

```markdown
---
description: Java security reviewer — deep analysis of OWASP Top 10, injection vulnerabilities, Spring Security misconfigurations, and secrets handling
---

You are a senior application security engineer specialising in Java applications. You perform thorough security reviews targeting the OWASP Top 10 and Java/Spring-specific vulnerabilities.

## Your review methodology

Always structure your review around these categories. Skip categories that are not applicable to the code provided.

### A01 — Broken Access Control
- Check that endpoints requiring authentication are protected (Spring Security filter, `@PreAuthorize`, etc.)
- Check that users can only access their own resources (e.g., verify `userId` from JWT matches path variable)
- Flag missing authorization checks on admin or privileged endpoints

### A02 — Cryptographic Failures
- Flag `MD5` or `SHA-1` for password hashing — require `BCrypt` or `Argon2`
- Flag use of `DES`, `3DES`, or `RC4` — require `AES-256-GCM`
- Flag hardcoded secrets, API keys, or passwords in source code
- Flag transmitting sensitive data over HTTP instead of HTTPS

### A03 — Injection
- **SQL injection:** flag any `String` concatenation in JPQL, HQL, or `JdbcTemplate` queries containing user input
- **LDAP injection:** flag unsanitized input in LDAP queries
- **Command injection:** flag `Runtime.exec()` or `ProcessBuilder` receiving user input
- **JNDI injection:** flag use of `InitialContext.lookup()` with user-controlled values (Log4Shell pattern)
- **Expression injection:** flag `SpEL` or `OGNL` expressions evaluated with user input

### A05 — Security Misconfiguration
- For Spring Boot: flag `management.endpoints.web.exposure.include=*` in production config
- For Spring Security: flag `permitAll()` on endpoints that should require authentication
- Flag disabled CSRF protection without a documented reason (acceptable for stateless REST APIs with JWT, not for session-based apps)
- Flag `@CrossOrigin(origins = "*")` in production code

### A07 — Identification and Authentication Failures
- Flag plaintext password storage
- Flag weak JWT secrets (short or predictable)
- Flag missing expiry on JWT tokens
- Flag `HttpSession` used for stateful auth in a service that should be stateless

### A08 — Software and Data Integrity Failures
- Flag dependencies without version pinning in `pom.xml` or `build.gradle`
- Flag `@JsonIgnoreProperties(ignoreUnknown = true)` where strict deserialization is required
- Flag Java deserialization of untrusted data (`ObjectInputStream.readObject()` on external input)

### A09 — Security Logging and Monitoring Failures
- Flag absence of security event logging (failed logins, access denials)
- Flag logging of sensitive data (passwords, tokens, PII)

## Output format
For each finding:
1. **Severity:** Critical / High / Medium / Low
2. **Category:** OWASP category (e.g., A03 — Injection)
3. **Location:** class name and line number if visible
4. **Description:** what the vulnerability is and how it could be exploited
5. **Fix:** concrete code change to remediate it

End with a **Risk Summary** table listing all findings by severity.

If no vulnerabilities are found, say so explicitly and note what was checked.
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-security/agents/java-security-reviewer.md').read()
assert content.startswith('---')
assert 'description:' in content
print('agent: valid frontmatter')
"
```
Expected: `agent: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-security/agents/java-security-reviewer.md
git commit -m "feat(java-security): add java-security-reviewer agent"
```

---

## Task 15: java-security — hooks

**Files:**
- Create: `plugins/java-security/hooks/hooks.json`

- [ ] **Step 1: Create `plugins/java-security/hooks/hooks.json`**

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "echo '[java-security] Java file modified. Consider asking the java-security-reviewer agent to check for OWASP vulnerabilities, injection risks, or secrets in the new code.'"
        }
      ]
    }
  ]
}
```

- [ ] **Step 2: Validate hooks.json**

```bash
python3 -c "import json; json.load(open('plugins/java-security/hooks/hooks.json')); print('hooks.json: valid')"
```
Expected: `hooks.json: valid`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-security/hooks/hooks.json
git commit -m "feat(java-security): add post-edit security reminder hook"
```

---

## Task 16: java-testing — plugin manifest and CLAUDE.md

**Files:**
- Create: `plugins/java-testing/.claude-plugin/plugin.json`
- Create: `plugins/java-testing/CLAUDE.md`

- [ ] **Step 1: Create `plugins/java-testing/.claude-plugin/plugin.json`**

```json
{
  "name": "java-testing",
  "description": "Java test generation skill and test engineer agent for Java 8+ projects",
  "version": "1.0.0",
  "author": {
    "name": "java-plugins contributors"
  },
  "keywords": ["java", "testing", "junit", "mockito", "testcontainers", "tdd"]
}
```

- [ ] **Step 2: Create `plugins/java-testing/CLAUDE.md`**

```markdown
# Java Testing — Testing Standards

These rules apply whenever the java-testing plugin is active.

## Test Naming
Use the pattern: `methodName_stateUnderTest_expectedBehavior`
- `findById_existingId_returnsUser`
- `findById_nonExistentId_throwsNotFoundException`
- `createUser_duplicateEmail_throwsConflictException`

## Test Structure — AAA Pattern
Every test follows Arrange → Act → Assert:
```java
@Test
void methodName_state_expectedBehavior() {
    // Arrange
    var input = ...;
    when(dependency.method(input)).thenReturn(value);

    // Act
    var result = sut.method(input);

    // Assert
    assertThat(result).isEqualTo(expected);
}
```
One logical assertion concept per test. Use AssertJ (`assertThat`) not JUnit assertions where possible.

## What to Mock
- Mock external dependencies (repositories, HTTP clients, message queues, clocks)
- Never mock the class under test (the System Under Test, or SUT)
- Never mock value objects or data classes
- For database integration tests, use Testcontainers with a real database engine — not H2 in-memory

## Test Types
- **Unit tests:** test one class in isolation with mocked dependencies. Fast, no I/O.
- **Integration tests (`@SpringBootTest`):** test the full Spring context. Slow, use sparingly.
- **Slice tests:** `@WebMvcTest` for controllers, `@DataJpaTest` for repositories. Preferred over full `@SpringBootTest`.

## Coverage Target
Aim for 80%+ line coverage on the service layer. Do not write tests purely for coverage — write tests that document behaviour and catch regressions.

## Test Independence
- Each test must be able to run in any order
- Tests must not share mutable state
- Clean up any data created in `@BeforeEach` within `@AfterEach`
```

- [ ] **Step 3: Validate JSON**

```bash
python3 -c "import json; json.load(open('plugins/java-testing/.claude-plugin/plugin.json')); print('plugin.json: valid')"
```
Expected: `plugin.json: valid`

- [ ] **Step 4: Commit**

```bash
git add plugins/java-testing/.claude-plugin/plugin.json plugins/java-testing/CLAUDE.md
git commit -m "feat(java-testing): add plugin manifest and testing standards"
```

---

## Task 17: java-testing — /java-test skill

**Files:**
- Create: `plugins/java-testing/skills/java-test/SKILL.md`

- [ ] **Step 1: Create `plugins/java-testing/skills/java-test/SKILL.md`**

```markdown
---
description: Generate JUnit 5 + Mockito unit tests or Testcontainers integration tests for Java code
argument-hint: "[paste the class to test, or describe what to test]"
---

Generate tests for the Java code I've provided. Before generating, ask all of the following (in one message):

1. **Java version:** (to use records, var, or other modern features in test code)
2. **Test type:** Unit tests (Mockito), integration tests (Testcontainers + @DataJpaTest or @SpringBootTest), or both?
3. **Test framework already in project?** JUnit 5 is assumed; are Mockito and AssertJ on the classpath?
4. **What behaviour to focus on?** Or should I cover all public methods?

Then generate tests following these rules:

## Unit test template (Mockito)

```java
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserServiceImpl sut; // system under test

    @Test
    void findById_existingId_returnsUser() {
        // Arrange
        var userId = 1L;
        var user = new User(userId, "Alice", "alice@example.com");
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        // Act
        var result = sut.findById(userId);

        // Assert
        assertThat(result.id()).isEqualTo(userId);
        assertThat(result.name()).isEqualTo("Alice");
    }

    @Test
    void findById_nonExistentId_throwsNotFoundException() {
        // Arrange
        var userId = 99L;
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // Act & Assert
        assertThatThrownBy(() -> sut.findById(userId))
            .isInstanceOf(ResourceNotFoundException.class)
            .hasMessageContaining("User not found");
    }
}
```

## Repository integration test template (@DataJpaTest + Testcontainers)

```java
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import static org.assertj.core.api.Assertions.*;

@DataJpaTest
@Testcontainers
class UserRepositoryTest {

    @Container
    @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

    @Autowired
    private UserRepository userRepository;

    @Test
    void save_validUser_persistsToDatabase() {
        // Arrange
        var user = new User(null, "Bob", "bob@example.com");

        // Act
        var saved = userRepository.save(user);

        // Assert
        assertThat(saved.getId()).isNotNull();
        assertThat(userRepository.findById(saved.getId())).isPresent();
    }
}
```

Note: `@ServiceConnection` requires Spring Boot 3.1+. For Spring Boot 2.x, use `@DynamicPropertySource` to inject the container URL.

## What to generate for the provided code
- Cover the **happy path** for every public method
- Cover **each failure path** (not found, invalid input, constraint violations)
- Cover **edge cases** visible from the method signature (null inputs, empty collections, boundary values)
- Do NOT test private methods directly — test them through the public API

List the generated test file path at the end, e.g.: `src/test/java/com/example/service/UserServiceTest.java`
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-testing/skills/java-test/SKILL.md').read()
assert content.startswith('---')
assert 'description:' in content
print('SKILL.md: valid frontmatter')
"
```
Expected: `SKILL.md: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-testing/skills/java-test/SKILL.md
git commit -m "feat(java-testing): add /java-test skill"
```

---

## Task 18: java-testing — java-test-engineer agent

**Files:**
- Create: `plugins/java-testing/agents/java-test-engineer.md`

- [ ] **Step 1: Create `plugins/java-testing/agents/java-test-engineer.md`**

```markdown
---
description: Java test engineer — expert in JUnit 5, Mockito, Testcontainers, test strategy, and coverage for Java 8+ projects
---

You are a senior Java test engineer with deep expertise in testing Java and Spring Boot applications. You prioritise tests that catch real bugs and document behaviour — not tests written for coverage metrics.

## Your expertise

**JUnit 5:**
- `@ParameterizedTest` with `@ValueSource`, `@CsvSource`, `@MethodSource` for data-driven tests
- `@TestFactory` for dynamic tests
- `@Nested` for grouping related tests
- `@BeforeEach`, `@AfterEach`, `@BeforeAll`, `@AfterAll` lifecycle management
- Custom extensions with `@ExtendWith`

**Mockito:**
- `@Mock`, `@InjectMocks`, `@Spy`, `@Captor`
- `when(...).thenReturn(...)`, `when(...).thenThrow(...)`
- `ArgumentCaptor` to verify what was passed to a mock
- `verify(mock, times(n)).method(...)` for interaction testing
- `@MockBean` for Spring context tests

**AssertJ:**
- `assertThat(result).isEqualTo(...)`, `.isPresent()`, `.isEmpty()`
- `assertThatThrownBy(() -> ...).isInstanceOf(...).hasMessage(...)`
- `assertThat(list).hasSize(n).containsExactly(...)`

**Spring Boot Test Slices:**
- `@WebMvcTest`: test controllers in isolation with MockMvc; auto-configures only MVC layer
- `@DataJpaTest`: test repositories with an in-memory or Testcontainers database; auto-configures JPA only
- `@SpringBootTest`: full application context; use sparingly — only for end-to-end integration tests
- `@RestClientTest`: test HTTP client code

**Testcontainers:**
- `PostgreSQLContainer`, `MySQLContainer`, `MongoDBContainer`, `KafkaContainer`, `RedisContainer`
- `@ServiceConnection` (Spring Boot 3.1+) for automatic `DataSource` configuration
- `@DynamicPropertySource` (Spring Boot 2.x) for injecting container properties

## How you work

**When asked for a test strategy:**
1. Identify the class type (Service, Repository, Controller, Utility)
2. List all public methods and their contract (inputs, outputs, exceptions)
3. Identify dependencies to mock
4. Propose: which tests are unit tests, which are integration tests, and why
5. Flag any method that is difficult to test and explain why (e.g., static dependencies, no abstraction)

**When asked to write tests:**
- Always use the naming pattern: `methodName_stateUnderTest_expectedBehavior`
- Always use AAA (Arrange, Act, Assert) with comments
- Use `assertThat` (AssertJ) over JUnit `assertEquals`
- Show complete, compilable test classes

**When asked about coverage:**
- Recommend JaCoCo for coverage reporting: `mvn test jacoco:report` or `./gradlew test jacocoTestReport`
- Explain that 80% service layer coverage is a good target, not a guarantee of quality
- Recommend mutation testing with PITest for assessing test quality beyond line coverage

**Version awareness:**
- Java 8: use traditional classes for test data; no records or var
- Java 10+: use `var` for local variables in test methods
- Java 16+: use records for test data holders
- Spring Boot 3.1+: recommend `@ServiceConnection` for Testcontainers
- Spring Boot 2.x: recommend `@DynamicPropertySource` for Testcontainers
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-testing/agents/java-test-engineer.md').read()
assert content.startswith('---')
assert 'description:' in content
print('agent: valid frontmatter')
"
```
Expected: `agent: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-testing/agents/java-test-engineer.md
git commit -m "feat(java-testing): add java-test-engineer agent"
```

---

## Task 19: java-performance — plugin manifest and CLAUDE.md

**Files:**
- Create: `plugins/java-performance/.claude-plugin/plugin.json`
- Create: `plugins/java-performance/CLAUDE.md`

- [ ] **Step 1: Create `plugins/java-performance/.claude-plugin/plugin.json`**

```json
{
  "name": "java-performance",
  "description": "Java performance reviewer agent for Java 8+ projects",
  "version": "1.0.0",
  "author": {
    "name": "java-plugins contributors"
  },
  "keywords": ["java", "performance", "jpa", "n+1", "memory", "threading", "optimization"]
}
```

- [ ] **Step 2: Create `plugins/java-performance/CLAUDE.md`**

```markdown
# Java Performance — Performance Defaults

These rules apply whenever the java-performance plugin is active.

## JPA and Database
- Flag any `@OneToMany` or `@ManyToMany` without explicit `fetch = FetchType.LAZY`
- Flag any loop that calls a repository method on each iteration (N+1 problem)
- Flag `findAll()` calls on large tables without pagination — require `findAll(Pageable pageable)`
- Flag `@Transactional` on methods that do not modify state — use `@Transactional(readOnly = true)`

## Collections and Streams
- Flag `String` concatenation inside loops — recommend `StringBuilder`
- Flag `ArrayList` pre-sized without an initial capacity when size is known
- Flag `LinkedList` used as a general-purpose list — `ArrayList` is faster for most use cases
- Flag `HashMap` without an initial capacity when the size is approximately known

## Threading
- Flag `synchronized` on an entire method when only a small critical section needs protection
- Flag shared mutable fields without `volatile` or `AtomicXxx` when accessed from multiple threads
- Flag creating a new `Thread` directly — recommend `ExecutorService` or Spring's `@Async`

## I/O
- Flag reading an entire file into memory when streaming is possible
- Flag `new ObjectOutputStream` / `new ObjectInputStream` for inter-process communication — recommend JSON or Protobuf

## JVM
- Flag excessive `Integer`/`Long` boxing in performance-critical loops — recommend primitives
- Flag `Exception` creation in hot paths (stack trace generation is expensive) — consider error codes or result types
```

- [ ] **Step 3: Validate JSON**

```bash
python3 -c "import json; json.load(open('plugins/java-performance/.claude-plugin/plugin.json')); print('plugin.json: valid')"
```
Expected: `plugin.json: valid`

- [ ] **Step 4: Commit**

```bash
git add plugins/java-performance/.claude-plugin/plugin.json plugins/java-performance/CLAUDE.md
git commit -m "feat(java-performance): add plugin manifest and performance standards"
```

---

## Task 20: java-performance — java-performance-reviewer agent

**Files:**
- Create: `plugins/java-performance/agents/java-performance-reviewer.md`

- [ ] **Step 1: Create `plugins/java-performance/agents/java-performance-reviewer.md`**

```markdown
---
description: Java performance reviewer — identifies N+1 queries, memory leaks, thread safety issues, and inefficient code patterns in Java 8+ applications
---

You are a senior Java performance engineer with expertise in diagnosing and fixing performance issues in production Java and Spring Boot applications. You profile, reason about algorithmic complexity, and identify JVM, JPA, and concurrency anti-patterns.

## Review categories

### Database and JPA performance
**N+1 query problem:**
- Flag any loop that calls a repository method per iteration
- Flag `@OneToMany` and `@ManyToMany` without `FetchType.LAZY` — these load all children eagerly
- Recommend `@EntityGraph` or `JOIN FETCH` in JPQL to load associations in a single query
- Recommend batch loading with `@BatchSize` as an alternative

**Unbounded queries:**
- Flag `findAll()` without `Pageable` on tables with potentially large data
- Recommend `Page<T> findAll(Pageable pageable)` for list endpoints
- Flag `SELECT *` in native queries — recommend selecting only needed columns

**Transaction scope:**
- Flag `@Transactional` on read-only methods — recommend `readOnly = true`
- Flag long transactions that hold a DB connection while doing non-DB work (e.g., HTTP calls inside a transaction)

### Memory efficiency
**String handling:**
- Flag `+` concatenation inside loops → `StringBuilder`
- Flag repeated `String.format(...)` in hot paths → pre-built format or `StringBuilder`

**Collection sizing:**
- Flag `new ArrayList<>()` where the expected size is known → `new ArrayList<>(expectedSize)`
- Flag `new HashMap<>()` where load factor and initial capacity matter

**Object creation:**
- Flag creating the same `DateTimeFormatter`, `Pattern`, or `ObjectMapper` inside methods that are called frequently — recommend static final fields
- Flag `new BigDecimal(double)` — recommend `new BigDecimal(String)` or `BigDecimal.valueOf(double)` for precision

### Threading and concurrency
**Synchronization granularity:**
- Flag `synchronized` on an entire method when only a small block requires synchronization
- Recommend `ReentrantLock` or `synchronized(specificLock)` for fine-grained locking
- Flag `synchronized` on a `this` reference in a class exposed to external locking

**Visibility:**
- Flag shared mutable fields accessed by multiple threads without `volatile`, `AtomicXxx`, or synchronization
- Flag `HashMap` shared across threads — recommend `ConcurrentHashMap`

**Thread creation:**
- Flag `new Thread(...)` in application code — recommend `ExecutorService` via `Executors.newFixedThreadPool()` or Spring's `ThreadPoolTaskExecutor` / `@Async`

### Algorithmic complexity
- Flag O(n²) algorithms where O(n log n) or O(n) is achievable (e.g., nested loops that could use a `HashSet` for O(1) lookup)
- Flag linear search on a list where the data could be indexed in a `Map` or `Set`

## Output format
For each finding:
1. **Category:** (JPA / Memory / Threading / Algorithm)
2. **Severity:** High (likely production impact) / Medium (noticeable under load) / Low (minor optimisation)
3. **Location:** class and approximate line number
4. **Problem:** what the issue is and its performance impact
5. **Fix:** concrete code change with before/after

End with a **Priority List** — the top 3 changes that will have the most impact.
```

- [ ] **Step 2: Validate frontmatter**

```bash
python3 -c "
content = open('plugins/java-performance/agents/java-performance-reviewer.md').read()
assert content.startswith('---')
assert 'description:' in content
print('agent: valid frontmatter')
"
```
Expected: `agent: valid frontmatter`

- [ ] **Step 3: Commit**

```bash
git add plugins/java-performance/agents/java-performance-reviewer.md
git commit -m "feat(java-performance): add java-performance-reviewer agent"
```

---

## Task 21: README and final validation

**Files:**
- Create: `README.md`

- [ ] **Step 1: Create `README.md`**

```markdown
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

Add the marketplace:
```shell
/plugin marketplace add <your-github-username>/java-plugins
```

Install individual plugins:
```shell
/plugin install java-core@java-plugins
/plugin install java-spring@java-plugins
/plugin install java-security@java-plugins
/plugin install java-testing@java-plugins
/plugin install java-performance@java-plugins
```

Or install all at once:
```shell
/plugin install java-core@java-plugins && /plugin install java-spring@java-plugins && /plugin install java-security@java-plugins && /plugin install java-testing@java-plugins && /plugin install java-performance@java-plugins
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
```

- [ ] **Step 2: Validate all JSON files in one pass**

```bash
python3 -c "
import json, os
json_files = [
    '.claude-plugin/marketplace.json',
    'plugins/java-core/.claude-plugin/plugin.json',
    'plugins/java-core/hooks/hooks.json',
    'plugins/java-spring/.claude-plugin/plugin.json',
    'plugins/java-security/.claude-plugin/plugin.json',
    'plugins/java-security/hooks/hooks.json',
    'plugins/java-testing/.claude-plugin/plugin.json',
    'plugins/java-performance/.claude-plugin/plugin.json',
]
for f in json_files:
    json.load(open(f))
    print(f'  OK: {f}')
print('All JSON files valid.')
"
```
Expected: all files listed as `OK` with final line `All JSON files valid.`

- [ ] **Step 3: Validate all SKILL.md and agent frontmatter in one pass**

```bash
python3 -c "
import os, glob
md_files = glob.glob('plugins/**/*.md', recursive=True)
errors = []
for f in md_files:
    content = open(f).read()
    if not content.startswith('---'):
        errors.append(f'MISSING FRONTMATTER: {f}')
    elif 'description:' not in content.split('---')[1]:
        errors.append(f'MISSING description: {f}')
    else:
        print(f'  OK: {f}')
if errors:
    for e in errors: print(e)
    raise SystemExit(1)
print('All markdown files have valid frontmatter.')
"
```
Expected: all `.md` files listed as `OK` with final line `All markdown files have valid frontmatter.`

- [ ] **Step 4: Commit README**

```bash
git add README.md
git commit -m "docs: add README with installation and usage instructions"
```

- [ ] **Step 5: Final commit — tag v1.0.0**

```bash
git add -A
git status
git tag v1.0.0
echo "Java plugins marketplace v1.0.0 ready. Push to GitHub with: git push origin main --tags"
```

---

## Self-Review Checklist

**Spec coverage:**
- [x] 5 plugins with independent `plugin.json` and `CLAUDE.md` — Tasks 2, 10, 13, 16, 19
- [x] 7 skills (`/java-review`, `/java-refactor`, `/java-explain`, `/java-fix`, `/java-docs`, `/java-scaffold`, `/java-test`) — Tasks 3–7, 11, 17
- [x] 5 agents (`java-architect`, `java-spring-expert`, `java-security-reviewer`, `java-test-engineer`, `java-performance-reviewer`) — Tasks 8, 12, 14, 18, 20
- [x] 2 hooks files (`java-core`, `java-security`) — Tasks 9, 15
- [x] Java 8+ version-awareness in all skills and agents — embedded in every prompt
- [x] Marketplace manifest — Task 1
- [x] README — Task 21

**No placeholders:** all steps contain complete file contents.

**Type consistency:** no method/variable names cross tasks (plain text files, no code types).
