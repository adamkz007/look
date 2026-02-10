# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Look is a native macOS + iPadOS research workspace that combines PDF reading with Markdown note-taking and deep linking between the two. All data is stored locally with privacy-first defaults. The app is built using SwiftUI with modular frameworks and Core Data persistence. Shared frameworks compile for both platforms via `#if canImport(AppKit)` / `#if canImport(UIKit)` conditional compilation.

## Build & Development Commands

Since this is an Xcode project without Package.swift or traditional build tools, development is done through Xcode:

- **Open Project:** Open `Look.xcodeproj` or `Look.xcworkspace` in Xcode
- **Build:** Use Xcode's build command (Cmd+B) or `xcodebuild` if Xcode is installed
- **Run:** Use Xcode's run command (Cmd+R)

**Note:** The project requires Xcode (not just Command Line Tools) to build and run. If `xcodebuild` fails with a "requires Xcode" error, the project must be opened and built through Xcode IDE.

## Architecture

The codebase uses a modular architecture with distinct frameworks:

### Module Boundaries

- **LookApp** – Main macOS target, app entry point, window management, and SwiftUI shell
 - Entry point: `Sources/LookApp/Sources/LookApp.swift`
 - Handles library location selection flow via `LibraryRootCoordinator`
 - Integrates all other frameworks

- **LookApp_iPad** – iPadOS target, app entry point, touch-optimized UI shell
 - Entry point: `Sources/LookApp_iPad/Sources/LookApp_iPad.swift`
 - Uses `UIDocumentPickerViewController` for PDF import
 - Auto-creates library in app Documents directory
 - Full feature parity with macOS version

- **LookKit** – Shared cross-platform UI components, view models, and SwiftUI utilities
 - Contains `FeatureFlags` for toggling experimental capabilities
 - Provides reusable UI components (document browser, tag pickers, split views)
 - `PlatformCompat.swift`: Type aliases (`PlatformImage`, `PlatformColor`) and cross-platform helpers

- **LookData** – Persistence layer with Core Data + SQLite FTS
  - Core Data model: `Sources/LookData/Resources/LookModel.xcdatamodeld`
  - `PersistenceController` manages Core Data stack with merge policies and background contexts
  - `LibraryRootStore` handles security-scoped bookmarks for sandboxed file access
  - Logging via `LookLogger` (OSLog wrapper with categories: persistence, library, telemetry)

- **LookPDF** – PDFKit integration, annotation logic, OCR orchestration
  - `PDFAnnotationBridge` handles annotation coordinate mapping

- **LookNotes** – Markdown editing, backlink engine, templates
  - `NoteTemplateRegistry` manages Markdown templates

- **LookAutomation** – Shortcuts, AppleScript handlers, Quick Capture
  - `ShortcutActions` exposes automation capabilities

### Data Flow

```
File Import → LookData Importer → Library Storage
          → LookPDF processes PDF (OCR + text extraction)
          → Indexer updates FTS + vector store
          → LookNotes links highlights ↔ notes through AnchorService
UI uses ObservedObject wrappers over LookData entities via Combine publishers
```

## Core Data Model

Located in `Sources/LookData/Resources/LookModel.xcdatamodeld`:

**Key Entities (7):**
- `Document` – PDF metadata, checksum, OCR status, page count
- `Note` – Markdown body, frontmatter, backlinks (derived)
- `Annotation` – Highlights/annotations with normalized coordinates, text snippets
- `DocumentCollection` – Manual folders and bundles (renamed from `Collection` to avoid Swift stdlib conflict)
- `Tag` – Hierarchical tags with color
- `Attachment` – Note-linked assets
- `Link` – Relationships between notes, annotations, documents

**Note:** `SmartRule` entity was removed to simplify the sidebar to Library/Collections/Tags.

**Merge Policies:**
- View context: `NSMergeByPropertyObjectTrumpMergePolicy`
- Background contexts: `NSMergeByPropertyStoreTrumpMergePolicy`

## File Storage Layout

Library root contains:
```
Library Root/
├── PDFs/<doc-uuid>/document.pdf
├── Notes/<note-uuid>.md
├── Attachments/<attachment-uuid>/<original-filename>
├── Index/
│   ├── Look.sqlite (Core Data)
│   ├── Search.sqlite (FTS5)
│   └── Thumbnails/
└── Cache/
    ├── OCR/<doc-uuid>.json
    └── Previews/<doc-uuid>-<page>.jpg
```

All file access uses security-scoped bookmarks for sandbox compliance.

## Logging

Use `LookLogger` instances for structured logging via OSLog:
- `LookLogger.persistence` – Core Data operations
- `LookLogger.libraryRoot` – Library location and file operations
- `LookLogger.telemetry` – Analytics and diagnostics

Create new loggers: `LookLogger(category: "your-category")`

## Development Phase

**Current Status:** Active MVP development — core research workflow functional. See `STATUS.md` for detailed progress.

**Implementation Status:**
1. Phase 0 (Weeks 1-2): Project foundations – ✅ **COMPLETE** (Core Data model, file layout, logging, feature flags, telemetry)
2. Phase 1 (Weeks 3-5): Library & Import – ✅ **COMPLETE** (Import service, deduplication, UI integration, document browser)
3. Phase 2 (Weeks 6-9): PDF Workspace – ✅ **COMPLETE** (PDF viewer, annotations with auto-highlight, color presets, persistence)
4. Phase 3 (Weeks 10-13): Markdown Notes – ✅ **COMPLETE** (Editor with live preview, formatting toolbar, auto-save, templates)
5. Phase 4 (Weeks 14-18): Linking & Search – 🚧 **IN PROGRESS** (Content search implemented, note-PDF linking pending)
6. Phase 5 (Weeks 19-22): UX Polish & Extensibility – 🚧 **PARTIALLY COMPLETE** (Native toolbar, thumbnails, context menus, info popover done; inspector enhancement pending)
7. Phase 6 (Weeks 23-26): Testing & Release Prep – NOT STARTED

**Working Features:**
- Three-pane UI with native macOS toolbar (sidebar, content list, detail view)
- PDF import with deduplication, metadata extraction, and drag-and-drop
- PDF viewing with thumbnails sidebar, zoom presets, page navigation, display modes
- PDF annotations: highlight/underline tools, 6 color presets, auto-highlight on selection, Core Data persistence
- Markdown editor with live preview, formatting toolbar (H1/H2/lists/code/quote), auto-save, word count
- Note templates (Literature Review, Meeting Notes)
- Content search (filename and content modes) with results view
- Collections with exclusive assignment, tags with colors
- Document context menus (rename, delete, tags, collections)
- Document thumbnails (80×100px, cached, generated on import)
- Document info popover with editable metadata
- Status bar with item count and storage size
- Light/dark mode support

Refer to `STATUS.md` for complete feature list and session log.

## Key Documentation

The `docs/` directory contains comprehensive design specifications:
- `product-spec.md` – Functional requirements and research workflows
- `architecture.md` – System components, services, data flow
- `data-model.md` – Complete entity definitions and file layout
- `storage-and-security.md` – Security-scoped bookmarks, encryption, privacy
- `testing-and-quality.md` – Test pyramid, automation, QA strategy
- `ui-ux-guidelines.md` – Design patterns and UX conventions
- `implementation-roadmap.md` – Phase-by-phase development plan
- `ipados-setup.md` – iPadOS target setup instructions and feature parity checklist

**Always consult relevant docs before implementing features.**

## Services Architecture

### Implemented Services
- **ImportService** (`LookData/Sources/ImportService.swift`) – PDF import, SHA-256 deduplication, metadata extraction, OCR detection
- **DocumentService** (`LookData/Sources/DocumentService.swift`) – CRUD for documents and notes, metadata editing, storage calculation, content search
- **CollectionService** (`LookData/Sources/CollectionService.swift`) – Collection/tag management, exclusive assignment, document-tag associations
- **AnnotationService** (`LookData/Sources/AnnotationService.swift`) – Highlight/note creation, color presets, coordinate storage, bulk operations
- **ThumbnailService** (`LookData/Sources/ThumbnailService.swift`) – PDF thumbnail generation (80×100px PNG), validation, caching, bulk regeneration
- **LibraryRootStore** (`LookData/Sources/LibraryRootStore.swift`) – Security-scoped bookmarks, directory management

### Pending Services (Documented in `docs/architecture.md`)
- `OCRService` – VisionKit integration for text extraction
- `SearchService` – FTS5 indices, ranking heuristics, query APIs (basic content search exists in DocumentService)
- `LinkService` – Note-to-annotation bidirectional links, backlinks
- `AutomationService` – Shortcuts, Quick Capture, AppleScript
- `SyncMonitor` – File system event reconciliation with Core Data

When implementing these, follow protocol-based design for testability and future extensibility.

## Coding Conventions

- Use SwiftUI for all UI components; AppKit only where necessary (e.g., NSOpenPanel)
- Background Core Data operations use `newBackgroundContext()` from `PersistenceController`
- Wrap file operations in `NSFileCoordinator` / `NSFilePresenter` to avoid race conditions
- Lazy-load heavy views (PDF pages) using `@StateObject` caches
- OSLog categories for all logging (never print/NSLog)
- Feature flags via `FeatureFlags` in LookKit for experimental capabilities

## Error Handling

- Log errors via `LookLogger` with appropriate severity (error, fault)
- Graceful fallbacks for OCR failures or encrypted PDFs (surface status to user)
- Conflict logging for Core Data merge policy violations
- Centralized error handling with user-facing alerts via `LibraryRootCoordinator.activeAlert`

## Security & Privacy

- All metadata stored locally; optional SQLCipher encryption for Core Data stores
- Security-scoped bookmarks required for library root access (sandboxed)
- Sensitivity flags to mask documents from QuickLook previews
- SHA-256 checksums for deduplication and integrity verification
- No cloud dependencies or telemetry without explicit opt-in

## Testing Strategy

From `docs/testing-and-quality.md`:
- **Unit Tests:** XCTest for services and Core Data helpers
- **Integration Tests:** End-to-end flows with in-memory libraries
- **UI Tests:** XCUITest for critical paths (import, annotate, link, search)
- **Performance Tests:** Stress PDF rendering, OCR, search indexing
- **Automation:** CI with `xcodebuild test`, SwiftLint, >80% code coverage goal

**Note:** No tests exist yet; this is the target strategy.

## Third-Party Dependencies

Planned (not all integrated yet):
- PDFKit (Apple framework) – PDF rendering and annotations
- Vision/VisionKit (Apple framework) – OCR
- Combine (Apple framework) – Reactive data binding
- SQLite with FTS5 – Full-text search (via GRDB or custom wrapper)
- markdown/Down/Ink – Markdown parsing

Use Swift Package Manager for third-party libraries when needed.
