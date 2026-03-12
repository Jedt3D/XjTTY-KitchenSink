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

### Phase 3 — Search *(pending)*
- XjTextInput wired with XjCompleter (component names + keywords)
- Real-time search filtering in registry
- Tree filters to matching entries only
- `/` shortcut to jump to search, Esc to clear

### Phase 2 — Component Registry & Navigation *(pending)*
- KSComponentRegistry: all 31 entries with metadata
- XjTree populated with categorized component list
- Up/Down/Enter/Space navigation
- currentLabel and statusBar update on selection change

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
