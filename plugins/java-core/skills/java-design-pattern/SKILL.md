---
description: Detect design patterns in Java code, or suggest the right pattern for a given problem
argument-hint: "[paste code to detect patterns, or describe your problem]"
---

Either detect which design patterns are used in the provided code, or recommend the right pattern for a described problem. Tailor all examples to the detected Java version (Java 8+).

## Mode A — Detect patterns in existing code
Scan the code for these common patterns and name them explicitly:

**Creational:**
- **Singleton** — private constructor + static instance (flag if not thread-safe without `volatile` or `enum`)
- **Factory Method** — static `create()` or `of()` returning an interface type
- **Builder** — inner static `Builder` class with fluent setters and `build()`
- **Abstract Factory** — factory that creates families of related objects

**Structural:**
- **Decorator** — wraps another object implementing the same interface to add behaviour
- **Proxy** — Spring `@Transactional`, `@Cacheable`, `@Async` are all proxies; flag manual proxies
- **Adapter** — converts one interface to another (often with `*Adapter` or `*Wrapper` class name)
- **Facade** — simplifies a complex subsystem; often a service that orchestrates multiple repos/clients
- **Composite** — tree structure where leaf and composite implement the same interface

**Behavioral:**
- **Strategy** — interface with multiple implementations selected at runtime
- **Observer** — Spring `ApplicationEvent` / `@EventListener` or manual listener list
- **Template Method** — abstract class with `final` algorithm method calling overridable steps
- **Command** — encapsulates a request as an object (common in undo/redo, queuing)
- **Chain of Responsibility** — Spring Security filter chain, Servlet filters
- **State** — object behaviour changes based on internal state enum/object

For each detected pattern: name it, show the key code that reveals it, explain how it's used here.

## Mode B — Recommend a pattern for a problem
When the user describes a problem, recommend the most appropriate pattern:

| Problem | Recommended Pattern |
|---|---|
| Need multiple algorithms interchangeable at runtime | Strategy |
| Object creation is complex, many optional fields | Builder |
| Need to add behaviour without modifying existing class | Decorator |
| Need to notify multiple objects when state changes | Observer |
| Complex subsystem needs a simple interface | Facade |
| Same operation on tree structures | Composite |
| Object has distinct lifecycle states | State |
| Need only one instance globally | Singleton (or Spring `@Component`) |

Show a minimal Java implementation for the recommended pattern, appropriate for the detected Java version:
- Java 8+: use functional interfaces (Strategy can be a lambda `Function<T,R>`)
- Java 17+: use sealed classes for State pattern
- Java 16+: use records for value objects in patterns

## Output format
**Mode A:** List each detected pattern with: name + location + explanation + any concerns (e.g., non-thread-safe Singleton)
**Mode B:** Recommend pattern + minimal before/after code + when to use vs alternatives

## Next Steps
- After identifying patterns → run `/java-solid` to check if patterns are applied correctly
- For implementation help → ask the `java-architect` agent for full design guidance
