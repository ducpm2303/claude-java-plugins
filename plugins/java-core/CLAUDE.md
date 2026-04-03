---
globs: ["**/*.java", "**/pom.xml", "**/build.gradle", "**/build.gradle.kts"]
---

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
