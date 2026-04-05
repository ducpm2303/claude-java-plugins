# OpenAPI Annotation Templates

---

## Controller with full annotations

```java
@Tag(name = "Products", description = "Product catalogue management")
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @Operation(summary = "List all products",
               description = "Returns a paginated list. Use `page` and `size` query params.")
    @ApiResponse(responseCode = "200", description = "Page of products")
    @GetMapping
    public ResponseEntity<Page<ProductResponse>> findAll(Pageable pageable) { ... }

    @Operation(summary = "Get product by ID")
    @ApiResponse(responseCode = "200", description = "Product found")
    @ApiResponse(responseCode = "404", description = "Product not found")
    @GetMapping("/{id}")
    public ResponseEntity<ProductResponse> findById(@PathVariable Long id) { ... }

    @Operation(summary = "Create a new product")
    @ApiResponse(responseCode = "201", description = "Product created",
                 content = @Content(schema = @Schema(implementation = ProductResponse.class)))
    @ApiResponse(responseCode = "400", description = "Validation failed")
    @ApiResponse(responseCode = "409", description = "Product with this SKU already exists")
    @PostMapping
    public ResponseEntity<ProductResponse> create(@Valid @RequestBody ProductRequest request) { ... }

    @Operation(summary = "Update product")
    @ApiResponse(responseCode = "200", description = "Product updated")
    @ApiResponse(responseCode = "400", description = "Validation failed")
    @ApiResponse(responseCode = "404", description = "Product not found")
    @PutMapping("/{id}")
    public ResponseEntity<ProductResponse> update(@PathVariable Long id,
                                                   @Valid @RequestBody ProductRequest request) { ... }

    @Operation(summary = "Delete product")
    @ApiResponse(responseCode = "204", description = "Product deleted")
    @ApiResponse(responseCode = "404", description = "Product not found")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) { ... }
}
```

---

## DTO with @Schema annotations

```java
// Request DTO
public record ProductRequest(

    @Schema(description = "Product display name", example = "Wireless Mouse", requiredMode = REQUIRED)
    @NotBlank String name,

    @Schema(description = "Unit price in USD", example = "29.99", minimum = "0")
    @NotNull @DecimalMin("0.00") BigDecimal price,

    @Schema(description = "Product category", example = "ELECTRONICS",
            allowableValues = {"ELECTRONICS", "CLOTHING", "FOOD"})
    @NotNull String category,

    @Schema(description = "Whether the product is available for purchase", example = "true")
    boolean active

) {}

// Response DTO
public record ProductResponse(

    @Schema(description = "Unique product identifier", example = "42")
    Long id,

    @Schema(description = "Product display name", example = "Wireless Mouse")
    String name,

    @Schema(description = "Unit price in USD", example = "29.99")
    BigDecimal price,

    @Schema(description = "Product category", example = "ELECTRONICS")
    String category,

    @Schema(description = "Availability status", example = "true")
    boolean active,

    @Schema(description = "ISO-8601 creation timestamp", example = "2024-01-15T10:30:00Z")
    LocalDateTime createdAt

) {}
```

---

## OpenAPI global config bean

```java
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("My Service API")
                .version("v1.0")
                .description("REST API for My Service")
                .contact(new Contact()
                    .name("API Support")
                    .email("api@example.com"))
                .license(new License()
                    .name("Apache 2.0")
                    .url("https://www.apache.org/licenses/LICENSE-2.0")))
            // JWT Bearer auth in Swagger UI "Authorize" button
            .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
            .components(new Components()
                .addSecuritySchemes("bearerAuth", new SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("bearer")
                    .bearerFormat("JWT")
                    .description("Paste your JWT access token here")));
    }
}
```

---

## Hide internal endpoints from public docs

```java
// Hide entire controller
@Hidden
@RestController
@RequestMapping("/internal")
public class InternalController { ... }

// Hide one endpoint
@Operation(hidden = true)
@GetMapping("/admin/debug")
public ResponseEntity<DebugInfo> debug() { ... }
```

---

## application.yml — production safety

```yaml
springdoc:
  swagger-ui:
    enabled: ${SWAGGER_ENABLED:false}    # false in prod, true in dev
  api-docs:
    enabled: ${SWAGGER_ENABLED:false}
```
