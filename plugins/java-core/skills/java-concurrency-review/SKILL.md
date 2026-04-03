---
description: Review Java code for thread safety issues, race conditions, deadlocks, and concurrency anti-patterns
argument-hint: "[paste concurrent code or select in editor]"
---

Review the Java code for concurrency correctness. Before reviewing, detect the Java version from `pom.xml` or `build.gradle` — suggest modern alternatives only if the version supports them.

## Step 1 — Identify concurrency primitives in use
List all concurrency mechanisms found: `synchronized`, `volatile`, `AtomicXxx`, `Lock`, `ExecutorService`, `CompletableFuture`, `CountDownLatch`, `Semaphore`, `BlockingQueue`, virtual threads (Java 21+).

## Step 2 — Review for race conditions
- Flag shared mutable fields accessed from multiple threads without synchronization
- Flag read-modify-write operations (e.g., `count++`) not wrapped in `synchronized` or `AtomicInteger`
- Flag non-atomic check-then-act patterns: `if (map.containsKey(k)) map.get(k)` → suggest `map.computeIfAbsent()`
- Flag `HashMap` shared across threads → suggest `ConcurrentHashMap`
- Flag `ArrayList` / `HashSet` shared across threads → suggest concurrent alternatives

## Step 3 — Review for deadlocks
- Flag multiple locks acquired in inconsistent order across methods
- Flag `synchronized` calls that invoke external/unknown code while holding a lock
- Flag `ReentrantLock` without `try/finally` unlock → lock may never be released
- Flag nested `synchronized` blocks on different objects

## Step 4 — Review synchronization granularity
- Flag `synchronized` on entire methods where only a small critical section needs protection
- Suggest `ReentrantLock` for fine-grained locking with timeout capability
- Flag `synchronized(this)` in classes exposed to external code → suggest private lock object
- For Java 21+: flag `synchronized` on virtual thread code → suggest `ReentrantLock` (avoids carrier thread pinning)

## Step 5 — Review visibility
- Flag fields shared across threads without `volatile`, `AtomicXxx`, or synchronization
- Flag `boolean` flag fields used to stop threads → must be `volatile` or `AtomicBoolean`
- Flag lazy initialization without double-checked locking or `volatile`

## Step 6 — Review thread lifecycle
- Flag `new Thread(...)` created directly in application code → suggest `ExecutorService`
- Flag `ExecutorService` never shut down → resource leak
- Flag unbounded thread pools (`Executors.newCachedThreadPool()`) under high load → suggest bounded pool
- For Java 21+: suggest `Executors.newVirtualThreadPerTaskExecutor()` for I/O-bound workloads

## Output format
1. **Summary** — overall thread safety assessment
2. **Issues** — grouped by: 🔴 Critical (data corruption risk) / 🟡 Warning (potential deadlock/liveness) / 🔵 Suggestion (improvement)
3. **Each issue**: location + problem + fix with before/after code

## Next Steps
- If deadlock risk found → suggest running thread dump analysis: `jstack <pid>`
- If using Java 21+ → consider `/java-virtual-threads` modernization
- After fixes → run `/java-review` for general code quality
