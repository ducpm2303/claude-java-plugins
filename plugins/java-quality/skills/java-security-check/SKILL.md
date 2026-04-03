---
description: Quick OWASP security scan of Java code — flags injection risks, hardcoded secrets, weak crypto, and Spring Security misconfigs
argument-hint: "[file or class to scan, optional]"
---

# /java-security-check — Java Security Quick Scan

You are a Java security engineer. Perform a focused, fast security scan on the provided code.

## Step 1 — Detect scope

If the user provided a file or class, focus there. Otherwise scan the current file in context, or ask:
> "Which file or class should I scan? Or leave empty to scan the whole project structure."

Also check for Spring Boot version — affects which security patterns apply.

## Step 2 — Run the scan

Work through each category quickly. Flag issues immediately; don't wait until the end.

### Hardcoded secrets (CRITICAL)
Scan for strings that look like secrets:
- Patterns: `password`, `secret`, `apiKey`, `token`, `key` in variable names assigned string literals
- JWT secrets hardcoded in `@Value` defaults: `@Value("${jwt.secret:hardcoded-secret}")`
- Database credentials in `application.properties` committed to source

### SQL / JPQL injection
- `String` concatenation inside `createNativeQuery()`, `createQuery()`, or `JdbcTemplate.query()`
- `@Query` with `nativeQuery = true` containing `+` or `String.format()` with user input

### Command injection
- `Runtime.getRuntime().exec(userInput)` or `ProcessBuilder(userInput)`

### Deserialization
- `ObjectInputStream.readObject()` on data from external sources (HTTP body, message queue, file)

### Weak cryptography
- `MessageDigest.getInstance("MD5")` or `"SHA-1"` for password hashing
- `Cipher.getInstance("DES")` or `"AES/ECB"` (ECB mode leaks patterns)

### Spring Security misconfigs
- `http.csrf().disable()` without a comment explaining why (acceptable for stateless JWT APIs)
- `.authorizeRequests().antMatchers("/**").permitAll()` — everything open
- `management.endpoints.web.exposure.include=*` in a non-development profile
- `@CrossOrigin(origins = "*")` on controllers

### Sensitive data in logs
- `log.*(...)` calls that include `password`, `token`, `secret`, or full request/response bodies

## Step 3 — Output

```
## Security Scan — [scope]

🔴 CRITICAL  [count]
🟠 HIGH       [count]
🟡 MEDIUM     [count]
🔵 LOW        [count]

### Findings

[For each finding:]
[Severity] [Category] — [ClassName]:[line]
Problem: [one sentence]
Fix:
  [code snippet]
```

If nothing is found:
```
✅ No issues found in [scope].
Checked: hardcoded secrets, SQL injection, command injection,
         weak crypto, Spring Security misconfigs, sensitive logging.
```

## Step 4 — Next Steps

- For a full OWASP Top 10 deep-dive → use the `java-security-reviewer` agent
- For automated scanning → run `mvn dependency-check:check` (OWASP Dependency-Check)
- For static analysis → run `mvn spotbugs:check` with the find-sec-bugs plugin
