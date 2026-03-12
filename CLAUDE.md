# CLAUDE.md — XjTTY-KitchenSink Project Context

> อัปเดตโดย @documentator · 2026-03-13 (Phase 5)

---

## Project Purpose

**XjTTY-KitchenSink** is a fullscreen TUI console application (Xojo) that showcases all 31 components in the **XjTTY-Toolkit** library. It serves as an interactive browser, live-demo tool, and reference for developers learning the toolkit.

- Library lives in: `XjTTYLib/` (59 `.xojo_code` files — do NOT modify)
- App source files: `KSApp`, `KSComponentEntry`, `KSComponentRegistry`, `KSPreviewBuilder` (Phase 4)
- Spec: `KITCHEN_SINK_PROPOSAL.md`

---

## Team Roles & Workflow

This project uses a **structured multi-role agent team**. Each phase follows the cycle:

```
@lead  →  @dev  →  Human Review  →  @documentator  →  /sccs
```

### @lead — Lead Architect
- Plans each phase before implementation begins
- Defines architecture, file structure, API contracts
- Delegates implementation tasks to @dev
- Reviews @dev output for correctness before human review
- Does NOT write implementation code

### @dev — Developer
- Implements code per @lead's specification
- Follows Xojo 2025 conventions (see Xojo-Specific Notes below)
- Writes clean, minimal code — no speculative features
- Flags blockers to @lead immediately

### Human — Code Reviewer
- Reviews each phase output before milestone is committed
- Has final say on code quality and correctness
- Approves before /sccs runs

### @documentator — Documentation & Code Commentary
- Writes and maintains: `README.md`, `CLAUDE.md`, `CHANGELOG.md`, `DEV_CODE_WALKTHROUGH.md`
- Adds **bilingual Thai/English inline comments** to all source files
- Proficient in both software development and Thai editorial writing
- Comments describe *why*, not just *what*
- Thai comments target: Thai developer reading the codebase for the first time

**Comment format in source code:**
```xojo
// [EN] Build the constraint-based layout tree for the 4-panel UI
// [TH] สร้างโครงสร้าง layout แบบ constraint สำหรับ UI 4 ส่วนหลัก
```

---

## Current Project Status

| Phase | Name | Status |
|-------|------|--------|
| Setup | Team infrastructure, docs, git | ✅ Done |
| Scaffold | KSApp rename, XjTTYLib attached to project | ✅ Done |
| Phase 1 | Skeleton (layout shell, event loop) | ✅ Done |
| Phase 2 | Component Registry + Tree Navigation | ✅ Done |
| Phase 3 | Search + Autocomplete | ✅ Done |
| Phase 4 | Static Previews (KSPreviewBuilder + 3 preview widgets) | ✅ Done |
| Phase 5 | Interactive Previews (Tab focus zone + 4 live demos) | ✅ Done |
| Phase 6 | Polish (help overlay, edge cases) | ⬜ Pending |

---

## Architecture Decisions

### File Structure (current source files)
```
KitchenSink.xojo_project      — console app project file
KSApp.xojo_code               — App class: event loop, layout tree, key routing, tree navigation, preview widgets
KSComponentEntry.xojo_code    — Data class: 6 public fields per component (Name, Category, ShortDesc, LongDesc, Keywords, IsInteractive)
KSComponentRegistry.xojo_code — Module: Init() + 31 entries; Categories(), EntriesForCategory(), EntryAt(), Count(), Search()
KSPreviewBuilder.xojo_code    — Module: stateless factory; LoadInto(entry, titleText, bodyText, propsTable) populates all 3 preview widgets
KSInteractiveLoader.xojo_code — Module: maps entry → demo type ("textinput"|"progressbar"|"spinner"|"keyevent"|"mockup"|"")
XjTTYLib/                     — library (read-only, 59 files)
```

### Layout Architecture
4-panel fullscreen layout using `XjLayoutNode` / `XjBox`:
1. Header (fixed height: 3)
2. Search bar (fixed height: 3)
3. Main area (auto): Component list (25%) | Preview + Properties (75%)
4. Status bar (fixed height: 1)

Minimum terminal size: 80×24. Guard in resize handler.

### Key Design Patterns
- **Parallel flat arrays**: `mFlatNodes() As XjTreeNode` and `mFlatEntries() As KSComponentEntry` mirror XjTree's internal flat list. `mFlatEntries(i)` is `Nil` for category header rows. O(1) cursor→entry lookup.
- **Tree highlight**: Change `node.SetNodeStyle(...)` then call `mListTree.SetScrollOffset(mScrollOffset)` to mark XjTree dirty — no rebuild needed.
- **Scroll visible height**: `mTermHeight - 11` (not `-9`). Breakdown: mRoot border(2) + header(3) + searchBar(3) + statusBar(1) + componentList border(2) = 11.
- **Registry Init guard**: `KSComponentRegistry.mInitialized` prevents double-population. Call `Init()` freely; it no-ops after first call.
- **Two-mode key routing**: `mSearchMode As Boolean` in KSApp. List mode: `↑↓` navigate, `/` activates search, `q` quits. Search mode: printable keys → `mSearchInput.HandleKey()` → `ApplySearch()`; `↑↓` still navigate filtered list; `Esc` restores full tree.
- **Shared tree builder**: `RebuildTree(entries() As KSComponentEntry)` is called by both `PopulateTree()` (all 31) and `ApplySearch()` (filtered subset). Categories with no matching entries are omitted automatically.
- **XjTextInput focus**: Call `SetFocused(True)` before routing keys to XjTextInput — it returns False without processing if `mFocused = False`.
- **Search**: `KSComponentRegistry.Search(query)` uses `Instr(field.Lowercase, query.Lowercase) > 0` across Name, ShortDesc, Keywords, Category.
- **Static preview pattern** (Phase 4): Pre-build `mPreviewTitle` (XjText, Fixed(1), cyan+bold), `mPreviewBody` (XjText, auto, wrap), and `mPropsTable` (XjTable, 2 cols, col-0 width=12) at startup. On navigation call `KSPreviewBuilder.LoadInto(entry, mPreviewTitle, mPreviewBody, mPropsTable)` — no widget rebuild needed, just update content via `SetText()` / `ClearRows()` + `AddRow()`.
- **⚠️ No RemoveAllChildren on XjWidget/XjBox** — confirmed by reading XjWidget.xojo_code. Use persistent pre-built widgets and update content instead of swapping child widgets.
- **Interactive demo pattern** (Phase 5): All 4 demo widgets (`mDemoInput`, `mDemoBar`, `mDemoSpinnerWidget`, `mDemoKeyText`) pre-built at startup with `SetHeight(Fixed(0))`. `ActivateDemoWidget(type)` reveals one by setting its height to a positive Fixed value; others stay at 0. Tab enters preview focus; Esc returns to list. `HandleTick` drives spinner/bar animation.
- **Three focus zones** (Phase 5): `mSearchMode=True` → search; `mPreviewFocus=True` → live demo; default → list navigation. Tab in list mode enters preview only when `mDemoType` is a live demo type.
- **XjSpinner / XjProgressBar tick**: Must call `widget.HandleTick(tickCount)` manually from `KSApp.HandleTick()` — the render pipeline does NOT call HandleTick on child widgets automatically.
- **Rendering**: ~30fps via `XjEventLoop(33)`. Full clear+paint each tick.
- **RemoveAll for arrays**: Use `.RemoveAll` to clear dynamic arrays (confirmed in XjTree source).

---

## Xojo-Specific Notes & Gotchas

- **Entry point class is `KSApp`** — Xojo boilerplate defaults to `App`; renamed to match `KS` prefix convention
- **No modification to XjTTYLib** — it's a library dependency, not project code
- **⚠️ IDE drops Module entries from .xojo_project** — When attaching a folder in Xojo IDE, `Class=` entries are preserved correctly but `Module=` entries either get path `../../../../../../..` or disappear entirely. Must be manually corrected in `KitchenSink.xojo_project` with paths like `XjTTYLib/XjANSI.xojo_code`. Affects: XjTerminal, XjScreen, XjANSI, XjLayoutSolver, XjColor, XjSymbols, XjCursor, XjFont, XjYAML, XjConversion, XjPlatform, XjCommand, XjMarkdown, XjUIParser, XjPrompt, XjWhich
- **⚠️ `(New XjStyle).Method()` is a syntax error** — Xojo does not allow method calls on temporary `New` expressions. Always assign first: `Var s As New XjStyle` then `Var s2 As XjStyle = s.SetFG(...)`.
- **⚠️ XjStyle chaining requires variables** — Each `Set*` returns a new XjStyle instance (immutable builder). Break chains into named variables: `Var withCyan As XjStyle = base.SetFG(...)` then `Var final As XjStyle = withCyan.SetBold()`.
- **Delegate wiring** uses `AddressOf` — ensure method signatures match exactly
- **XjTreeNode** children added before calling `mListTree.SetData(roots)` — tree rebuilds from root array
- **XjTree has no built-in navigation** — `HandleKey` in XjTree always returns False for arrow keys. KSApp must handle UP/DOWN directly and call `SetScrollOffset` manually.
- **Prompt previews are MOCKUPS** (Phase 4) — prompts conflict with the event loop; render as styled XjText
- **`q` or Ctrl+C to quit** — both must be handled in key handler
- **`XjTerminal.Width()` / `XjTerminal.Height()`** — checked on resize and initial render
- **Xojo module properties** — module-level `Private` properties act as module globals (used in KSComponentRegistry for mEntries/mInitialized)

---

## Running the App

```bash
# Open in Xojo IDE
./xojo.sh open KitchenSink.xojo_project

# Check for compilation errors
./xojo.sh analyze

# Run
./xojo.sh run
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `KITCHEN_SINK_PROPOSAL.md` | Full project specification (source of truth) |
| `README.md` | User-facing project overview |
| `CHANGELOG.md` | Version history (Keep a Changelog format) |
| `DEV_CODE_WALKTHROUGH.md` | Code walkthrough for new developers |
| `TEAM_WORKFLOW.md` | Team roles, phase checklist, review protocol |
| `XjTTYLib/` | TUI toolkit library (59 components) |
