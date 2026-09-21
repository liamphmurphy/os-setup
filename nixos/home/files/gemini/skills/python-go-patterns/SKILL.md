---
name: python-go-patterns
description: Idiomatic design patterns, architecture best practices, and concurrency models for Python and Go engineering.
---

# Python & Go Engineering Patterns Skill

## 1. Python Engineering Standards

### Structural Typing & Contracts
- Use `typing.Protocol` for structural subtyping (duck typing with static checking) over deep inheritance.
- Use `pydantic.BaseModel` (or `@dataclass(slots=True)`) for data validation, serialization, and immutable value objects.
- Explicit type annotations on all function signatures (`typing.Optional`, `typing.Union` / `|`, `typing.Sequence`, `typing.Mapping`).

### Idiomatic Patterns
- **Repository & Unit of Work**: Abstract database queries behind repository interfaces to allow seamless in-memory testing.
- **Dependency Injection**: Inject dependencies through constructor `__init__` arguments; utilize frameworks like FastAPI dependency injection or lightweight factories.
- **Context Managers**: Encapsulate resource acquisition and release using `@contextlib.contextmanager` or class `__enter__`/`__exit__`.
- **Async Concurrency**: Use `asyncio.TaskGroup` (Python 3.11+) or `asyncio.gather` for parallel I/O. Never block the event loop with synchronous file/network I/O; delegate CPU-bound work to `asyncio.to_thread` or `ProcessPoolExecutor`.

---

## 2. Go Engineering Standards

### Idiomatic Go Design
- **Accept Interfaces, Return Structs**: Keep interfaces small (1-3 methods) and define them where they are consumed, not where they are implemented.
- **Functional Options Pattern**: Use functional options for constructing structs with optional configuration:
  ```go
  type Option func(*Server)
  func WithTimeout(d time.Duration) Option {
      return func(s *Server) { s.timeout = d }
  }
  func NewServer(opts ...Option) *Server { ... }
  ```

### Concurrency & Lifecycle
- **Context Propagation**: Always pass `ctx context.Context` as the first parameter to functions performing I/O. Respect cancellation via `ctx.Done()`.
- **Safe Goroutine Management**: Never fire-and-forget goroutines without lifecycle management. Use `sync.WaitGroup`, channels, or `golang.org/x/sync/errgroup` for parallel work with error propagation.
- **Data Race Prevention**: Protect shared mutable state with `sync.Mutex` / `sync.RWMutex`, or communicate by sharing memory through channels.

### Error Handling & Testing
- Wrap errors with contextual details using `fmt.Errorf("operation failed: %w", err)`.
- Inspect error types using `errors.Is` and `errors.As`.
- Use **table-driven tests** with descriptive test case names and `t.Parallel()` where appropriate:
  ```go
  tests := []struct {
      name    string
      input   string
      wantErr bool
  }{ ... }
  for _, tt := range tests {
      t.Run(tt.name, func(t *testing.T) { ... })
  }
  ```
