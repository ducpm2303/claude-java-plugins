---
description: Full quality audit — runs security scan, performance check, and test coverage analysis in sequence and produces a combined report
---

# /java-quality:audit

Run a complete quality audit combining security, performance, and test coverage checks.

## Instructions

Run each phase in order. Do not stop on findings — complete all three phases first, then report.

---

### Phase 1 — Security scan

Apply the checks from `/java-quality:java-security-check`:
- Scan for OWASP Top 10 patterns (SQL injection, XSS, hardcoded secrets, weak crypto, etc.)
- Scan for logging of sensitive data
- Scan for missing input validation at controller boundaries

---

### Phase 2 — Performance scan

Apply the checks from `/java-quality:java-perf-check`:
- N+1 query patterns (loops calling repository methods)
- Eager fetch on collections
- Missing pagination on list endpoints
- Expensive object instantiation in loops

---

### Phase 3 — Test coverage analysis

1. Run: `mvn test jacoco:report` or `./gradlew test jacocoTestReport`
2. If JaCoCo not configured, estimate coverage by counting:
   - Service classes with no corresponding `*Test.java`
   - Public methods with no test referencing them
3. Report line coverage % if available; otherwise report untested service classes

---

## Combined Report

```
╔══════════════════════════════════════════════════════════╗
║              JAVA QUALITY AUDIT REPORT                   ║
╠══════════════════════════════════════════════════════════╣
║ SECURITY  │ X critical, X high, X medium findings        ║
║ PERF      │ X high-impact, X medium findings             ║
║ COVERAGE  │ XX% line coverage (or N untested services)   ║
╠══════════════════════════════════════════════════════════╣
║ TOP ACTIONS (prioritized)                                ║
║  1. [CRITICAL] file:line — description                   ║
║  2. [HIGH] file:line — description                       ║
║  ...                                                     ║
╚══════════════════════════════════════════════════════════╝
```

List at most 10 top-priority actions, sorted by severity across all three phases.
