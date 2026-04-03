---
globs: ["**/*.java", "**/pom.xml", "**/build.gradle", "**/build.gradle.kts"]
---

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
