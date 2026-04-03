---
globs: ["**/*.java"]
---

# Java Naming Conventions

Apply these rules whenever editing or reviewing `.java` files.

## Classes and Interfaces
- Classes: `PascalCase` — `UserService`, `OrderRepository`, `HttpClientFactory`
- Interfaces: `PascalCase`, prefer noun or adjective — `Serializable`, `UserRepository`, `PaymentGateway`
- Abstract classes: prefix `Abstract` — `AbstractBaseService`, `AbstractEntity`
- Enums: `PascalCase` — `OrderStatus`, `UserRole`
- Annotations: `PascalCase` — `@NotNull`, `@ValidEmail`

## Methods and Variables
- Methods: `camelCase` verb phrases — `getUserById`, `calculateTotal`, `isActive`
- Variables: `camelCase` nouns — `orderCount`, `userEmail`, `retryInterval`
- Boolean variables/methods: `is`, `has`, `can` prefix — `isActive`, `hasPermission`, `canRetry`
- Constants (`static final`): `SCREAMING_SNAKE_CASE` — `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS`

## Packages
- All lowercase, dot-separated, reverse domain — `com.example.order.service`
- Standard layers: `controller`, `service`, `repository`, `entity`, `dto`, `exception`, `config`, `util`
- No underscores or hyphens in package names

## Generic Type Parameters
- Single capital letter: `T` (type), `E` (element), `K` (key), `V` (value), `R` (result)
- Descriptive for domain types: `<ID extends Serializable>`

## Flag violations by name
If a name violates these conventions, flag it with the rule broken and a corrected suggestion.
