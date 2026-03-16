# XjTTY-KitchenSink

> แอปพลิเคชัน TUI แบบเต็มหน้าจอสำหรับเรียกดูและทดลองใช้ทุก component ใน XjTTY-Toolkit
>
> A fullscreen TUI application for browsing and interacting with every component in the XjTTY-Toolkit library.

---

## Features

- **Browse all 31 components** organized in 6 categories with tree navigation
- **20 interactive live demos** — type, toggle, navigate, and interact directly
- **Overlay mockup demos** for all 9 prompt classes (blocking prompts rendered as visual mockups)
- **Block-art text rendering** — type letters and see them rendered as large 5x5 block characters
- **Live search** with instant filtering by name, category, or keyword
- **Properties panel** showing API metadata for every component
- **Help overlay** with complete keyboard reference
- **Category jump** (1-6 keys), Page Up/Down, Home/End navigation
- **btop-inspired theme** — cyan borders, magenta selection, dim hints
- **30fps render loop** — smooth fullscreen TUI at ~30 frames per second

---

## Screenshots

![XjMultiSelectPrompt](development%20docs/XjMultiSelectPrompt.jpg)
![XjPie](development%20docs/XjPie.jpg)
![XjStyle](development%20docs/XjStyle.jpg)
![XjTable](development%20docs/XjTable.jpg)


**Sketch design in the beginning**
```
┌─ XjTTY-Toolkit Kitchen Sink ───────────────────────────── v0.8.1 │ 2026-03-17 ─┐
│                                                                                │
├─ Search ──────────────┬─ Preview ──────────────────────────────────────────────┤
│ [___________________ ]│ XjProgressBar  [Widgets]                               │
├─ Components ──────────┤                                                        │
│ ▸ Widgets             │ A horizontal progress bar with format tokens,          │
│   ├── XjBox           │ percentage display, ETA calculation, and               │
│   ├── XjText          │ bounce mode for indeterminate progress.                │
│   ├── XjTextInput     │                                                        │
│   ├── XjTable         │ Keywords: progress, bar, loading, percent              │
│   ├── XjProgressBar ◄─│─── selected (magenta highlight)                        │
│   ├── XjSpinner       │ [ Interactive ] Press Tab to enter the live demo.      │
│   └── XjTree          │                                                        │
│ ▸ Styling             ├─ Properties ───────────────────────────────────────────┤
│   ├── XjStyle         │ Name         XjProgressBar                             │
│   ├── XjColor         │ Category     Widgets                                   │
│   └── XjANSI          │ Interactive  Yes (Tab for demo)                        │
│ ▸ Prompts             │ Keywords     progress, bar, loading, percent           │
│   ├── XjAskPrompt     │                                                        │
│   └── ... (9 total)   │                                                        │
│ ▸ Utilities           │                                                        │
│ ▸ Foundation          │                                                        │
│ ▸ Layout              │                                                        │
├───────────────────────┴────────────────────────────────────────────────────────┤
│ XjProgressBar — Progress bar with format tokens  / Search  Up/Dn  ?Help  q Quit│
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## Requirements

- **Xojo 2025r3.1** or later
- **Terminal**: minimum **80x24** columns/rows (responsive to larger sizes)
- **macOS** — tested on macOS Tahoe; Windows/Linux should work but are untested
- **XjTTY-Toolkit** library: [github.com/Jedt3D/XjTTY-Toolkit](https://github.com/Jedt3D/XjTTY-Toolkit)

---

## Quick Start

```bash
# Clone both repos side by side
git clone https://github.com/Jedt3D/XjTTY-Toolkit.git
git clone https://github.com/Jedt3D/XjTTY-KitchenSink.git

# Open in Xojo IDE
cd XjTTY-KitchenSink
./xojo.sh open XjTTYKitchenSink.xojo_project

# Or analyze for errors / run directly
./xojo.sh analyze
./xojo.sh run
```

---

## Project Structure

```
XjTTY-KitchenSink/
├── XjTTYKitchenSink.xojo_project  — Console application project
├── KSApp.xojo_code                — App entry point, event loop, layout, key routing
├── KSComponentEntry.xojo_code     — Data class (6 fields per component)
├── KSComponentRegistry.xojo_code  — Catalog of 31 components with metadata
├── KSPreviewBuilder.xojo_code     — Stateless factory for preview widgets
├── KSInteractiveLoader.xojo_code  — Maps components to live demo types
├── KSFontRenderer.xojo_code       — Block-art text renderer (Tahoe-safe)
├── XjTTYLib/                      — Symlink to XjTTY-Toolkit library (59 files)
├── CLAUDE.md                      — AI-assisted development context
├── CHANGELOG.md                   — Version history
├── DEV_CODE_WALKTHROUGH.md        — Developer onboarding guide
├── KITCHEN_SINK_PROPOSAL.md       — Original specification
└── README.md                      — This file
```

---

## Layout Architecture

4-panel fullscreen layout using `XjLayoutNode` / `XjBox`:

```
┌──────────────────────────────────────────────────────────┐
│  Header (Fixed 3)                                        │
├──────────────────────────────────────────────────────────┤
│  Search Bar (Fixed 3)                                    │
├────────────┬─────────────────────────────────────────────┤
│            │  Preview (auto)                             │
│ Component  │─────────────────────────────────────────────│
│ List (25%) │  Properties (auto)                          │
│            │                                             │
├────────────┴─────────────────────────────────────────────┤
│  Status Bar (Fixed 1)                                    │
└──────────────────────────────────────────────────────────┘
```

---

## Keyboard Shortcuts

### Navigation

| Key | Action |
|-----|--------|
| `Up` / `Down` | Navigate component list |
| `Page Up` / `Page Down` | Scroll one page |
| `Home` / `End` | Jump to first / last item |
| `1` - `6` | Jump to category (Widgets, Styling, Prompts, ...) |
| `/` | Enter search mode |
| `Esc` | Exit search / exit demo / dismiss help |

### Demo Interaction

| Key | Action |
|-----|--------|
| `Tab` | Enter live demo (when available) |
| `Esc` | Return to component list |
| Demo-specific keys | Shown in status bar when in demo mode |

### Global

| Key | Action |
|-----|--------|
| `?` | Toggle help overlay |
| `q` / `Ctrl+C` | Quit |

---

## Components (31 total)

### Widgets (7) — Live widget demos

| Component | Demo | Interactive Keys |
|-----------|------|-----------------|
| XjBox | Layout container — "you're looking at it" | — |
| XjText | Text alignment/wrap | `l`/`c`/`r` align, `w` wrap |
| XjTextInput | Text input field | Type freely |
| XjTable | Table with toggle options | `b` border, `h` header |
| XjProgressBar | Animated progress bar | `+`/`-` adjust, `r` reset |
| XjSpinner | Auto-animated spinner | Auto-plays |
| XjTree | Tree navigation | `Up`/`Down` scroll |

### Styling (3) — Overlay demos

| Component | Demo |
|-----------|------|
| XjStyle | ANSI style showcase (bold, dim, underline, colors) |
| XjColor | 16 ANSI colors as colored blocks |
| XjANSI | Enhanced description |

### Prompts (9) — Overlay mockups

| Component | Mockup Behavior |
|-----------|----------------|
| XjConfirmPrompt | Y/N confirm with checkmark |
| XjKeyPressPrompt | Press any key, shows key name |
| XjExpandPrompt | Collapsed choices, `h` expands |
| XjAskPrompt | Type text, Enter settles |
| XjEnumSelectPrompt | Numbered list, press digit |
| XjSelectPrompt | Arrow-key list with cursor |
| XjMultiSelectPrompt | Checkbox list with Space toggle |
| XjSuggestPrompt | Text input with filtered dropdown |
| XjCollectPrompt | 3-step wizard |

### Utilities (6)

| Component | Demo |
|-----------|------|
| XjFont | **Block-art text** — type A-Z/0-9, renders as large block characters |
| XjPie | Pie chart with switchable datasets (`1`/`2`/`3`) |
| XjMarkdown | Enhanced description |
| XjLogger | Enhanced description |
| XjSymbols | Enhanced description |
| XjPager | Enhanced description |

### Foundation (4)

| Component | Demo |
|-----------|------|
| XjCanvas | Canvas concept overlay |
| XjEventLoop | Self-referential description |
| XjKeyEvent | Live key display (shows keycode, char, modifiers) |
| XjConstraint | Self-referential description |

### Layout (2)

| Component | Demo |
|-----------|------|
| XjLayoutNode | Self-referential description |
| XjLayoutSolver | Self-referential description |

---

## Demo Types

The app uses 5 distinct demo rendering approaches:

| Type | Count | How It Works |
|------|-------|-------------|
| **Widget demos** | 7 | Pre-built XjWidget embedded in preview panel |
| **Overlay demos** | 4 | ANSI cursor-positioned overlay box |
| **Prompt mockups** | 9 | Interactive overlay simulating prompt behavior |
| **Block-art demo** | 1 | Widget-based rendering (XjFont, Tahoe-safe) |
| **Static previews** | 10 | Enhanced descriptions with extra property rows |

---

## macOS Tahoe Compatibility

This app includes workarounds for macOS Tahoe's xzone malloc allocator, which can cause crashes in Xojo applications. Key mitigations:

- **KSFontRenderer**: Replaces `XjFont.Render()` (which crashes due to large Dictionary init) with hardcoded glyph lookups split across 4 small methods
- **Widget-based rendering for XjFont**: Uses `mDemoTextWidget.SetText()` instead of `RenderDemoOverlay()` to avoid heap-fragmentation-triggered crashes
- **Method body size limits**: Large methods extracted into helpers to stay under Tahoe's compiled-code threshold

See `XOJO_MACOS_TAHOE_CRASH_INVESTIGATION.md` for the full investigation report.

---

## Development

### For AI-assisted development

This project uses a structured multi-role agent team. See:
- `CLAUDE.md` — Full project context and architecture decisions
- `DEV_CODE_WALKTHROUGH.md` — Code walkthrough for new developers
- `TEAM_WORKFLOW.md` — Team roles and phase process

### Adding a new component demo

1. Add entry in `KSComponentRegistry.Init()` with metadata
2. Add a `Case` in `KSInteractiveLoader.DemoTypeFor()` mapping to a demo type
3. For widget demos: build widget in `KSApp.BuildWidgetTree()`, add activation in `ActivateDemoWidget()`
4. For overlay demos: add builder method and case in `RenderOverlayIfNeeded()`
5. Add key handling in the appropriate handler method

### Project indexing

```bash
# Fast code navigation using xoji indexer
xoji check || xoji index
cat .xojo_index/codetree.json | grep -A 20 "KSApp"
```

---

## Version History

See [CHANGELOG.md](CHANGELOG.md) for the full version history.

Current: **v0.8.1** — All 31 components with interactive demos, overlay mockups, or enhanced static previews.

---

## License

This project is part of the XjTTY ecosystem.

---

*Built with [XjTTY-Toolkit](https://github.com/Jedt3D/XjTTY-Toolkit) · Xojo 2025r3.1*
