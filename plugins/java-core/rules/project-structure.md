---
globs: ["**/pom.xml", "**/build.gradle", "**/build.gradle.kts"]
---

# Java Project Structure Rules

Apply these rules when reading or editing build files.

## Standard Maven/Gradle Layout
```
src/
├── main/
│   ├── java/          ← production source code
│   └── resources/     ← application.yml, static files, templates
└── test/
    ├── java/          ← test source code
    └── resources/     ← test-specific config (application-test.yml)
```

## Build File Hygiene
- Pin dependency versions in a `<dependencyManagement>` (Maven) or platform BOM (Gradle) — never scatter versions across `<dependency>` blocks
- Never use `LATEST` or `RELEASE` version ranges — they break reproducible builds
- Keep test-scope dependencies (`spring-boot-starter-test`, `mockito-core`) out of `compile`/`implementation` scope
- Use the Spring Boot parent POM / BOM to align all Spring dependency versions

## Java Version Declaration
- Maven: `<java.version>` in `<properties>`, or `<maven.compiler.source>` + `<maven.compiler.target>`
- Gradle: `java { sourceCompatibility = JavaVersion.VERSION_17 }` or `toolchain { languageVersion = JavaLanguageVersion.of(21) }`
- Prefer toolchain over `sourceCompatibility` for Gradle (Java 11+, ensures consistent cross-platform builds)

## Dependency Red Flags
- `javax.*` imports in a Spring Boot 3.x project → should be `jakarta.*`
- Duplicate dependencies with different versions → consolidate
- Test libraries in non-test scope → move to `test` scope
