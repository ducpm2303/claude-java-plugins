---
name: java-spring-ai
description: Use when the user asks to add AI features, integrate Spring AI or LangChain4J, build a chatbot, implement RAG (retrieval-augmented generation), use vector stores, stream LLM responses, or call AI tools/functions in a Spring Boot project.
version: 1.0.0
authors: [java-plugins contributors]
tags: [java, spring-boot, spring-ai, langchain4j, llm, rag, vector-store, ai]
allowed-tools: [Read, Glob, Grep, Edit, Write]
---

# Spring AI / LangChain4J Skill

Detect the framework in use, then apply the correct patterns.

## Step 1 — Detect framework and version

Check `pom.xml` or `build.gradle`:
- `spring-ai-*` dependency → **Spring AI** (note version: 1.0.x GA or 0.8.x milestone)
- `langchain4j-*` dependency → **LangChain4J** (note version: 0.x or 1.x)
- Neither present → offer to add one (recommend Spring AI for Spring Boot 3.x, LangChain4J for Boot 2.x)

Check Spring Boot version:
- Boot 3.x → Spring AI 1.x preferred, LangChain4J 0.35+
- Boot 2.x → LangChain4J 0.30.x (Spring AI requires Boot 3.x)

---

## Mode: `review`

User asks to review existing AI code. Check for:

**Spring AI:**
- [ ] `ChatClient` built via `ChatClient.Builder` (not raw `ChatModel`) for fluent API
- [ ] Prompt templates use `PromptTemplate` with variables — no string concatenation
- [ ] Streaming uses `stream().content()` or `Flux<String>` — not blocking `.call()` for real-time responses
- [ ] `@Retryable` or Spring AI retry config on ChatClient calls — LLMs are flaky
- [ ] Secrets (`spring.ai.openai.api-key`) come from env vars or Vault, never hardcoded
- [ ] `VectorStore` queries use `SearchRequest.query(text).withTopK(n)` — not raw SQL
- [ ] RAG advisor (`QuestionAnswerAdvisor`) attached to ChatClient — not manual context injection
- [ ] Token usage logged at DEBUG, not INFO (avoid log noise)

**LangChain4J:**
- [ ] AI services use `@AiService` interface — not `ChatLanguageModel.generate()` directly
- [ ] System prompts in `@SystemMessage` annotation — not hardcoded strings
- [ ] Memory uses `MessageWindowChatMemory` or `TokenWindowChatMemory` — not unlimited history
- [ ] Streaming via `StreamingChatLanguageModel` with `TokenStream` — not blocking
- [ ] Embeddings via `EmbeddingModel` + `EmbeddingStore` for RAG — not in-memory list search
- [ ] Tools annotated with `@Tool` on service methods — not manual function dispatch
- [ ] API key from `@Value("${langchain4j.openai.api-key}")` — never literal

---

## Mode: `chat`

User asks to add a basic chatbot or chat endpoint.

### Spring AI
1. Add dependency (see `references/patterns.md` → Spring AI Setup)
2. Inject `ChatClient.Builder`, build a `ChatClient` bean
3. Create `ChatController` with `@PostMapping("/chat")`
4. Use `chatClient.prompt().user(message).call().content()` for simple response
5. For streaming: return `Flux<String>` with `chatClient.prompt().user(message).stream().content()`
6. Add `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` to `application.yml` via `${env-var}`

### LangChain4J
1. Add `langchain4j-spring-boot-starter` + provider dependency
2. Define `@AiService` interface with `@SystemMessage`
3. Register as Spring bean via `AiServices.builder(MyAssistant.class).chatLanguageModel(model).build()`
4. Expose via `@RestController`

---

## Mode: `rag`

User asks to implement RAG (chat over documents, knowledge base, semantic search).

### Spring AI RAG
1. Choose vector store: PgVector (PostgreSQL), Chroma, Redis, Weaviate, Qdrant (see `references/patterns.md`)
2. Add `spring-ai-{store}-store-spring-boot-starter`
3. Ingest pipeline:
   - `DocumentReader` (PDF, text, web) → `TokenTextSplitter` → `VectorStore.add()`
   - Run at startup via `ApplicationRunner` or dedicated `@PostMapping("/ingest")`
4. Query pipeline:
   - Attach `QuestionAnswerAdvisor(vectorStore)` to `ChatClient`
   - Spring AI auto-retrieves context and injects into prompt
5. Tune: `SearchRequest.withTopK(5).withSimilarityThreshold(0.7)`

### LangChain4J RAG
1. Add `EmbeddingStore` (Chroma, Qdrant, in-memory for dev)
2. `EmbeddingStoreIngestor` with `DocumentSplitter` and `EmbeddingModel`
3. `EmbeddingStoreContentRetriever` → `RetrievalAugmentor` → `AiServices` builder

---

## Mode: `tools`

User asks to give the AI the ability to call Java methods (function/tool calling).

### Spring AI
1. Define a `@Bean` of type `Function<Input, Output>` — Spring AI auto-registers it
2. Or use `@Description` on a `record` parameter for rich schema
3. Pass function names to `ChatClient`: `.options(OpenAiChatOptions.builder().withFunction("myFunction").build())`
4. Spring AI handles the tool call loop automatically

### LangChain4J
1. Annotate service methods with `@Tool("description of what this tool does")`
2. Register the service as a tool: `AiServices.builder(...).tools(myToolService).build()`
3. The model decides when to call — no manual dispatch needed

---

## Mode: `memory`

User asks to add conversation memory / chat history.

### Spring AI
- `MessageChatMemoryAdvisor` with `InMemoryChatMemory` for single-instance apps
- `JdbcChatMemory` for persistent / multi-instance memory (requires `spring-ai-jdbc` store)
- Key: pass `conversationId` (e.g., session ID or user ID) to scope memory per user

### LangChain4J
- `MessageWindowChatMemory.withMaxMessages(20)` — keeps last N messages
- `TokenWindowChatMemory` — keeps messages within token budget
- For persistence: implement `ChatMemoryStore` backed by Redis or JDBC

---

## Output format

For **review mode**: list findings as `[CRITICAL] / [HIGH] / [MEDIUM] / [LOW]` with file:line references.

For **implementation modes** (chat, rag, tools, memory):
1. Show exact Maven/Gradle dependencies with versions
2. Show full working code snippets (not pseudocode)
3. Show `application.yml` configuration
4. Note: state the minimum Spring Boot and Java version required

Always note version-specific differences:
- Spring AI 1.0.x (GA) vs 0.8.x (milestone) — API changes between these
- LangChain4J 1.x vs 0.x — `AiServices` API changed in 1.x
- Spring Boot 3.x required for Spring AI; Boot 2.x → use LangChain4J
