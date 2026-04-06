---
name: java-cache
description: Use when the user asks to add caching, configure Redis or Caffeine cache, use @Cacheable/@CacheEvict/@CachePut, optimize repeated database or API calls, or review existing Spring Boot cache configuration.
version: 1.0.0
authors: [java-plugins contributors]
tags: [java, spring-boot, cache, redis, caffeine, spring-cache]
allowed-tools: [Read, Glob, Grep, Edit, Write]
---

# Spring Cache Skill

Detect the cache provider in use, then apply the correct patterns.

## Step 1 — Detect setup

Check `pom.xml` or `build.gradle`:
- `spring-boot-starter-data-redis` → Redis (Lettuce client by default)
- `spring-boot-starter-cache` + `caffeine` → Caffeine (in-process)
- `spring-boot-starter-cache` only → Simple (ConcurrentHashMap, dev only)
- None present → offer to add (recommend Caffeine for single-instance, Redis for multi-instance/distributed)

Check Spring Boot version:
- Boot 3.x → Lettuce 6.x, Caffeine 3.x
- Boot 2.x → Lettuce 5.x, Caffeine 2.x/3.x

---

## Mode: `review`

User asks to review existing cache configuration. Check for:

- [ ] `@EnableCaching` present on a `@Configuration` class — missing it silently disables all cache annotations
- [ ] Cache names declared in `application.yml` with explicit TTL — no unnamed or unbounded caches
- [ ] `@Cacheable` methods are on Spring-managed beans (not `private`, not called within the same class — proxy bypass)
- [ ] Cache keys are deterministic — `@Cacheable(key = "#id")` not `#root.methodName` unless intentional
- [ ] `@CacheEvict` present wherever data is mutated — missing eviction causes stale cache
- [ ] `@CachePut` used to update cache on write — not a `@CacheEvict` + re-fetch pattern
- [ ] Redis serialization configured — default JDK serialization is not readable/portable; use `GenericJackson2JsonRedisSerializer`
- [ ] Redis TTL set — without `time-to-live`, entries never expire
- [ ] Caffeine `maximumSize` set — without it, cache grows unbounded and causes OOM
- [ ] Null values handled — `@Cacheable(unless = "#result == null")` to avoid caching nulls
- [ ] Cache metrics exposed: `management.metrics.cache.instrument=true`

---

## Mode: `setup`

User asks to add caching from scratch.

### Caffeine (recommended for single-instance apps)
1. Add `spring-boot-starter-cache` + `com.github.ben-manes.caffeine:caffeine`
2. Add `@EnableCaching` to a `@Configuration` class
3. Configure cache specs in `application.yml` — set `maximum-size` and `expire-after-write`
4. Annotate service methods with `@Cacheable`, `@CacheEvict`, `@CachePut`

### Redis (recommended for multi-instance / distributed)
1. Add `spring-boot-starter-data-redis`
2. Configure `spring.data.redis.host/port` (Boot 3.x) or `spring.redis.host/port` (Boot 2.x)
3. Configure `RedisCacheConfiguration` bean — set TTL and use `GenericJackson2JsonRedisSerializer`
4. Add `@EnableCaching` and annotate service methods

See `references/patterns.md` for full configuration examples.

---

## Mode: `cacheable`

User asks to cache the result of a method.

1. Place `@Cacheable(cacheNames = "products", key = "#id")` on the service method
2. The method must be on a Spring-managed bean and not `private`
3. The method must not call itself (proxy bypass) — extract to a separate bean if needed
4. Add `unless = "#result == null"` to avoid caching null results
5. Ensure the return type is `Serializable` (Redis) or any object (Caffeine)
6. Add a corresponding `@CacheEvict` on the update/delete method

---

## Mode: `evict`

User asks to invalidate/evict cache entries on data changes.

- `@CacheEvict(cacheNames = "products", key = "#id")` — evict a single entry on update/delete
- `@CacheEvict(cacheNames = "products", allEntries = true)` — evict all entries (use sparingly)
- `@CacheEvict(beforeInvocation = true)` — evict before method runs (use when method may throw)
- For multi-cache eviction: `@Caching(evict = { @CacheEvict("products"), @CacheEvict("productList") })`

---

## Mode: `redis`

User asks specifically for Redis cache configuration.

1. Add `spring-boot-starter-data-redis`
2. Configure connection: `spring.data.redis.host`, `spring.data.redis.port`, `spring.data.redis.password`
3. Define `RedisCacheManager` bean with:
   - `GenericJackson2JsonRedisSerializer` for values (human-readable, portable)
   - `StringRedisSerializer` for keys
   - Default TTL + per-cache TTL overrides
4. Enable `@EnableCaching`
5. For Redis Cluster: set `spring.data.redis.cluster.nodes`
6. For Redis Sentinel: set `spring.data.redis.sentinel.master` and `nodes`

---

## Output format

For **review mode**: list findings as `[CRITICAL] / [HIGH] / [MEDIUM] / [LOW]` with file:line references.

For **implementation modes**: show exact Maven/Gradle dependency, full `application.yml` block, and complete Java configuration + annotated example. State minimum Spring Boot version where it differs.
