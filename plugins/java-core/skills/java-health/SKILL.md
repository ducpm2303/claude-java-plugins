---
description: Run a holistic code health check across security, performance, test coverage, code smells, and dependency freshness
argument-hint: "[path to file, class, or leave empty for current project]"
---

Run a comprehensive health check on the Java code or project I've indicated. This is an aggregating command — it runs multiple review dimensions and produces a single scored report.

## Step 1 — Detect context
- Check `pom.xml` or `build.gradle` for: Java version, Spring Boot version, dependencies
- If a specific file is provided, scope the review to that file
- If no file is provided, review the overall project structure

## Step 2 — Run all dimensions in parallel (mentally)

Assess each dimension independently, then score it:

### A. Security (0–25 points)
Check for:
- Hardcoded secrets or credentials (-5 each, max -15)
- SQL string concatenation (-5 each, max -10)
- Missing input validation on controller methods (-3 each, max -9)
- Weak password hashing (MD5/SHA-1) (-8)
- Sensitive data in logs (-4)

Full score = 25. Deduct per finding.

### B. Test Structure Assessment (0–25 points)

> **Note:** This is a *structural* assessment — Claude cannot run your test suite or measure real line coverage. For actual coverage numbers run `mvn test jacoco:report` or `./gradlew test jacocoTestReport`.

Check for:
- Presence of test files for each service class (-5 per missing service test, max -15)
- Use of H2 instead of Testcontainers for DB integration tests (-5)
- Missing exception path tests (no test method with "throws", "exception", or "notFound" in name) (-3 per service class, max -9)
- Tests that mock the class under test (-4)

Full score = 25. Deduct per finding.

### C. Performance (0–25 points)
Check for:
- `@OneToMany`/`@ManyToMany` without `FetchType.LAZY` (-6 each, max -12)
- Loops calling repository methods (N+1) (-8 each, max -16)
- `findAll()` without pagination on large entities (-5)
- `String` concatenation in loops (-3 each, max -6)
- `synchronized` on entire methods (-3 each, max -6)

Full score = 25. Deduct per finding.

### D. Code Quality (0–25 points)
Check for:
- Methods longer than 20 lines (-3 each, max -12)
- Classes with more than one clear responsibility (-5 each, max -10)
- Magic numbers/strings not extracted to constants (-2 each, max -8)
- Missing Javadoc on public API methods (-1 each, max -5)
- Raw types (unparameterized generics) (-3 each, max -6)

Full score = 25. Deduct per finding.

## Step 3 — Output the Health Report

Format the report exactly like this:

```
╔══════════════════════════════════════════╗
║         JAVA HEALTH REPORT               ║
║  Project: [project name or file name]    ║
║  Java: [version] | Spring Boot: [version]║
╠══════════════════════════════════════════╣
║  Security          [score]/25   [grade]  ║
║  Test Coverage     [score]/25   [grade]  ║
║  Performance       [score]/25   [grade]  ║
║  Code Quality      [score]/25   [grade]  ║
╠══════════════════════════════════════════╣
║  TOTAL HEALTH      [total]/100  [grade]  ║
╚══════════════════════════════════════════╝
```

Grade scale: 23–25 = A, 18–22 = B, 13–17 = C, 8–12 = D, 0–7 = F

## Step 4 — Top 3 Actions
List the 3 highest-impact improvements ranked by score gain:
1. **[Action]** — fixes [dimension], gains up to +[N] points
2. **[Action]** — fixes [dimension], gains up to +[N] points
3. **[Action]** — fixes [dimension], gains up to +[N] points

## Step 5 — Offer drill-downs
After the report, offer:
- "Run `/java-review` for detailed code quality findings"
- "Run `/java-security-check` or ask `java-security-reviewer` for a full OWASP analysis"
- "Run `/java-perf-check` or ask `java-performance-reviewer` for performance deep-dive"
- "Run `/java-test` to generate missing tests"
- "For real coverage numbers: `mvn test jacoco:report` or `./gradlew test jacocoTestReport`"
