# Scaffold Templates

---

## pom.xml (Maven)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
             https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>{spring-boot-version}</version>
    </parent>
    <groupId>com.example</groupId>
    <artifactId>{project-name}</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <properties>
        <java.version>{java-version}</java.version>
    </properties>
    <dependencies>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-validation</artifactId></dependency>
        <dependency><groupId>org.postgresql</groupId><artifactId>postgresql</artifactId><scope>runtime</scope></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-test</artifactId><scope>test</scope></dependency>
        <dependency><groupId>org.testcontainers</groupId><artifactId>junit-jupiter</artifactId><scope>test</scope></dependency>
        <dependency><groupId>org.testcontainers</groupId><artifactId>postgresql</artifactId><scope>test</scope></dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin><groupId>org.springframework.boot</groupId><artifactId>spring-boot-maven-plugin</artifactId></plugin>
        </plugins>
    </build>
</project>
```

---

## build.gradle (Gradle)

```groovy
plugins {
    id 'java'
    id 'org.springframework.boot' version '{spring-boot-version}'
    id 'io.spring.dependency-management' version '1.1.4'
}
group = 'com.example'
version = '0.0.1-SNAPSHOT'
java { sourceCompatibility = JavaVersion.VERSION_{java-version} }

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    runtimeOnly 'org.postgresql:postgresql'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.testcontainers:junit-jupiter'
    testImplementation 'org.testcontainers:postgresql'
}
```

---

## application.yml

```yaml
# application.yml — base config, no hardcoded credentials
spring:
  application:
    name: {project-name}
  jpa:
    hibernate:
      ddl-auto: validate
    open-in-view: false
server:
  port: 8080
```

```yaml
# application-dev.yml — local development only
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/{project-name}_dev
    username: postgres
    password: postgres
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
```

---

## Package structure

```
src/
├── main/
│   ├── java/{base-package}/
│   │   ├── {ProjectName}Application.java
│   │   ├── controller/
│   │   ├── service/
│   │   ├── repository/
│   │   ├── entity/
│   │   ├── dto/
│   │   └── exception/
│   └── resources/
│       ├── application.yml
│       └── application-dev.yml
└── test/
    └── java/{base-package}/
        ├── service/
        └── repository/
```

---

## GlobalExceptionHandler

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(Map.of("error", ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new LinkedHashMap<>();
        ex.getBindingResult().getFieldErrors()
            .forEach(e -> errors.put(e.getField(), e.getDefaultMessage()));
        return ResponseEntity.badRequest()
            .body(Map.of("error", "Validation failed", "details", errors));
    }
}
```
