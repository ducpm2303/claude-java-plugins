---
description: Reviews Java code for bugs, naming issues, code smells, and version-appropriate idioms. Use when user asks to "review this code", "check my Java", "look at this class", "find issues in", "code review", "what's wrong with this", or "review this file".
argument-hint: "[paste code or select in editor]"
allowed-tools: Read, Grep, Glob
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

## Next Steps
After completing this review, offer these follow-up actions based on findings:
- If structural issues found (long methods, god classes) → suggest running `/java-refactor`
- If missing or inadequate tests found → suggest running `/java-test`
- If security issues found (SQL concat, hardcoded secrets, weak crypto) → suggest delegating to the `java-security-reviewer` agent
- If performance issues found (N+1, unbounded queries, String concatenation in loops) → suggest delegating to the `java-performance-reviewer` agent
- If Javadoc is missing on public API → suggest running `/java-docs`
