# Agents & Responsibilities

## Product & Research

- **Product Strategist**
  - Owns overall vision, roadmap prioritization, and success metrics (see `docs/product-spec.md` and `docs/implementation-roadmap.md`).
  - Keeps persona definitions current and validates feature scope against user feedback.
- **Research Librarian**
  - Curates sample libraries, verifies workflows for importing, tagging, and smart groups.
  - Supplies regression datasets for QA and ensures documentation reflects real researcher needs.

## Engineering

- **Platform Architect**
  - Maintains system architecture (`docs/architecture.md`), module boundaries, and build tooling.
  - Reviews technical decisions affecting performance, security, or extensibility.
- **Data & Persistence Engineer**
  - Implements Core Data schema, FTS indices, and file layout per `docs/data-model.md` and `docs/storage-and-security.md`.
  - Oversees migrations, integrity checks, and backup/restore tooling.
- **PDF Experience Engineer**
  - Delivers PDF reader, annotation tooling, OCR integration, and highlight-note linking.
  - Collaborates with Note Experience Engineer to maintain anchor fidelity.
- **Note Experience Engineer**
  - Builds Markdown editor, backlink engine, templating, and automation hooks.
  - Ensures interoperability with PDF highlights and collection/tag systems.
- **Automation & Extensions Engineer**
  - Implements Shortcuts, share extensions, Quick Capture, and AppleScript features.
  - Coordinates with QA to script end-to-end automation tests.

## Quality & Operations

- **Quality Lead**
  - Enforces testing strategy (`docs/testing-and-quality.md`), maintains CI pipelines, and tracks defect trends.
  - Oversees accessibility, localization, and performance benchmarks.
- **Security & Privacy Officer**
  - Audits storage, encryption, and compliance commitments (`docs/storage-and-security.md`).
  - Handles incident response procedures and data export requests.
- **Documentation Steward**
  - Keeps README and `docs/` contents up to date with shipping software.
  - Coordinates release notes, onboarding guides, and in-app help content.

## Governance

- **Program Manager**
  - Facilitates cross-functional planning, sprint rituals, and milestone reviews.
  - Maintains alignment between roadmap phases and resource allocation.
- **Advisory Board**
  - Provides periodic assessments on research trends, ensures product direction stays relevant, and signs off on major pivots.
