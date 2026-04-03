---
description: Build the Java project — detects Maven or Gradle and runs a clean build with test execution
---

# /java-core:build

Build the Java project and report the result.

## Instructions

1. Detect the build tool:
   - If `pom.xml` exists → Maven
   - If `build.gradle` or `build.gradle.kts` exists → Gradle
   - If neither found → tell the user and stop

2. Run the build:
   - **Maven**: `mvn clean package`
   - **Gradle**: `./gradlew clean build`

3. Parse the output:
   - On **success**: report `BUILD SUCCESS`, total time, and test results summary (tests run, failures, errors, skipped)
   - On **failure**: show the first failing error with file:line, describe the root cause in plain English, and suggest a fix

4. If tests fail specifically (build compiled but tests red):
   - List each failing test with method name and failure message
   - Suggest running `/java-quality:test` for targeted test generation
