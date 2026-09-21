---
name: architecture-design-patterns
description: Guidelines and patterns for software architecture, system decomposition, Clean/Hexagonal architecture, and Gang of Four design patterns.
---

# Software Architecture & Design Patterns Skill

## 1. System Architecture Styles
- **Hexagonal / Clean / Ports & Adapters**:
  - Core domain logic has zero external dependencies.
  - Ports define abstract interfaces for inputs (driving ports) and outputs (driven ports).
  - Adapters implement specific technologies (REST API, database, message broker, third-party services).
- **Modular Monolith**:
  - Organize by bounded context / domain feature instead of technical layer.
  - Public APIs between modules; internal package structures remain encapsulated.
- **Event-Driven & Messaging**:
  - Asynchronous event emission for loose coupling.
  - Idempotent consumers and outbox pattern for reliable message delivery.

## 2. Gang of Four (GoF) & Structural Patterns
- **Creational**:
  - *Factory Method / Abstract Factory*: Decouple object creation from business logic.
  - *Builder*: Construct complex objects step-by-step with validation.
  - *Dependency Injection*: Pass dependencies through constructors or interfaces; never hardcode instantiations.
- **Structural**:
  - *Adapter*: Convert incompatible interfaces without modifying existing code.
  - *Facade*: Provide a simplified interface to a complex subsystem.
  - *Decorator / Middleware*: Dynamically attach responsibilities or cross-cutting concerns (logging, auth, metrics).
  - *Composite*: Treat individual objects and compositions uniformly.
- **Behavioral**:
  - *Strategy*: Interchangeable algorithms behind a common interface.
  - *Observer / PubSub*: Decoupled one-to-many event notification.
  - *Command*: Encapsulate requests as objects (enabling undo, queueing, or transactional execution).
  - *Chain of Responsibility*: Pass requests along a chain of handlers.

## 3. Resilience, Concurrency & Reliability
- **Circuit Breaker & Retry**: Exponential backoff with jitter for transient external failures.
- **Idempotency**: Use idempotency keys for write operations to prevent duplicate mutations.
- **Graceful Degradation**: Fallback defaults when non-critical downstream services fail.
