---
description: Start the Spring Boot application locally — checks prerequisites, then runs the app and reports startup status
---

# /java-spring:run

Start the Spring Boot application in the current directory.

## Instructions

1. **Pre-flight checks**:
   - Detect build tool (`pom.xml` → Maven, `build.gradle` → Gradle)
   - Check `application.yml` / `application.properties` for required env vars (`${...}` placeholders with no default)
   - Warn about any unset required variables before starting

2. **Start the application**:
   - Maven: `mvn spring-boot:run`
   - Gradle: `./gradlew bootRun`

3. **Watch startup output** for:
   - `Started <AppName> in X seconds` → report success with port
   - `APPLICATION FAILED TO START` → extract the root cause (e.g., missing bean, port conflict, datasource error) and explain in plain English
   - Port conflict (`Address already in use: 8080`) → suggest `mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8081`

4. **On datasource errors**:
   - Missing database → suggest `docker run -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:16-alpine`
   - Connection refused → check if DB container is running

5. After successful start, remind: Ctrl+C to stop; use `spring.profiles.active=dev` for dev profile.
