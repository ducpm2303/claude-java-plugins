---
description: Interactive Java version upgrade guide (8 to 11, 11 to 17, 17 to 21). Use when user asks to "migrate to Java 17", "upgrade to Java 21", "Java migration guide", "move from Java 11 to 17", or "what changed in Java 21".
argument-hint: "[current Java version and target version, e.g. '8 to 17']"
---

Guide the migration of a Java project to a newer Java version. This is an interactive migration assistant.

## Step 1 — Detect current version
Check `pom.xml` (`<java.version>`, `<maven.compiler.source>`, `<maven.compiler.target>`) or `build.gradle` (`sourceCompatibility`, `javaVersion`). Ask for target version if not specified.

## Step 2 — Build the migration checklist

### Java 8 → Java 11
**Breaking changes to fix:**
- Remove `sun.*` and `com.sun.*` internal API usage → find public alternatives
- Remove JavaEE modules now removed from JDK: `javax.xml.bind` (JAXB), `javax.activation`, `javax.annotation` → add as Maven dependencies (`jakarta.xml.bind-api`, etc.)
- Fix `ClassLoader.getSystemClassLoader().getResourceAsStream()` → use `getClass().getResourceAsStream()`
- Flag use of `finalize()` → deprecated, suggest `Cleaner` or try-with-resources

**Quick wins to adopt (optional):**
- `var` for local variables (Java 10+) where type is obvious
- `List.of()`, `Map.of()`, `Set.of()` instead of `Collections.unmodifiableList(Arrays.asList(...))`
- `String` new methods: `isBlank()`, `strip()`, `lines()`, `repeat()`
- `Optional.ifPresentOrElse()`, `Optional.or()`

**Build changes:**
```xml
<maven.compiler.source>11</maven.compiler.source>
<maven.compiler.target>11</maven.compiler.target>
```

### Java 11 → Java 17
**Breaking changes to fix:**
- Strong encapsulation of JDK internals — fix any `--add-opens` flags (may need library updates)
- Remove deprecated `SecurityManager` usage
- Fix `sun.misc.Unsafe` direct usage → find library replacements

**Quick wins to adopt (optional):**
- Records for immutable data classes (Java 16+)
- Sealed classes for fixed hierarchies (Java 17)
- Pattern matching `instanceof` (Java 16+)
- Text blocks for multi-line strings (Java 15+)
- Switch expressions (Java 14+)

### Java 17 → Java 21
**Breaking changes to fix:**
- None significant — Java 21 is largely additive

**Quick wins to adopt (optional):**
- Virtual threads for I/O-bound thread pools (Java 21)
- Sequenced collections: `getFirst()`, `getLast()` (Java 21)
- Pattern matching switch (standard in Java 21)
- Structured concurrency preview (Java 21)

## Step 3 — Generate migration task list
Output a numbered checklist:
```
Migration: Java [current] → Java [target]

REQUIRED (must fix before compiling):
[ ] 1. [specific change with file/class reference if visible]
[ ] 2. ...

RECOMMENDED (adopt for better code):
[ ] 3. [specific improvement]
[ ] 4. ...

BUILD CHANGES:
[ ] Update pom.xml/build.gradle compiler version
[ ] Update CI/CD Java version
[ ] Update Docker base image (e.g., eclipse-temurin:[target]-jre)
```

## Step 4 — Offer to scan
If the project files are accessible: "Want me to scan your codebase for the required changes above?"

## Next Steps
- After migration → run `/java-review` to catch any remaining issues
- After migration → run `/java-refactor` to adopt new idioms
- Update Spring Boot version if migrating to Java 17+ (Spring Boot 3.x requires Java 17+)
