<!--
SYNC IMPACT REPORT
==================
Version change: 1.0.0 → 1.1.0
Modified principles: None
Added sections:
  - Principle IX. Documentation Language Requirements
Removed sections: None
Templates requiring updates:
  - .specify/templates/plan-template.md: ✅ No updates required (template structure
    unchanged; generated plans will be in zh-TW per new principle)
  - .specify/templates/spec-template.md: ✅ No updates required (template structure
    unchanged; generated specs will be in zh-TW per new principle)
  - .specify/templates/tasks-template.md: ✅ No updates required (template structure
    unchanged; generated tasks will be in zh-TW per new principle)
  - .specify/templates/checklist-template.md: ✅ No updates required (generic template)
  - .specify/templates/agent-file-template.md: ✅ No updates required (generic template)
Follow-up TODOs: None
==================
-->

# Blue-Green Deployment Constitution

## Core Principles

### I. Code Quality

All code MUST meet professional quality standards ensuring maintainability, readability, and correctness.

- Code MUST follow consistent naming conventions (descriptive, intention-revealing names)
- Functions MUST have a single responsibility and be no longer than 30 lines (excluding
  documentation)
- Cyclomatic complexity MUST NOT exceed 10 per function
- Code duplication MUST be avoided; DRY (Don't Repeat Yourself) principle enforced
- All public APIs MUST have clear documentation describing purpose, parameters, and return values
- Magic numbers and strings MUST be replaced with named constants
- Dead code MUST be removed immediately upon discovery

### II. Testing Standards

Comprehensive testing is MANDATORY to ensure system reliability and enable confident refactoring.

- Minimum code coverage: 80% line coverage, 70% branch coverage
- Unit tests MUST be isolated, fast (<100ms each), and deterministic
- Integration tests MUST verify component interactions and external dependencies
- Contract tests MUST validate API boundaries between services
- All tests MUST be automated and run in CI/CD pipeline
- Flaky tests MUST be fixed or removed within 48 hours of identification
- Test code MUST receive the same quality attention as production code

### III. Behavior Driven Development (BDD)

Features MUST be specified and validated using behavior-driven scenarios that bridge
business and technical understanding.

- All user stories MUST include acceptance criteria in Given/When/Then format
- Scenarios MUST be written in domain language understandable by stakeholders
- Automated acceptance tests MUST map directly to specified scenarios
- Feature files MUST be maintained as living documentation
- Each scenario MUST test one specific behavior (no multi-behavior scenarios)
- Edge cases and error conditions MUST have explicit scenarios

### IV. Domain Driven Design (DDD)

System architecture MUST reflect the business domain, ensuring code structure mirrors
business concepts and language.

- Ubiquitous Language MUST be established and used consistently across code, tests,
  and documentation
- Bounded Contexts MUST be clearly defined with explicit boundaries
- Aggregates MUST encapsulate business rules and ensure consistency
- Domain entities MUST be rich objects with behavior, not anemic data containers
- Value Objects MUST be immutable and compared by value
- Domain events MUST capture significant business occurrences
- Repository interfaces MUST be defined in the domain layer (implementation in infrastructure)

### V. SOLID Principles

All object-oriented code MUST adhere to SOLID principles to ensure maintainability
and extensibility.

- **Single Responsibility**: Each class/module MUST have one reason to change
- **Open/Closed**: Code MUST be open for extension, closed for modification
- **Liskov Substitution**: Derived classes MUST be substitutable for their base classes
- **Interface Segregation**: Clients MUST NOT depend on interfaces they don't use
- **Dependency Inversion**: High-level modules MUST NOT depend on low-level modules;
  both MUST depend on abstractions

### VI. Infrastructure Layer Isolation

Frameworks and external dependencies MUST be confined to the infrastructure layer,
keeping the domain and application layers framework-agnostic.

- Domain layer MUST contain zero framework imports or dependencies
- Application layer MUST depend only on domain abstractions, not concrete implementations
- Infrastructure layer MUST implement interfaces defined by inner layers
- Framework-specific annotations MUST NOT appear in domain entities
- Database access, HTTP clients, message queues MUST be implemented in infrastructure only
- Dependency injection MUST flow inward (infrastructure → application → domain)
- Changing frameworks MUST NOT require changes to domain or application logic

### VII. User Experience Consistency

All user-facing interfaces MUST provide a consistent, intuitive, and accessible experience.

- UI components MUST follow established design system patterns
- Error messages MUST be user-friendly, actionable, and consistent in tone
- Loading states and feedback MUST be present for all asynchronous operations
- Keyboard navigation MUST be supported for all interactive elements
- Response times for user interactions MUST NOT exceed defined thresholds (see Performance)
- Accessibility standards (WCAG 2.1 AA) MUST be met for all public interfaces
- Progressive disclosure MUST be used to manage complexity

### VIII. Performance Requirements

System performance MUST meet defined benchmarks to ensure responsive user experience
and efficient resource utilization.

- API response times: p50 < 100ms, p95 < 500ms, p99 < 1000ms
- Page load times: First Contentful Paint < 1.5s, Time to Interactive < 3s
- Memory usage MUST NOT exceed defined limits per service
- Database queries MUST be optimized; N+1 queries are prohibited
- Batch operations MUST implement pagination or streaming for large datasets
- Performance regression tests MUST be included in CI/CD pipeline
- Resource cleanup MUST be guaranteed (no memory leaks, connection leaks)

### IX. Documentation Language Requirements

All project documentation MUST follow defined language standards to ensure consistency
and accessibility for the target audience.

- Feature specifications (spec.md) MUST be written in Traditional Chinese (zh-TW)
- Implementation plans (plan.md) MUST be written in Traditional Chinese (zh-TW)
- User-facing documentation MUST be written in Traditional Chinese (zh-TW)
- Task lists (tasks.md) MUST be written in Traditional Chinese (zh-TW)
- This Constitution MUST remain in English as the authoritative governance document
- Code comments and inline documentation MAY be in English for international compatibility
- API documentation for public interfaces SHOULD include English translations

## Quality Gates

All code changes MUST pass these gates before merging:

| Gate | Criteria | Enforcement |
|------|----------|-------------|
| Static Analysis | Zero critical/high issues | Automated CI check |
| Test Coverage | Meets minimum thresholds | Automated CI check |
| BDD Scenarios | All acceptance tests pass | Automated CI check |
| Performance | No regression beyond 10% | Automated CI check |
| Code Review | Approved by qualified reviewer | PR requirement |
| Documentation | Public APIs documented | Manual verification |

## Development Workflow

### Test-Driven Development Cycle

1. Write failing acceptance test (BDD scenario)
2. Write failing unit test
3. Implement minimum code to pass tests
4. Refactor while keeping tests green
5. Commit with meaningful message

### Code Review Standards

- Reviews MUST verify principle compliance (SOLID, DDD, layer isolation)
- Reviews MUST check for security vulnerabilities (OWASP Top 10)
- Reviews MUST validate test coverage and quality
- Reviews SHOULD complete within one business day

### Continuous Integration Requirements

- All tests MUST pass before merge
- Static analysis MUST report no new violations
- Build artifacts MUST be reproducible
- Deployment MUST be automated and reversible (blue-green capability)

## Governance

This Constitution supersedes all other development practices within this project.

- **Amendments**: Changes require documented proposal, team review, and explicit approval
- **Versioning**: Constitution follows semantic versioning (MAJOR.MINOR.PATCH)
  - MAJOR: Backward-incompatible principle changes or removals
  - MINOR: New principles or material expansions
  - PATCH: Clarifications, typo fixes, non-semantic refinements
- **Compliance Review**: All PRs MUST verify compliance with these principles
- **Exceptions**: Temporary exceptions require documented justification and remediation plan
- **Complexity Justification**: Any deviation from simplicity MUST be documented with rationale

**Version**: 1.1.0 | **Ratified**: 2025-12-04 | **Last Amended**: 2025-12-04
