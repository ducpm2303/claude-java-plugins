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
