# CLAUDE.md — XjTTY-KitchenSink Project Context

> อัปเดตโดย @documentator · 2026-03-13

---

## Project Purpose

**XjTTY-KitchenSink** is a fullscreen TUI console application (Xojo) that showcases all 31 components in the **XjTTY-Toolkit** library. It serves as an interactive browser, live-demo tool, and reference for developers learning the toolkit.

- Library lives in: `XjTTYLib/` (59 `.xojo_code` files — do NOT modify)
- App source files: `KSApp`, `KSComponentRegistry`, `KSPreviewBuilder`, `KSStatusBar`
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
| Phase 2 | Component Registry + Tree Navigation | ⬜ Pending |
| Phase 3 | Search + Autocomplete | ⬜ Pending |
| Phase 4 | Static Previews (29 components) | ⬜ Pending |
| Phase 5 | Interactive Previews (15 components) | ⬜ Pending |
| Phase 6 | Polish (help overlay, edge cases) | ⬜ Pending |

---

## Architecture Decisions

### File Structure (5 source files)
```
KitchenSink.xojo_project   — console app project file
KSApp.xojo_code            — App class: event loop, layout tree, key routing (~400 lines)
KSComponentRegistry.xojo_code — 31 component entries with metadata (~300 lines)
KSPreviewBuilder.xojo_code — preview builders for all 31 components (~800 lines)
KSStatusBar.xojo_code      — status bar renderer (~60 lines)
XjTTYLib/                  — library (read-only)
```

### Layout Architecture
4-panel fullscreen layout using `XjLayoutNode` / `XjBox`:
1. Header (fixed height: 3)
2. Search bar (fixed height: 3)
3. Main area (auto): Component list (25%) | Preview + Properties (75%)
4. Status bar (fixed height: 1)

Minimum terminal size: 80×24. Guard in resize handler.

### Key Design Patterns
- **Preview swapping**: `mPreviewBox.RemoveAllChildren()` → `BuildPreview(entry)` → `mPreviewBox.AddChild(preview)`
- **State in KSPreviewBuilder**: Interactive preview state (e.g., `mProgressValue`) lives as module-level properties
- **Search**: `KSComponentRegistry.Search(query)` returns matching indices; tree filters to show only matches
- **Focus cycle**: `XjFocusManager` chains: searchInput → listTree → previewArea
- **Rendering**: ~30fps via `XjEventLoop(33)`. Full clear+paint each tick. Switch to DiffRender if needed.
- **String building**: Use `parts() + String.FromArray(parts, "")` for concatenation in loops

---

## Xojo-Specific Notes & Gotchas

- **Entry point class is `KSApp`** — Xojo boilerplate defaults to `App`; renamed to match `KS` prefix convention
- **No modification to XjTTYLib** — it's a library dependency, not project code
- **⚠️ IDE drops Module entries from .xojo_project** — When attaching a folder in Xojo IDE, `Class=` entries are preserved correctly but `Module=` entries either get path `../../../../../../..` or disappear entirely. Must be manually corrected in `KitchenSink.xojo_project` with paths like `XjTTYLib/XjANSI.xojo_code`. Affects: XjTerminal, XjScreen, XjANSI, XjLayoutSolver, XjColor, XjSymbols, XjCursor, XjFont, XjYAML, XjConversion, XjPlatform, XjCommand, XjMarkdown, XjUIParser, XjPrompt, XjWhich
- **Delegate wiring** uses `AddressOf` — ensure method signatures match exactly
- **XjTreeNode** children added before adding root to XjTree
- **Prompt previews are MOCKUPS** — prompts conflict with the event loop; render as styled XjText
- **`q` or Ctrl+C to quit** — both must be handled in key handler
- **`XjTerminal.Width()` / `XjTerminal.Height()`** — checked on resize and initial render
- **String performance**: Follow patterns from PERFORMANCE_EVAL.md in toolkit project
- **`RemoveAll` vs loop** — prefer `RemoveAll` for clearing collections
- **Xojo module properties** — KSPreviewBuilder uses module-level `Private` properties for interactive state

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
