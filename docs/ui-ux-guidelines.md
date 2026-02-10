# UI & UX Guidelines

> **Last Updated:** February 7, 2026
> **Implementation Status:** Core UI complete with native macOS patterns

## Design Principles

- **Focus on Content:** Prioritize reading and note-taking surfaces; minimal chrome
- **Contextual Actions:** Commands relevant to current selection in toolbar
- **Fluid Navigation:** Quick switching between PDFs, notes, and collections
- **Mac-Native Feel:** Follow macOS idioms with SwiftUI modern components

## Layout

### Primary Window ✅

Three-pane NavigationSplitView layout:

```
┌─────────────┬──────────────────┬─────────────────────────────┐
│  Sidebar    │  Content List    │  Detail View                │
│  (200pt)    │  (flexible)      │  (400pt min)                │
├─────────────┼──────────────────┼─────────────────────────────┤
│ Library     │ Document/Note    │ PDF Viewer or               │
│ • All Docs  │ list with        │ Markdown Editor             │
│ • All Notes │ thumbnails and   │                             │
│             │ selection        │ + Info Popover (toolbar)    │
│ Collections │ highlighting     │ + Optional Inspector        │
│ Tags        │                  │   (HSplitView)              │
└─────────────┴──────────────────┴─────────────────────────────┘
```

### Sidebar ✅
- **Library Section:** All Documents, All Notes (with stable counts)
- **Collections Section:** User-created folders with icons, renamable via right-click, drag-and-drop document targets with visual feedback
- **Tags Section:** Color-coded tags with counts, renamable via right-click

### Search Bar ✅
- Two search modes via picker: Filename and Content
- Debounced input with clear button
- Progress indicator during search
- Search results view with thumbnails, snippets, and page numbers

### Content List ✅
- Document rows with thumbnail (32x40px), title, collection badge, file size, relative date, tag badges
- Note rows with icon, title, preview text, pin indicator, relative date
- Selection binding with visual highlighting
- Drag-and-drop import support with visual feedback
- Compact date formatting ("Today", "2d", "3mo", "1y")
- **Status Bar:** Item count and formatted library storage size
- **Context Menu (right-click):**
  - Rename: Inline text field editing
  - Delete: Confirmation dialog
  - Tags: Submenu to toggle tags on/off
  - Add to Collection: Exclusive assignment (one collection per document)

### Detail View ✅
- HSplitView containing main content + optional inspector
- Dynamically shows PDF viewer or Markdown editor based on selection
- Empty state when nothing selected

## PDF Experience ✅

### Viewer Layout
- Full PDF rendering via PDFKit
- Optional thumbnail sidebar (toggleable via View Options menu)
- No in-view toolbars - all controls in native window toolbar

### Native Toolbar Controls
| Control | Description |
|---------|-------------|
| Page Navigation | ◀ Page X/Y ▶ |
| Annotation Tools | Segmented picker: Select, Highlight, Underline, Note |
| Color Picker | Current color circle → popover with 6 color options |
| Zoom | −/+ buttons, percentage menu (50%-200%, Fit to Width) |
| View Options | Menu: Single/Continuous/Two-Up, Toggle Thumbnails |
| Info Button | ⓘ icon → popover with document metadata |

### Info Popover ✅
Accessible via info circle icon in toolbar (disabled when no document selected):
- **Editable Fields:** Title, Subtitle, Authors (comma-separated)
- **Read-only Fields:** Pages, Filename, Added date, Modified date
- **Tags Display:** Color-coded tag badges with flow layout
- **Done Button:** Saves changes and dismisses popover

### Annotation Colors
- Yellow (default), Green, Blue, Pink, Orange, Purple
- Displayed as circles in popover grid

### Implemented Features
- ✅ Thumbnails sidebar with page selection
- ✅ Page navigation with keyboard shortcuts
- ✅ Zoom controls with presets
- ✅ Display modes (single, continuous, two-up)
- ✅ Highlight annotations with color selection
- ✅ Clear all annotations

### Planned Features
- 🚧 Table of contents navigation
- 🚧 Annotation list in inspector
- 🚧 Create note from selection context menu
- 🚧 Split view (PDF + linked note)

## Markdown Experience ✅

### Editor Layout
- **Title Bar:** Editable title field, preview toggle, save button (when dirty)
- **Formatting Toolbar:** H1, H2, bullet list, numbered list, code block, blockquote (with hover effects)
- **Editor:** TextEditor with monospace font (SF Mono), scrollable, auto-focus
- **Preview:** Live preview pane (toggleable) with AttributedString rendering
- **Status Bar:** Word/character count, saving indicator, last saved time, unsaved changes warning

### Implemented Features
- ✅ Basic text editing with monospace font (SF Mono)
- ✅ Formatting toolbar (H1, H2, bullet list, numbered list, code block, blockquote)
- ✅ Live preview with AttributedString rendering
- ✅ Auto-save with 2-second debounce
- ✅ Manual save (⌘S) with indicator
- ✅ Word and character count
- ✅ Note templates (Blank, Literature Review, Meeting Notes)
- ✅ Note pinning (toggle to top of list)
- ✅ Wikilink syntax (`[[noteTitle]]`)

### Planned Features
- 🚧 Slash command menu for advanced formatting
- 🚧 Inline image previews
- 🚧 Backlinks panel
- 🚧 Outgoing links visualization

## Keyboard Shortcuts

### Implemented
| Shortcut | Action |
|----------|--------|
| ⌘I | Import Documents |
| ⌘N | New Note |
| ⌘S | Save Note |
| ⌥⌘I | Toggle Inspector |
| ⌫ | Delete selected document/note (with confirmation) |

### Planned
| Shortcut | Action |
|----------|--------|
| ⌃⌥Space | Quick Capture (global) |
| ⌘L | Link to Selection |
| ⌘D | Toggle Split View |
| ⌘F | Focus Search |
| ⌃⇥ | Switch Tab |

## Theming & Accessibility ✅

### Implemented
- System-aware light/dark mode (SwiftUI automatic)
- Standard system colors and materials
- VoiceOver compatibility via SwiftUI semantics

### Planned
- Reader mode with typography controls
- High-contrast theme option
- Dynamic Type scaling verification

## Empty States ✅

### No Documents
```
┌─────────────────────────────────┐
│         📥 (large icon)        │
│                                 │
│       No Documents              │
│                                 │
│  Drop PDF files here or use     │
│  the Import button              │
│                                 │
│  [Import PDF]  [New Note]       │
└─────────────────────────────────┘
```

### No Notes
```
┌─────────────────────────────────┐
│         📝 (large icon)        │
│                                 │
│         No Notes                │
│                                 │
│  Create a note to get started   │
│                                 │
│        [New Note]               │
└─────────────────────────────────┘
```

### No Selection (Detail Pane)
```
┌─────────────────────────────────┐
│         📄 (large icon)        │
│                                 │
│  Select a Document or Note      │
│                                 │
│  Choose an item from the list   │
│  to view it here                │
└─────────────────────────────────┘
```

## Component Reference

| Component | File | Purpose |
|-----------|------|---------|
| LookPrimaryView | LookKit.swift | Main three-pane container with toolbar |
| LibrarySidebarView | LibrarySidebarView.swift | Sidebar navigation with rename, drag-and-drop targets |
| ContentSearchBar | ContentAreaView.swift | Search bar with filename/content mode picker |
| ContentListView | LookKit.swift | Document/note list with search |
| ContentListStatusBar | ContentAreaView.swift | Item count and storage size display |
| SearchResultsListView | ContentAreaView.swift | Unified search results with snippets |
| DetailAreaView | LookKit.swift | PDF/editor + inspector |
| DocumentListView | ContentAreaView.swift | Document row list with thumbnails |
| DocumentRow | ContentAreaView.swift | Single document with thumbnail, collection badge, tags |
| NoteListView | ContentAreaView.swift | Note row list with pin indicators |
| ThumbnailImageView | ContentAreaView.swift | Async thumbnail loader with fallback |
| PDFViewerView | PDFViewerView.swift | PDF rendering with native toolbar |
| MarkdownEditorView | MarkdownEditorView.swift | Note editing with formatting toolbar |
| FormatIconButton | MarkdownEditorView.swift | Toolbar buttons with hover effects |
| MarkdownPreviewView | MarkdownEditorView.swift | Live preview with AttributedString |
| DocumentInfoPopover | ContentAreaView.swift | Editable document metadata |
| InspectorPanelView | InspectorPanelView.swift | Metadata panel (document/note) |
| NewNoteSheet | ContentAreaView.swift | Note creation dialog |

## Onboarding ✅

### Library Setup Flow
1. Welcome screen with app description
2. "Choose Library Location" button
3. Folder picker (NSOpenPanel)
4. Library directory structure created automatically
5. Main UI appears with empty state

### Planned
- 🚧 First-run tour
- 🚧 Sample library option
- 🚧 Inline tips for advanced features
- 🚧 Help menu with documentation
