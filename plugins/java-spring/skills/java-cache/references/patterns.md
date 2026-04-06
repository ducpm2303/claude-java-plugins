# Spring Cache — Reference Patterns

## Caffeine Setup (single-instance)

### Maven
```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
<dependency>
  <groupId>com.github.ben-manes.caffeine</groupId>
  <artifactId>caffeine</artifactId>
</dependency>
```

### application.yml
```yaml
spring:
  cache:
    type: caffeine
    caffeine:
      spec: maximumSize=500,expireAfterWrite=10m
    cache-names:
      - products
      - categories
      - userProfiles
```

### Per-cache TTL (Java config)
```java
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager manager = new CaffeineCacheManager();
        manager.setCacheNames(List.of("products", "categories", "userProfiles"));
        manager.registerCustomCache("products",
            Caffeine.newBuilder()
                .maximumSize(1000)
                .expireAfterWrite(Duration.ofMinutes(10))
                .recordStats()          // enable hit/miss metrics
                .build());
        manager.registerCustomCache("userProfiles",
            Caffeine.newBuilder()
                .maximumSize(500)
                .expireAfterWrite(Duration.ofMinutes(30))
                .build());
        // default spec for other caches
        manager.setCaffeine(Caffeine.newBuilder().maximumSize(200).expireAfterWrite(Duration.ofMinutes(5)));
        return manager;
    }
}
```

---

## Redis Setup (multi-instance / distributed)

### Maven (Spring Boot 3.x)
```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

### application.yml (Boot 3.x)
```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}
      lettuce:
        pool:
          max-active: 10
          max-idle: 5
          min-idle: 1
  cache:
    type: redis
    redis:
      time-to-live: 10m
      key-prefix: "myapp:"
      use-key-prefix: true
      cache-null-values: false
```

### application.yml (Boot 2.x)
```yaml
spring:
  redis:
    host: ${REDIS_HOST:localhost}
    port: 6379
```

### Redis CacheManager with JSON serialization
```java
@Configuration
@EnableCaching
public class RedisCacheConfig {

    @Bean
    public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .activateDefaultTyping(
                LaissezFaireSubTypeValidator.instance,
                ObjectMapper.DefaultTyping.NON_FINAL,
                JsonTypeInfo.As.PROPERTY
            );

        RedisSerializer<Object> jsonSerializer =
            new GenericJackson2JsonRedisSerializer(objectMapper);

        RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(
                RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(
                RedisSerializationContext.SerializationPair.fromSerializer(jsonSerializer))
            .disableCachingNullValues();

        // Per-cache TTL overrides
        Map<String, RedisCacheConfiguration> cacheConfigs = new HashMap<>();
        cacheConfigs.put("userProfiles", defaultConfig.entryTtl(Duration.ofMinutes(30)));
        cacheConfigs.put("products",     defaultConfig.entryTtl(Duration.ofMinutes(60)));
        cacheConfigs.put("categories",   defaultConfig.entryTtl(Duration.ofHours(6)));

        return RedisCacheManager.builder(connectionFactory)
            .cacheDefaults(defaultConfig)
            .withInitialCacheConfigurations(cacheConfigs)
            .build();
    }
}
```

---

## Cache Annotations

### @Cacheable — cache the result
```java
@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository repository;

    // Cache by id; skip caching if result is null
    @Cacheable(cacheNames = "products", key = "#id", unless = "#result == null")
    public ProductDto findById(Long id) {
        return repository.findById(id)
            .map(ProductDto::from)
            .orElse(null);
    }

    // Compound key
    @Cacheable(cacheNames = "products", key = "#category + ':' + #page")
    public Page<ProductDto> findByCategory(String category, int page) {
        return repository.findByCategory(category, PageRequest.of(page, 20))
            .map(ProductDto::from);
    }
}
```

### @CacheEvict — remove on mutation
```java
@Service
@RequiredArgsConstructor
public class ProductService {

    // Evict single entry on update
    @CacheEvict(cacheNames = "products", key = "#dto.id")
    @Transactional
    public ProductDto update(ProductDto dto) {
        Product entity = repository.findById(dto.getId()).orElseThrow();
        entity.update(dto);
        return ProductDto.from(entity);
    }

    // Evict on delete
    @CacheEvict(cacheNames = "products", key = "#id")
    @Transactional
    public void delete(Long id) {
        repository.deleteById(id);
    }

    // Evict all — after bulk import
    @CacheEvict(cacheNames = "products", allEntries = true)
    @Transactional
    public void importAll(List<ProductDto> products) {
        repository.saveAll(products.stream().map(Product::from).toList());
    }
}
```

### @CachePut — update cache on write
```java
// Updates cache with the new value WITHOUT skipping the method
@CachePut(cacheNames = "products", key = "#result.id")
@Transactional
public ProductDto create(ProductDto dto) {
    Product saved = repository.save(Product.from(dto));
    return ProductDto.from(saved);
}
```

### @Caching — multiple cache operations at once
```java
@Caching(
    evict = {
        @CacheEvict(cacheNames = "products",     key = "#id"),
        @CacheEvict(cacheNames = "productList",  allEntries = true),
        @CacheEvict(cacheNames = "categories",   allEntries = true)
    }
)
@Transactional
public void delete(Long id) {
    repository.deleteById(id);
}
```

---

## Conditional Caching

```java
// Only cache if result has items
@Cacheable(cacheNames = "search", key = "#query",
           unless = "#result == null || #result.isEmpty()")
public List<ProductDto> search(String query) { ... }

// Only cache for authenticated users (SpEL on principal)
@Cacheable(cacheNames = "dashboard",
           key = "#root.target.getCurrentUserId()",
           condition = "#root.target.isAuthenticated()")
public DashboardDto getDashboard() { ... }
```

---

## Cache Metrics (Actuator)

### application.yml
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,caches,metrics
  metrics:
    cache:
      instrument: true   # enables cache.gets, cache.puts, cache.evictions
```

### Useful metrics endpoints
```
GET /actuator/caches                        # list all cache names + sizes
GET /actuator/caches/{cacheName}            # inspect a specific cache
GET /actuator/metrics/cache.gets            # hit/miss counts (Caffeine + Redis)
GET /actuator/metrics/cache.puts
GET /actuator/metrics/cache.evictions
```

---

## Redis Cluster & Sentinel

### Cluster (application.yml)
```yaml
spring:
  data:
    redis:
      cluster:
        nodes:
          - redis-node1:6379
          - redis-node2:6379
          - redis-node3:6379
        max-redirects: 3
```

### Sentinel (application.yml)
```yaml
spring:
  data:
    redis:
      sentinel:
        master: mymaster
        nodes:
          - sentinel1:26379
          - sentinel2:26379
          - sentinel3:26379
      password: ${REDIS_PASSWORD}
```

---

## Common Pitfalls

| Pitfall | Fix |
|---|---|
| `@EnableCaching` missing | Add to any `@Configuration` class |
| Calling `@Cacheable` from same class | Extract to a separate Spring bean |
| `private` method annotated | Make it `public` or `protected` |
| No TTL on Redis | Always set `time-to-live` |
| No `maximumSize` on Caffeine | Always set `maximumSize` to prevent OOM |
| JDK serialization in Redis | Use `GenericJackson2JsonRedisSerializer` |
| Caching null returns | Add `unless = "#result == null"` |
| No eviction on writes | Add `@CacheEvict` to every mutating method |
