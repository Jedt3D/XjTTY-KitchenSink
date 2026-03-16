# Changelog

All notable changes to XjTTY-KitchenSink are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [0.8.0] — 2026-03-17

### Added — Batch 1: Widget Demos (XjText, XjTable, XjTree)

- **XjText live demo** (`"text"` type): pre-built XjText widget with sample paragraph;
  keys `l`/`c`/`r` switch alignment (left/center/right), `w` toggles word wrap;
  status bar shows current alignment and wrap state
- **XjTable live demo** (`"table"` type): pre-built XjTable with 4-row sample dataset
  (programming languages); keys `b` toggles border visibility, `h` toggles header row;
  Fixed(8) height to fit table content
- **XjTree live demo** (`"tree"` type): pre-built XjTree with hierarchical sample data
  (Animals → Mammals/Birds/Fish); Up/Down arrow keys scroll through nodes;
  Fixed(6) height with scroll offset tracking
- `KSInteractiveLoader.DemoTypeFor`: 3 new Case entries mapping XjText→`"text"`,
  XjTable→`"table"`, XjTree→`"tree"`
- `KSComponentRegistry`: set `IsInteractive=True` for XjText and XjTable
  (XjTree was already interactive)

### Fixed — Trace Trap Crash on macOS Tahoe

- **Root cause**: `XjCell.Reset()` allocated a new `XjStyle` per call — at 4800 cells × 30fps
  that was 144,000 allocations/second. macOS Tahoe's xzone malloc detected the resulting
  heap fragmentation as corruption and killed the process with SIGTRAP.
- **Fix applied in XjTTY-Toolkit** (upstream commit `3c9afca`):
  - `XjStyle.ResetToDefault()`: new method resets all 15 style fields in-place
  - `XjStyle.CopyFrom()`: made public for direct use by XjCell
  - `XjCell.Reset()`: reuses existing XjStyle via `ResetToDefault()` instead of `New XjStyle`
  - `XjCell.SetStyle()`: uses `CopyFrom()` instead of `Clone()` to avoid per-call allocation
  - `XjCanvas.Render()`: rewritten from single ~10,000-entry array to per-row string building

### Added — Batch 4: Complex Prompt Overlays (XjSelectPrompt, XjMultiSelectPrompt, XjSuggestPrompt, XjCollectPrompt)

- **XjSelectPrompt overlay** (`"select"` type): arrow-key navigated list with `❯` marker
  and inverse highlight; 5 sample items (React, Vue, Angular, Svelte, Ember); Enter selects
- **XjMultiSelectPrompt overlay** (`"multiselect"` type): checkbox list with `■`/`□` markers;
  Space toggles, `a` selects all, `n` selects none; Enter confirms (requires ≥1 selected)
- **XjSuggestPrompt overlay** (`"suggest"` type): text input with filtered dropdown from
  10 color names; typing filters suggestions, Tab accepts highlighted item, Up/Down navigate
  visible list (max 5), Enter confirms
- **XjCollectPrompt overlay** (`"collect"` type): 3-step wizard — Step 1: text input (name),
  Step 2: Y/N confirm (terms), Step 3: select from list (language); completed steps show `✔`
- New properties: `mSelectIndex`, `mSelectChecked()`, `mCollectStep`, `mCollectAnswers()`,
  `mSuggestFiltered()` for complex prompt state management
- `InitBatch4State()`: type-specific state initializer for multiselect/suggest/collect
- `UpdateSuggestFilter()`: filters suggestion list based on typed input

### Added — Batch 3: Simple Prompt Overlays (XjConfirmPrompt, XjKeyPressPrompt, XjExpandPrompt, XjAskPrompt, XjEnumSelectPrompt)

- **XjConfirmPrompt overlay** (`"confirm"` type): shows `? Are you sure? (Y/n)`;
  press Y or N to settle with green checkmark answer
- **XjKeyPressPrompt overlay** (`"keypress"` type): shows `? Press any key to continue...`;
  any key settles and displays the key name
- **XjExpandPrompt overlay** (`"expand"` type): collapsed `(ynadh)` key choices;
  press `h` to expand full list, then select with y/n/a/d keys
- **XjAskPrompt overlay** (`"ask"` type): text input with cursor; type name, Enter settles
  (requires non-empty input); Backspace deletes
- **XjEnumSelectPrompt overlay** (`"enum"` type): numbered list of 4 log levels;
  press 1–4 digit to select and settle
- Shared prompt overlay infrastructure: `mPromptState` (0=active, 1=settled),
  `mPromptInput`, `mPromptAnswer`, `mExpandExpanded`
- `BuildPromptOverlayLines()`: dispatcher routing `mDemoType` to per-prompt builders

### Added — Batch 2: Rendered-Output Demos (XjPie, XjStyle, XjColor, XjCanvas)

- **XjPie overlay demo** (`"pie"` type): pie chart with 3 switchable datasets
  (Languages, Browsers, OS); keys `1`/`2`/`3` switch datasets; shows colored slices
  with percentages and legend
- **XjStyle overlay demo** (`"style"` type): ANSI style showcase displaying bold, dim,
  italic, underline, strikethrough, inverse, blink, and color combinations
- **XjColor overlay demo** (`"color"` type): 16 standard ANSI colors displayed as
  colored blocks with labels; foreground and background pairs
- **XjCanvas overlay demo** (`"canvas"` type): rendered canvas concept art showing
  block-character drawing with box-drawing frame
- `RenderDemoOverlay()`: generalized overlay renderer using ANSI cursor positioning;
  draws bordered box with title, content lines, and hint row over the preview area
- `mOverlayLines() As String`: shared overlay content buffer used by all overlay demos

### Added — Project Walkthrough

- `KitchenSink Walk Through.md`: comprehensive project walkthrough covering architecture,
  source files, layout system, event loop, key routing, component registry, demos, and
  design patterns

---

## [0.7.1] — 2026-03-16

### Fixed — Compilation Error from Stale Library References

- **Removed `ExportModule` and `ThemeModule`** from `KitchenSink.xojo_project` — these were
  accidentally pulled in when the Xojo IDE re-attached XjTTYLib from the shared toolkit path
  (`../xojo-ttytoolkit/XjTTYLib/`). `ExportModule` depends on `DBManager`, a class that belongs
  to the separate `XjTTY-SQLiteBackup` project, causing 5 compilation errors:
  - `Can't find a type with this name` on all functions accepting `DBManager` parameter
  - `Parameter "Line" expects type String, but this is type No Type` on `stream.WriteLine`
- **Root cause**: the previous commit switched XjTTYLib references from local copies
  (`XjTTYLib/*.xojo_code`) to the shared toolkit (`../xojo-ttytoolkit/XjTTYLib/`). The Xojo IDE
  picked up every `.xojo_code` file in that folder — including `ExportModule` and `ThemeModule`
  which are toolkit-internal and not needed by KitchenSink.

### Changed — Project Restructuring

- **Project renamed**: `KitchenSink.xojo_project` → `XjTTYKitchenSink.xojo_project`
- **XjTTYLib local copies removed**: 59 local `.xojo_code` files replaced with a macOS Alias
  pointing to `../xojo-ttytoolkit/XjTTYLib/`; project file references updated to relative paths
- **KSApp.xojo_code**: renamed `DIM` variable to `dimStyle` (avoids collision with Xojo keyword);
  extracted intermediate row-number variables for ANSI cursor positioning in `RenderHelp()`

---

## [0.7.0] — 2026-03-13

### Added — Phase 6: Polish

- **Help overlay** (`?` key): centered cyan-bordered box drawn directly on top of the
  running UI using ANSI cursor positioning (`ESC[row;colH`). Lists all keyboard shortcuts.
  Any key press dismisses it. `mShowHelp As Boolean` tracks state; `RenderHelp()` method
  calls `Render()` first then overlays the box without touching the widget tree.
- **Category jump** (`1`–`6`): pressing a digit key jumps directly to the first node of
  that category header in the component list. Scans `mFlatEntries` for Nil entries (category
  rows) and calls `SelectLine(i)` on the Nth match. Works in list mode only.
- **Page Up / Page Down**: scroll the component list by one visible page
  (`mTermHeight - 11` rows). Added as `KEY_PAGEUP` / `KEY_PAGEDOWN` cases in `HandleListKey`.
- **Home / End**: jump to the first or last item in the component list.
  Added as `KEY_HOME` / `KEY_END_` cases in `HandleListKey`.
- **keysHint updated**: status bar right-side hint now reads
  `"/ Search  Up/Dn  ?Help  q Quit"` (width adjusted from 30 → 32)

---

## [0.6.2] — 2026-03-13

### Changed — btop-Inspired Color Theme

- **Panel borders**: all five `SetBorder` calls now use `cyanBorder` (`FG_CYAN`) —
  root, searchBar, componentList, previewArea, propertiesPanel frames are now teal,
  matching btop's muted teal box-drawing aesthetic
- **Selected list item**: highlight changed from `SetInverse()` to
  `BG_MAGENTA + FG_WHITE` — the hot-pink selected-row look from btop
- **Key hint** (`/ Search  Up/Dn Nav  q Quit`): now styled `FG_BRIGHT_BLACK` (dim gray)
  to visually recede like btop's secondary labels
- Theme style variables (`cyanBorder`, `dimHint`) built once at top of
  `BuildWidgetTree()` from a shared `themeBase As New XjStyle`

---

## [0.6.1] — 2026-03-13

### Fixed — Search Mode UX

- **Tab from search mode**: pressing `Tab` while the search input is active now exits
  search mode first (calls `ExitSearchMode()`), then falls through to list-mode Tab
  handling — entering the preview demo widget in one keypress instead of requiring
  `Esc` then `Tab`
- **Selection preserved on search exit**: `ExitSearchMode()` now saves the currently
  selected `KSComponentEntry` before `PopulateTree()` rebuilds the full tree, then
  finds and re-selects it by name; applies to both `Esc` and `Tab` exits; falls back
  to line 0 only if no entry was selected or a category header was active

---

## [0.6.0] — 2026-03-13

### Added — Phase 5: Interactive Previews

- `KSInteractiveLoader.xojo_code`: stateless module with `DemoTypeFor(entry) As String` —
  maps interactive components to demo types: `"textinput"` | `"progressbar"` | `"spinner"` |
  `"keyevent"` | `"mockup"` | `""`; prompt classes are blocking/modal and return `"mockup"`
- **Three focus zones** in `KSApp.HandleKey`:
  - **List mode** (default): `↑↓` navigate, `/` search, `Tab` enters demo (when available), `q` quit
  - **Preview focus mode** (`mPreviewFocus=True`): keys route to active demo widget; `Esc` returns to list
  - **Search mode** (`mSearchMode=True`): unchanged from Phase 3
- **4 pre-built demo widgets** (all start at `Fixed(0)` height, `ActivateDemoWidget` reveals one):
  - `mDemoInput` (XjTextInput): type freely in preview; activated by XjTextInput entry
  - `mDemoBar` (XjProgressBar): `+`/`=` +10%, `-` −10%, `r`/Space reset; activated by XjProgressBar
  - `mDemoSpinnerWidget` (XjSpinner): "dots" format, auto-animates via `HandleTick`; activated by XjSpinner
  - `mDemoKeyText` (XjText, 4 rows): shows KeyCode, Char, and modifier for last key; activated by XjKeyEvent
- `ActivateDemoWidget(demoType As String)`: collapses all 4 demo widgets, reveals matching one by swapping height constraint; resets `mPreviewFocus` on type change
- `DemoKeyHint(demoType) As String`: returns context-sensitive key hint for status bar
- `KitchenSink.xojo_project`: registered `KSInteractiveLoader` module

### Changed

- `KSApp.HandleTick`: now calls `mDemoSpinnerWidget.HandleTick` / `mDemoBar.HandleTick` before rendering when those demo types are active
- `KSApp.SelectLine`: calls `KSInteractiveLoader.DemoTypeFor(entry)` + `ActivateDemoWidget(demoType)`; status bar appends `"   Tab: enter demo"` hint for live-demo entries
- `KSPreviewBuilder.LoadInto`: updated interactive notice from "Phase 5 will wire..." to "Press Tab to enter the live demo panel."
- `KSApp` class comment updated to document Phase 5 three-zone routing

### Technical Note

- `XjSpinner` / `XjProgressBar` require explicit `HandleTick(tickCount)` calls — the render pipeline (`mRoot.Paint`) does **not** propagate ticks to child widgets automatically.
- Widget "show/hide" implemented via `SetHeight(Fixed(0))` / `SetHeight(Fixed(n))` — confirmed safe since `XjLayoutSolver.Solve` re-evaluates constraints every frame.

---

## [0.5.0] — 2026-03-13

### Added — Phase 4: Static Previews

- `KSPreviewBuilder.xojo_code`: stateless factory module with `LoadInto(entry As KSComponentEntry, titleText As XjText, bodyText As XjText, propsTable As XjTable)` — populates all three preview widgets from a single component entry; truncates keywords to 40 chars with ellipsis; appends interactive notice for Phase-5 components
- `KSApp.mPreviewTitle` (XjText): 1-row header widget in livePreview, fixed height 1, ANSI cyan+bold, center-aligned; shows `"Name  [Category]"`
- `KSApp.mPreviewBody` (XjText): auto-height body widget in livePreview, word-wrap enabled, left-aligned; shows long description + keywords
- `KSApp.mPropsTable` (XjTable): 2-column property sheet in propertiesPanel, headers ["Property", "Value"], column 0 fixed at 12 chars; rows: Name, Category, Interactive, Keywords
- `KitchenSink.xojo_project`: registered `KSPreviewBuilder` module

### Changed

- `KSApp.SelectLine()`: now calls `KSPreviewBuilder.LoadInto(entry, mPreviewTitle, mPreviewBody, mPropsTable)` on each navigation step; category rows clear all three preview widgets
- `KSApp.ApplySearch()`: no-match branch now clears all three preview widgets (`SetText("")`, `ClearRows()`)
- `KSApp.BuildWidgetTree()`: replaced single `mCurrentLabel` XjText with three dedicated preview widgets built at startup
- Removed `mCurrentLabel` property; added `mPreviewTitle`, `mPreviewBody`, `mPropsTable`

### Technical Note

- Confirmed: `XjWidget` / `XjBox` have **no `RemoveAllChildren`** method — child-swapping is impossible. Phase 4 uses persistent pre-built widgets updated in-place, avoiding any widget-tree mutation after startup.

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
