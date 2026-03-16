# XjTTY-KitchenSink

> แอปพลิเคชัน TUI แบบเต็มหน้าจอสำหรับเรียกดูและทดลองใช้ทุก component ใน XjTTY-Toolkit
>
> A fullscreen TUI application for browsing and interacting with every component in the XjTTY-Toolkit library.

---

## What Is This?

**XjTTY-KitchenSink** is an interactive terminal application that lets you:

- Browse all **31 components** in the XjTTY-Toolkit, organized by category
- See **live previews** of widgets, styles, prompts, and utilities
- Interact with components using keyboard shortcuts (adjust values, toggle modes)
- View **properties panels** showing API signatures and current state
- **Search** components by name or keyword with autocomplete

Built as a Xojo Console application using only the `XjTTYLib/` library — no modifications to the library itself.

---

## Requirements

- **Xojo 2025** or later
- Terminal: minimum **80×24** columns/rows
- macOS, Windows, or Linux – I only tested on macOS only in this version.
- XjTTYLib from (https://github.com/Jedt3D/XjTTY-Toolkit) **Important**

---

## Project Structure

```
XjTTY-KitchenSink/
├── XjTTYKitchenSink.xojo_project  — Console application project
├── KSApp.xojo_code                — App entry point, event loop, layout tree
├── KSComponentEntry.xojo_code     — Data class for component metadata
├── KSComponentRegistry.xojo_code  — Catalog of 31 components with metadata
├── KSPreviewBuilder.xojo_code     — Stateless factory for preview widgets
├── KSInteractiveLoader.xojo_code  — Maps components to live demo types
├── XjTTYLib → ../xojo-ttytoolkit/XjTTYLib/  — Alias to shared toolkit (59 components)
└── README.md                      — This file
```

---

## Layout

```
┌─ XjTTY-Toolkit Kitchen Sink ──────────────────────────  v0.7.0 │ 2026-03-13 ─┐
│                                                                              │
├──────────────────────┬───────────────────────────────────────────────────────┤
│ Search: [__________] │ Current: XjProgressBar                                │
├──────────────────────┼───────────────────────────────────────────────────────┤
│ ▸ Widgets            │  ┌─ Preview ───────────────────────────────────────┐  │
│   ├── XjBox          │  │  ████████████░░░░░░░░  65% [6.5/10]             │  │
│   ├── XjProgressBar  │  └─────────────────────────────────────────────────┘  │
│   └── ...            │  ┌─ Properties ───────────────────────────────────┐   │
│ ▸ Styling            │  │ Value: 65   Total: 100   Mode: Determinate     │   │
│ ▸ Prompts            │  └────────────────────────────────────────────────┘   │
│ ▸ Utilities          │                                                       │
│ ▸ Foundation         │                                                       │
│ ▸ Layout             │                                                       │
├──────────────────────┴───────────────────────────────────────────────────────┤
│ XjProgressBar — Progress bar with format tokens │ ←/→:adjust  Space:mode     │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Tab` / `Shift+Tab` | Cycle focus zones (Search → List → Preview) |
| `↑` / `↓` | Navigate component list |
| `Enter` | Select component |
| `/` | Jump to search |
| `Esc` | Clear search / return to list |
| `?` | Toggle help overlay |
| `1`–`6` | Jump to category |
| `←` / `→` | Adjust interactive preview values |
| `Space` | Toggle modes in interactive previews |
| `q` / `Ctrl+C` | Quit |

---

## Components (31 total)

| Category | Components |
|----------|-----------|
| **Widgets** (7) | XjBox, XjText, XjTextInput, XjTable, XjProgressBar, XjSpinner, XjTree |
| **Styling** (3) | XjStyle, XjColor, XjANSI |
| **Prompts** (9) | Ask, Confirm, Password, Select, MultiSelect, EnumSelect, Expand, Slider, MultiLine |
| **Utilities** (6) | XjFont, XjMarkdown, XjPie, XjLogger, XjSymbols, XjPager |
| **Foundation** (4) | XjCanvas, XjEventLoop, XjKeyEvent, XjConstraint |
| **Layout** (2) | XjLayoutNode, XjLayoutSolver |

---

## Running

Open `KitchenSink.xojo_project` in Xojo IDE and run, or use the helper script:

```bash
./xojo.sh run
```

---

*Built with [XjTTY-Toolkit](../xojo-ttytoolkit) · Xojo 2025*
