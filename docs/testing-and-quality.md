# Testing & Quality Strategy

> **Last Updated:** February 7, 2026
> **Implementation Status:** Strategy defined, tests not yet implemented

## Quality Goals

- Reliable handling of large libraries (10k+ documents)
- Stable PDF annotation linking
- Crash-free user experience
- Strong accessibility support

## Current Quality Status

### Working Reliably ✅
- PDF import with deduplication (file picker and drag-and-drop)
- Document/note browsing with thumbnails and filtering
- PDF viewing with zoom, navigation, and display modes
- Markdown editing with formatting toolbar, auto-save, and live preview
- PDF highlighting with auto-highlight on selection (6 color presets)
- Collection and tag management (create, rename, delete, assign)
- Document context menus (rename, delete, tags, collections)
- Content search (filename and content modes)
- Document info popover (editable metadata)
- Document thumbnails (generated on import, cached)
- Note pinning and wikilink syntax
- Drag-and-drop documents to collections
- Status bar with storage calculation
- Light/dark mode

### Needs Testing 🚧
- Performance with 100+ documents
- Memory usage with large PDFs
- Edge cases in annotation persistence
- Error recovery scenarios
- Search accuracy with special characters
- Thumbnail regeneration reliability

## Test Pyramid (Planned)

### Unit Tests
| Area | Priority | Status |
|------|----------|--------|
| ImportService (validation, deduplication) | High | 🚧 Planned |
| DocumentService (CRUD operations) | High | 🚧 Planned |
| AnnotationService (coordinate handling) | High | 🚧 Planned |
| CollectionService (tag management) | Medium | 🚧 Planned |
| ThumbnailService (generation, validation, caching) | Medium | 🚧 Planned |
| LibraryRootStore (bookmark persistence) | Medium | 🚧 Planned |

### Integration Tests
| Flow | Priority | Status |
|------|----------|--------|
| Import → View → Annotate → Save | High | 🚧 Planned |
| Create Note → Edit → Save → Reload | High | 🚧 Planned |
| Tag/Collection assignment | Medium | 🚧 Planned |
| Library restore after relaunch | Medium | 🚧 Planned |

### UI Tests (XCUITest)
| Path | Priority | Status |
|------|----------|--------|
| Library setup flow | High | 🚧 Planned |
| PDF import via drag & drop | High | 🚧 Planned |
| Document selection and viewing | High | 🚧 Planned |
| Note creation and editing | High | 🚧 Planned |
| Highlight creation | Medium | 🚧 Planned |

### Performance Tests
| Scenario | Target | Status |
|----------|--------|--------|
| Import 50MB PDF | <5 seconds | 🚧 Needs verification |
| Load 100 document library | <2 seconds | 🚧 Needs verification |
| Render 500-page PDF | Smooth scroll | 🚧 Needs verification |
| Memory with 10 open PDFs | <500MB | 🚧 Needs verification |

## Test Data & Fixtures

### Planned Test Assets
- Sample PDFs (text-based, scanned, large, encrypted)
- Markdown notes with various content
- Pre-populated library for import testing
- Edge case documents (corrupt, very large, many pages)

### Test Library Structure
```
TestFixtures/
├── PDFs/
│   ├── simple-text.pdf
│   ├── scanned-document.pdf
│   ├── large-500-pages.pdf
│   ├── encrypted.pdf
│   └── corrupt.pdf
├── Notes/
│   ├── basic.md
│   ├── with-links.md
│   └── templates/
└── Libraries/
    ├── empty/
    ├── small-10-docs/
    └── medium-100-docs/
```

## Automation (Planned)

### CI Pipeline
- [ ] Build verification on PR
- [ ] Unit test execution
- [ ] SwiftLint/SwiftFormat checks
- [ ] Code coverage reporting (target: >80%)

### Pre-commit Hooks
- [ ] Fast unit tests
- [ ] Code formatting
- [ ] Build verification

### Nightly Runs
- [ ] Full integration test suite
- [ ] Performance benchmarks
- [ ] Memory leak detection

## Manual QA Checklist

### Core Workflows
- [ ] First launch and library setup
- [ ] Import PDF via file picker
- [ ] Import PDF via drag & drop
- [ ] Browse document list (thumbnails, tags, dates)
- [ ] Open and navigate PDF
- [ ] Create highlight annotation (auto-highlight on selection)
- [ ] Create new note with template
- [ ] Edit and save note (auto-save and ⌘S)
- [ ] Use formatting toolbar (headings, lists, code, quote)
- [ ] Toggle live preview
- [ ] Create collection and assign documents
- [ ] Drag document to collection in sidebar
- [ ] Assign and remove tags
- [ ] Rename document/collection/tag via context menu
- [ ] Delete document with confirmation
- [ ] Search by filename
- [ ] Search by content
- [ ] Edit document metadata via info popover
- [ ] Pin/unpin a note
- [ ] Relaunch and verify persistence

### Edge Cases
- [ ] Import duplicate PDF
- [ ] Import corrupt PDF
- [ ] Open very large PDF (500+ pages)
- [ ] Create note with empty title
- [ ] Delete document with annotations
- [ ] Switch library locations

### Accessibility
- [ ] VoiceOver navigation
- [ ] Keyboard-only operation
- [ ] High contrast mode
- [ ] Reduced motion

## Known Issues

### Current
- None documented yet - needs systematic testing

### Fixed
- Three-pane layout PDF placement (fixed 2026-02-01)
- Duplicate sidebar toggles (fixed 2026-02-01)
- Selection highlighting in lists (fixed 2026-02-01)
- PDF highlighting not working — auto-highlight on selection with debounce (fixed 2026-02-01)
- Sidebar counts changing when filtering by collection/tag (fixed 2026-02-07)
- `Collection` entity renamed to `DocumentCollection` to avoid Swift stdlib conflict (fixed 2026-02-07)
- `Annotation.rects` changed from Transformable to Binary for JSON serialization (fixed 2026-02-07)
- `Alert.Button` initializer updated to proper SwiftUI API (fixed 2026-02-07)
- State propagation: `@Published libraryURL` with Combine subscription for UI reactivity (fixed 2026-02-07)

## Release Validation

### Pre-Release Checklist
- [ ] All manual QA items pass
- [ ] No crash reports in testing
- [ ] Performance targets met
- [ ] Version bump completed
- [ ] Release notes drafted
- [ ] App notarized
- [ ] Sparkle feed updated (if applicable)

### Post-Release Monitoring
- Crash logs (if opted-in)
- Support inbox triage
- GitHub issues monitoring
- Patch release criteria defined
