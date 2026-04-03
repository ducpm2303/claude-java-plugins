---
description: Generates Javadoc comments for Java classes and methods. Use when user asks to "add javadoc", "document this class", "write documentation", "add comments", "generate docs", or "document this method".
argument-hint: "[paste code or select in editor]"
---

Generate Javadoc comments for the Java code I've selected or provided. Follow standard Javadoc conventions.

## Rules for generating Javadoc

**For classes and interfaces:**

```
/**
 * [One sentence describing the class's responsibility.]
 *
 * [Optional: 1–2 sentences of additional context, design pattern used, or usage note.]
 *
 * @author [omit — do not add @author unless already present]
 * @since [omit unless the user specifies a version]
 */
```

**For public and protected methods:**

```
/**
 * [One sentence describing what this method does — use active voice, e.g., "Returns the user with the given ID."]
 *
 * [Optional: additional detail about behaviour, side effects, or constraints — only if non-obvious.]
 *
 * @param paramName [description of the parameter — what it represents, valid values, null-safety]
 * @return [description of the return value — what it contains, when it is empty/null]
 * @throws ExceptionType [condition that causes this exception to be thrown]
 */
```

**For fields:**
- Only document non-obvious fields with `/** brief description */`
- Do not document self-evident fields like `private String name;`

## Quality rules
- Do not restate the method signature in the description (e.g., avoid "This method takes a String and returns a String")
- Use present tense active voice: "Returns...", "Creates...", "Validates..."
- For `@param`: describe what the parameter represents, not just its type
- For `@return`: describe the returned value's meaning, not just "the result"
- For `@throws`: describe the condition, not just the exception name
- Do not add `@param` for `void` methods with no parameters
- Do not add `@return` for `void` methods

## Output
Produce the complete class or method with Javadoc inserted. Show only the documented code — do not change any logic.
