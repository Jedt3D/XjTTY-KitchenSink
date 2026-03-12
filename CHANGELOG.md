# Changelog

All notable changes to XjTTY-KitchenSink are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Phase 6 — Polish *(pending)*
- Help overlay (`?` key)
- Category jump shortcuts (`1`–`6`)
- Page Up/Down, Home/End in component list
- Smooth animations (spinner, progress bounce)
- Edge case handling: rapid resize, empty search, boundary values

### Phase 5 — Interactive Previews *(pending)*
- Live key routing to preview widgets (focus zone 3)
- XjBox, XjText, XjTextInput, XjTable, XjProgressBar, XjSpinner, XjTree interaction
- XjFont (type to change), XjPie (adjust slices), XjStyle (cycle colors), XjKeyEvent (live display)

### Phase 4 — Static Previews *(pending)*
- KSPreviewBuilder: all 31 component preview builders
- Prompt mockups (styled text representation of each prompt)
- Reference cards: XjCanvas, XjEventLoop, XjConstraint, XjLayoutNode, XjLayoutSolver
- Properties table populated per component


---

## [0.4.0] — 2026-03-13

### Added — Phase 3: Search

- `KSComponentRegistry.Search(query As String) As KSComponentEntry()` — case-insensitive
  substring match across Name, ShortDesc, Keywords, and Category fields; empty query
  returns empty array (caller decides display behaviour)
- `KSApp.mSearchInput` (XjTextInput) embedded in searchBar panel with placeholder
  "Press / to search components..."
- Two-mode key routing in `KSApp.HandleKey`:
  - **List mode** (default): `↑↓` navigate tree, `/` activates search, `q`/Ctrl+C quit
  - **Search mode**: printable keys feed `mSearchInput`; `↑↓`/Enter still navigate the
    filtered list; `Esc` exits search and restores the full component tree
- `KSApp.ApplySearch(query)` — live tree filtering; status bar shows "N of 31 match"
  or "No matches"; empty categories hidden automatically
- `KSApp.EnterSearchMode()` / `ExitSearchMode()` — XjTextInput focus lifecycle
- `KSApp.RebuildTree(entries() As KSComponentEntry)` — shared tree builder extracted
  from `PopulateTree()`; eliminates duplicate tree-construction logic; skips categories
  with no matching entries

### Changed

- `KSApp.PopulateTree()` refactored to delegate to `RebuildTree(allEntries)` rather than
  building the tree inline — single code path for both full and filtered views
- searchBar `SetTitle(" Search ")` added so the border panel is labelled

---

## [0.3.0] — 2026-03-13

### Added — Phase 2: Component Registry & Navigation
- `KSComponentEntry.xojo_code`: data class with 6 public fields — Name, Category, ShortDesc,
  LongDesc, Keywords, IsInteractive — plus a single constructor for registry use
- `KSComponentRegistry.xojo_code`: module with idempotent `Init()` populating all 31 components
  across 6 categories (Layout 4 · Widgets 6 · Prompts 9 · Style 4 · I/O 4 · Utility 4);
  exposes `Categories()`, `EntriesForCategory()`, `EntryAt()`, `Count()`
- `KSApp.xojo_code`: XjTree wired into component list panel with full Up/Down navigation;
  parallel flat arrays `mFlatNodes / mFlatEntries` for O(1) cursor→entry lookup;
  `PopulateTree()`, `SelectLine()`, `HandleListKey()` methods added;
  status bar description updates live on every navigation step;
  `mCurrentLabel` (XjText) in livePreview shows selected component name
- `KitchenSink.xojo_project`: registered `KSComponentEntry` (Class) and
  `KSComponentRegistry` (Module)

### Fixed
- **Syntax error**: `(New XjStyle).Method()` is not valid Xojo — intermediate objects must be
  assigned to named variables before chaining; all three occurrences corrected
- **Scroll cut-off**: visible height formula was `mTermHeight - 9`; corrected to
  `mTermHeight - 11` (accounts for mRoot border + componentList border = 2 extra rows);
  previously hid the last 2 items in the component list

---

## [0.2.0] — 2026-03-13

### Added — Phase 1: Skeleton
- `KSApp.xojo_code`: full implementation with 4-panel layout, XjEventLoop (33ms/~30fps),
  resize guard (min 80×24), `q`/Ctrl+C quit, and render pipeline
- Bilingual [EN]/[TH] inline comments added to `KSApp.xojo_code` by @documentator
- **Verified:** App launches fullscreen at 83×25, all panels render correctly
  (XjTTY-Toolkit Kitchen Sink, Components, Preview, Properties borders + titles)

### Fixed
- `KitchenSink.xojo_project`: restored 15 missing `Module=` entries with correct
  relative paths (`XjTTYLib/XjTerminal.xojo_code`, etc.) — Xojo IDE drops module
  references when attaching a folder, silently breaking all XjTTYLib module calls

---

## [0.1.1] — 2026-03-13

### Changed — Project Scaffold Finalized
- Renamed `App.xojo_code` → `KSApp.xojo_code`; class `App` → `KSApp` to match `KS` prefix convention
- Updated `KitchenSink.xojo_project` entry point reference from `App` to `KSApp`
- All 59 `XjTTYLib/` components attached to project by user (referenced in `.xojo_project`)

---

## [0.1.0] — 2026-03-13

### Added — Team Setup & Project Scaffold
- Initialized git repository
- Created `README.md` — user-facing project overview
- Created `CLAUDE.md` — project context for AI-assisted development
- Created `CHANGELOG.md` — this file
- Created `DEV_CODE_WALKTHROUGH.md` — developer onboarding guide
- Created `TEAM_WORKFLOW.md` — team roles, phase checklist, review protocol
- Defined team roles: @lead, @dev, Human reviewer, @documentator
- Established bilingual Thai/English documentation convention
- Source of truth: `KITCHEN_SINK_PROPOSAL.md` (636 lines, 6-phase plan)
- Library ready: `XjTTYLib/` (59 components, 512K)
