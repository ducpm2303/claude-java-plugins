---
description: Check Java code for SOLID principles violations and suggest improvements
argument-hint: "[paste class or paste multiple related classes]"
---

Review the provided Java code for SOLID principles violations. For each principle, check for violations and suggest targeted improvements. Tailor suggestions to the detected Java version.

## S — Single Responsibility Principle
A class should have one reason to change.

**Violations to flag:**
- Classes named `*Manager`, `*Helper`, `*Utils` with more than 3 unrelated methods
- Service classes that also contain validation logic, email sending, AND database calls
- Classes with more than ~200 lines (often a signal of multiple responsibilities)
- Methods that do multiple distinct things (parse + validate + persist + notify)

**Fix pattern:** Extract each responsibility into its own class. Show the split.

## O — Open/Closed Principle
Open for extension, closed for modification.

**Violations to flag:**
- `if/else` or `switch` chains on type/status that would require modification to add new types
- Hard-coded behaviour that should be configurable
- Direct instantiation of concrete classes in business logic (use interfaces)

**Fix pattern:** Introduce Strategy, Template Method, or polymorphism. Show the refactoring.

## L — Liskov Substitution Principle
Subtypes must be substitutable for their base types.

**Violations to flag:**
- Subclass overrides a method by throwing `UnsupportedOperationException`
- Subclass weakens preconditions (accepts nulls when parent doesn't)
- Subclass strengthens postconditions (returns more restricted type)
- Square extends Rectangle anti-pattern

**Fix pattern:** Use composition over inheritance, or restructure the hierarchy.

## I — Interface Segregation Principle
Clients should not depend on interfaces they don't use.

**Violations to flag:**
- Interfaces with more than ~5 methods where implementors only use some
- `implements` classes that leave methods empty or throw `UnsupportedOperationException`
- Fat service interfaces used by clients that only call 1–2 methods

**Fix pattern:** Split the fat interface into focused role interfaces.

## D — Dependency Inversion Principle
Depend on abstractions, not concretions.

**Violations to flag:**
- Field or constructor takes a concrete class (`new UserServiceImpl`) instead of an interface (`UserService`)
- `new ConcreteClass()` inside business logic instead of dependency injection
- Static utility method calls deep in business logic that prevent testing
- `@Autowired` on a concrete class field instead of an interface

**Fix pattern:** Introduce interface + constructor injection. Show the change.

## Output format
For each violation:
1. **Principle violated:** (S/O/L/I/D)
2. **Location:** class + method
3. **Problem:** what rule is broken and why it matters
4. **Fix:** before/after code

End with: **SOLID Score** — how many of the 5 principles are cleanly satisfied (e.g., "3/5 — S, I, D pass; O and L need attention").

## Next Steps
- For O violations → run `/java-design-pattern` to find the right pattern
- For D violations → run `/java-refactor` to extract interfaces
- For SRP violations → run `/java-refactor` to split classes
