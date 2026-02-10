# Architecture Overview

> **Last Updated:** February 7, 2026
> **Implementation Status:** Core architecture complete, MVP features functional

## System Components

| Component | Description | Status |
|-----------|-------------|--------|
| **LookApp** | SwiftUI-based shell with window management, commands, AppKit integration | ✅ Implemented |
| **LookKit** | Shared UI components, view models, environment values | ✅ Implemented |
| **LookPDF** | PDFKit wrappers, annotation rendering, viewer controls | ✅ Implemented |
| **LookNotes** | Markdown editor with live preview, auto-save | ✅ Implemented |
| **LookData** | Core Data persistence, services, file coordination | ✅ Implemented |
| **LookAutomation** | Shortcuts, AppleScript handlers, Quick Capture | 🚧 Not Started |

## Data Flow

```text
File Import → LookData ImportService → Library Storage (PDFs/<uuid>/)
           → Core Data entities created (Document, metadata)
           → UI refreshes via Combine publishers

PDF Viewing → PDFViewerViewModel loads document
           → AnnotationService provides highlight data
           → PDFKit renders with overlay annotations

Note Editing → NoteEditorViewModel manages state
            → Auto-save to Core Data + .md file
            → DocumentService handles persistence
```

## Persistence Strategy

### Core Data Model ✅
Entities (7): `Document`, `Note`, `Annotation`, `DocumentCollection`, `Tag`, `Attachment`, `Link`
(SmartRule entity removed to simplify sidebar)

**Key Implementation Details:**
- Collection entity renamed to `DocumentCollection` (avoids Swift stdlib conflict)
- Annotation rects stored as Binary (JSON-serialized `[[String: Double]]`)
- Merge policies: view context uses `NSMergeByPropertyObjectTrumpMergePolicy`

### SQLite FTS5 🚧
- Tables planned: `fts_documents`, `fts_notes`, `fts_annotations`
- Not yet implemented - manual browsing works for MVP

### File Storage ✅
```text
Library Root/
├── PDFs/<doc-uuid>/document.pdf
├── Notes/<note-uuid>.md
├── Attachments/<attachment-uuid>/<filename>
├── Index/
│   ├── Look.sqlite (Core Data)
│   └── Thumbnails/<doc-uuid>.png (80x100px)
└── Cache/
    └── Previews/
```

### Security-Scoped Bookmarks ✅
- `LibraryRootStore` manages persistent access to user-selected library root
- Bookmark stored in UserDefaults, restored on app launch

## Services

| Service | Purpose | Status |
|---------|---------|--------|
| **ImportService** | PDF validation, deduplication (SHA-256), metadata extraction, OCR detection | ✅ Implemented |
| **DocumentService** | CRUD for documents/notes, metadata editing, storage calculation, content search | ✅ Implemented |
| **CollectionService** | Collection/tag management, document associations, exclusive collection assignment | ✅ Implemented |
| **AnnotationService** | Highlight creation, persistence, coordinate storage | ✅ Implemented |
| **ThumbnailService** | PDF thumbnail generation (80x100px), caching in Index/Thumbnails/ | ✅ Implemented |
| **LibraryRootStore** | Security bookmarks, directory management | ✅ Implemented |
| **OCRService** | VisionKit text extraction | 🚧 Planned |
| **SearchService** | FTS5 indices, query APIs | 🚧 Planned |
| **LinkService** | Note-to-annotation bidirectional links | 🚧 Planned |
| **AutomationService** | Shortcuts, AppleScript | 🚧 Planned |

## Third-Party & System Frameworks

**Currently Used:**
- SwiftUI - Primary UI framework
- PDFKit - PDF rendering and annotations
- Combine - Reactive data binding
- Core Data - Persistence
- UniformTypeIdentifiers - Content typing
- OSLog - Structured logging (`LookLogger`)

**Planned:**
- Vision/VisionKit - OCR
- GRDB or custom SQLite wrapper - FTS5 search

## View Architecture

### Three-Pane Layout ✅
```
┌─────────────┬──────────────────┬─────────────────────────────┐
│  Sidebar    │  Content List    │  Detail View                │
│             │                  │                             │
│ • Library   │ • Document rows  │ • PDF Viewer                │
│ • Collections│   w/ thumbnails │   - Native toolbar          │
│ • Tags      │ • Note rows      │   - Annotation tools        │
│             │ • Selection      │   - Zoom/page controls      │
│             │   highlighting   │   - Info popover            │
│             │ • Context menus  │ • Markdown Editor           │
│             │                  │   - Live preview            │
│             │                  │ • Inspector (optional)      │
└─────────────┴──────────────────┴─────────────────────────────┘
```

**Implementation:**
- `LookPrimaryView` - NavigationSplitView container with info popover
- `LibrarySidebarView` - Left pane navigation with rename context menus, drag-and-drop collection targets
- `ContentSearchBar` - Search bar with filename/content mode picker, debounced input
- `ContentListView` - Middle pane with search, document/note lists, status bar
- `SearchResultsListView` - Unified search results with thumbnails, snippets, page numbers
- `ContentListStatusBar` - Item count and formatted storage size
- `DetailAreaView` - Right pane with HSplitView for inspector
- `PDFViewerView` - PDF rendering with native toolbar
- `MarkdownEditorView` - Note editing with formatting toolbar and live preview
- `DocumentInfoPopover` - Editable metadata popover

### Environment Values ✅
Custom environment keys for dependency injection:
- `contentAreaDocumentHandler` - PDF viewer factory
- `contentAreaNoteHandler` - Note editor factory
- `contentAreaDropHandler` - Drag-drop import handler

### Content Search ✅
- Two search modes: filename (client-side filter) and content (Core Data predicate)
- `ContentSearchBar` with mode picker, debounced input, clear button, progress indicator
- `SearchResultsListView` for unified results with thumbnails and snippets
- `DocumentService.searchNoteContent()` for server-side content search

## Error Handling & Resilience

**Implemented:**
- Background Core Data contexts with merge policies
- Centralized alerts via `LibraryRootCoordinator.activeAlert`
- OSLog categories: persistence, library, import, telemetry
- Graceful handling of missing files (placeholder views)

**Planned:**
- NSFileCoordinator for external file changes
- OCR failure recovery with manual retry

## Performance Considerations

**Implemented:**
- Lazy thumbnail loading with caching (`PDFViewerViewModel.thumbnailCache`)
- PDF page disposal when not visible (PDFKit default behavior)
- Efficient list rendering with SwiftUI List
- Precomputed document thumbnails in Index/Thumbnails/ via `ThumbnailService`
- Thumbnail generation on import (80x100px PNG)

**Planned:**
- Background indexing queue
- Memory monitoring for large PDFs

## Module Dependencies

```
LookApp
├── LookKit (UI components, view models)
├── LookData (persistence, services)
├── LookPDF (PDF viewer, annotations)
└── LookNotes (Markdown editor)

LookKit
└── LookData (models only)

LookPDF
└── LookData (AnnotationService)

LookNotes
└── LookData (DocumentService)
```

## Extensibility

- Protocol-based service interfaces allow future swapping
- `FeatureFlags` in LookKit for experimental capabilities
- Clear module boundaries for potential iPad expansion
- Environment-based dependency injection for testability
