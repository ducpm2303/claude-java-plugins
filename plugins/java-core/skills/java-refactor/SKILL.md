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

## Next Steps
After completing refactoring:
- If tests don't exist for the refactored code → suggest running `/java-test` to generate tests
- If the refactoring changed public API signatures → suggest running `/java-docs` to update Javadoc
- Remind the user to run their build: `mvn compile -q` or `./gradlew build -q`
