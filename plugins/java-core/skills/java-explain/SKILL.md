---
description: Explains Java code in plain language including design patterns. Use when user asks to "explain this code", "what does this do", "help me understand", "walk me through this", or "how does this work".
argument-hint: "[paste code or select in editor]"
allowed-tools: Read, Grep, Glob
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
