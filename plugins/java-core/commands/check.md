---
description: Run static analysis on the Java project — detects configured tools (Checkstyle, SpotBugs, PMD) and reports findings
---

# /java-core:check

Run static analysis and code quality checks on the project.

## Instructions

1. **Detect configured tools** by scanning `pom.xml` or `build.gradle` for:
   - Checkstyle (`maven-checkstyle-plugin` / `checkstyle` plugin)
   - SpotBugs (`spotbugs-maven-plugin` / `com.github.spotbugs`)
   - PMD (`maven-pmd-plugin` / `pmd` plugin)
   - SonarQube (`sonar-maven-plugin` / `sonarqube` plugin)

2. **Run available tools**:
   - Maven: `mvn checkstyle:check`, `mvn spotbugs:check`, `mvn pmd:check`
   - Gradle: `./gradlew checkstyleMain`, `./gradlew spotbugsMain`, `./gradlew pmdMain`

3. If **no tools configured**:
   - Run a manual review of the current file or recent changes using `/java-core:java-review`
   - Suggest adding Checkstyle to `pom.xml` or `build.gradle`

4. **Report findings** grouped by severity:
   - CRITICAL / HIGH: Show file:line, rule name, and description
   - MEDIUM / LOW: Summarize counts by category

5. If findings exceed 10 items, show the top 10 by severity and summarize the rest.
