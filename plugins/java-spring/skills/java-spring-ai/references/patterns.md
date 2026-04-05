# Spring AI & LangChain4J — Reference Patterns

## Spring AI Setup

### Maven (Spring Boot 3.x)
```xml
<!-- BOM — pick one -->
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.ai</groupId>
      <artifactId>spring-ai-bom</artifactId>
      <version>1.0.0</version>  <!-- GA -->
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>

<!-- Provider starters — pick one -->
<dependency>
  <groupId>org.springframework.ai</groupId>
  <artifactId>spring-ai-openai-spring-boot-starter</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework.ai</groupId>
  <artifactId>spring-ai-anthropic-spring-boot-starter</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework.ai</groupId>
  <artifactId>spring-ai-azure-openai-spring-boot-starter</artifactId>
</dependency>
```

### application.yml
```yaml
spring:
  ai:
    openai:
      api-key: ${OPENAI_API_KEY}
      chat:
        options:
          model: gpt-4o
          temperature: 0.7
    anthropic:
      api-key: ${ANTHROPIC_API_KEY}
      chat:
        options:
          model: claude-sonnet-4-6
```

---

## Spring AI — ChatClient (simple chat)

```java
@Configuration
public class AiConfig {

    @Bean
    public ChatClient chatClient(ChatClient.Builder builder) {
        return builder
            .defaultSystem("You are a helpful Java expert assistant.")
            .build();
    }
}

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatClient chatClient;

    // Blocking — single response
    @PostMapping
    public String chat(@RequestBody String message) {
        return chatClient.prompt()
            .user(message)
            .call()
            .content();
    }

    // Streaming — Server-Sent Events
    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> stream(@RequestParam String message) {
        return chatClient.prompt()
            .user(message)
            .stream()
            .content();
    }
}
```

---

## Spring AI — Prompt Templates

```java
@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ChatClient chatClient;

    private static final String REVIEW_TEMPLATE = """
        Review the following {language} code for bugs and improvements:
        
        ```{language}
        {code}
        ```
        
        Focus on: {focus}
        """;

    public String reviewCode(String language, String code, String focus) {
        return chatClient.prompt()
            .user(u -> u.text(REVIEW_TEMPLATE)
                .param("language", language)
                .param("code", code)
                .param("focus", focus))
            .call()
            .content();
    }
}
```

---

## Spring AI — RAG with PgVector

### Maven dependency
```xml
<dependency>
  <groupId>org.springframework.ai</groupId>
  <artifactId>spring-ai-pgvector-store-spring-boot-starter</artifactId>
</dependency>
```

### application.yml
```yaml
spring:
  ai:
    vectorstore:
      pgvector:
        initialize-schema: true
        dimensions: 1536      # match your embedding model
        distance-type: COSINE_DISTANCE
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
```

### Ingest documents
```java
@Component
@RequiredArgsConstructor
public class DocumentIngestor {

    private final VectorStore vectorStore;
    private final ResourceLoader resourceLoader;

    public void ingest(String resourcePath) {
        Resource resource = resourceLoader.getResource(resourcePath);
        List<Document> docs = new TokenTextSplitter().apply(
            new TikaDocumentReader(resource).get()
        );
        vectorStore.add(docs);
    }
}
```

### RAG ChatClient with QuestionAnswerAdvisor
```java
@Bean
public ChatClient ragChatClient(ChatClient.Builder builder, VectorStore vectorStore) {
    return builder
        .defaultAdvisors(
            new QuestionAnswerAdvisor(
                vectorStore,
                SearchRequest.defaults().withTopK(5).withSimilarityThreshold(0.7)
            ),
            new SimpleLoggerAdvisor()
        )
        .build();
}
```

---

## Spring AI — Function / Tool Calling

```java
// Define the function
public record WeatherRequest(String city, String unit) {}
public record WeatherResponse(double temperature, String description) {}

@Bean
@Description("Get the current weather for a city")
public Function<WeatherRequest, WeatherResponse> weatherFunction(WeatherService weatherService) {
    return req -> weatherService.getWeather(req.city(), req.unit());
}

// Use in ChatClient
@Service
@RequiredArgsConstructor
public class WeatherChatService {

    private final ChatClient chatClient;

    public String chat(String message) {
        return chatClient.prompt()
            .user(message)
            .functions("weatherFunction")   // bean name
            .call()
            .content();
    }
}
```

---

## Spring AI — Conversation Memory

```java
@Bean
public ChatClient chatClientWithMemory(ChatClient.Builder builder) {
    return builder
        .defaultAdvisors(
            new MessageChatMemoryAdvisor(new InMemoryChatMemory())
        )
        .build();
}

// Scope memory per conversation (pass conversationId)
public String chat(String message, String conversationId) {
    return chatClient.prompt()
        .user(message)
        .advisors(a -> a.param(CHAT_MEMORY_CONVERSATION_ID_KEY, conversationId)
                        .param(CHAT_MEMORY_RETRIEVE_SIZE_KEY, 20))
        .call()
        .content();
}
```

---

## LangChain4J Setup (Spring Boot 2.x or 3.x)

### Maven
```xml
<dependency>
  <groupId>dev.langchain4j</groupId>
  <artifactId>langchain4j-spring-boot-starter</artifactId>
  <version>0.36.0</version>
</dependency>
<!-- Provider — pick one -->
<dependency>
  <groupId>dev.langchain4j</groupId>
  <artifactId>langchain4j-open-ai-spring-boot-starter</artifactId>
  <version>0.36.0</version>
</dependency>
<dependency>
  <groupId>dev.langchain4j</groupId>
  <artifactId>langchain4j-anthropic-spring-boot-starter</artifactId>
  <version>0.36.0</version>
</dependency>
```

### application.yml
```yaml
langchain4j:
  open-ai:
    chat-model:
      api-key: ${OPENAI_API_KEY}
      model-name: gpt-4o
      temperature: 0.7
```

---

## LangChain4J — AI Service

```java
// Define the interface
public interface JavaAssistant {

    @SystemMessage("""
        You are an expert Java developer.
        You provide concise, version-appropriate advice for Java {javaVersion}.
        """)
    String chat(@UserMessage String message,
                @V("javaVersion") String javaVersion);
}

// Register as Spring bean
@Configuration
public class AiConfig {

    @Bean
    public JavaAssistant javaAssistant(ChatLanguageModel model) {
        return AiServices.builder(JavaAssistant.class)
            .chatLanguageModel(model)
            .chatMemory(MessageWindowChatMemory.withMaxMessages(20))
            .build();
    }
}

// Use in controller
@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiController {

    private final JavaAssistant assistant;

    @PostMapping("/chat")
    public String chat(@RequestBody ChatRequest request) {
        return assistant.chat(request.message(), request.javaVersion());
    }
}
```

---

## LangChain4J — Tool Calling

```java
@Component
public class DatabaseTools {

    private final UserRepository userRepository;

    @Tool("Find a user by their email address")
    public String findUserByEmail(String email) {
        return userRepository.findByEmail(email)
            .map(u -> "Found: " + u.getName() + " (id=" + u.getId() + ")")
            .orElse("User not found");
    }

    @Tool("Count total users in the system")
    public long countUsers() {
        return userRepository.count();
    }
}

// Register tools in AiServices
@Bean
public SupportAssistant supportAssistant(
        ChatLanguageModel model,
        DatabaseTools dbTools) {
    return AiServices.builder(SupportAssistant.class)
        .chatLanguageModel(model)
        .tools(dbTools)
        .build();
}
```

---

## LangChain4J — RAG with Embeddings

```java
// In-memory (dev/test)
@Bean
public EmbeddingStore<TextSegment> embeddingStore() {
    return new InMemoryEmbeddingStore<>();
}

// Ingest
@Component
@RequiredArgsConstructor
public class KnowledgeBaseLoader implements ApplicationRunner {

    private final EmbeddingModel embeddingModel;
    private final EmbeddingStore<TextSegment> embeddingStore;

    @Override
    public void run(ApplicationArguments args) {
        Document doc = FileSystemDocumentLoader.loadDocument("docs/faq.txt");
        EmbeddingStoreIngestor.builder()
            .documentSplitter(DocumentSplitters.recursive(500, 50))
            .embeddingModel(embeddingModel)
            .embeddingStore(embeddingStore)
            .build()
            .ingest(doc);
    }
}

// Query with RAG
@Bean
public KnowledgeAssistant knowledgeAssistant(
        ChatLanguageModel model,
        EmbeddingModel embeddingModel,
        EmbeddingStore<TextSegment> embeddingStore) {

    ContentRetriever retriever = EmbeddingStoreContentRetriever.builder()
        .embeddingStore(embeddingStore)
        .embeddingModel(embeddingModel)
        .maxResults(5)
        .minScore(0.7)
        .build();

    return AiServices.builder(KnowledgeAssistant.class)
        .chatLanguageModel(model)
        .contentRetriever(retriever)
        .build();
}
```

---

## Vector Store Comparison

| Store | Best for | Spring AI | LangChain4J |
|---|---|---|---|
| PgVector | Existing PostgreSQL | `spring-ai-pgvector-store` | `langchain4j-pgvector` |
| Redis | Low-latency, existing Redis | `spring-ai-redis-store` | `langchain4j-redis` |
| Chroma | Local dev, easy setup | `spring-ai-chroma-store` | `langchain4j-chroma` |
| Qdrant | Production, high scale | `spring-ai-qdrant-store` | `langchain4j-qdrant` |
| Weaviate | Hybrid search | `spring-ai-weaviate-store` | `langchain4j-weaviate` |
| In-memory | Tests / prototypes | `SimpleVectorStore` | `InMemoryEmbeddingStore` |
