# XjTTY Kitchen Sink Application — Build Proposal

A fullscreen TUI application that lets users browse, preview, and interact with every component in XjTTY-Toolkit. Built as a **new Xojo Console project** that imports the existing `XjTTYLib/` library.

---

## 1. Project Setup

### New Project Structure

```
xjtty-kitchensink/
  KitchenSink.xojo_project    — Console application
  KSApp.xojo_code              — App class (entry point, event loop, layout)
  KSComponentRegistry.xojo_code — Component catalog (names, descriptions, builders)
  KSPreviewBuilder.xojo_code   — Builds live preview widget trees for each component
  KSStatusBar.xojo_code        — Status bar renderer
  XjTTYLib/                    — Symlink or copy of ../xojo-ttytoolkit/XjTTYLib/
```

The project references all `XjTTYLib/*.xojo_code` files from the toolkit project. No modifications to the library — the kitchen sink is a pure consumer.

---

## 2. Layout Architecture

### Visual Layout (minimum 80x24, responsive)

```
┌─ XjTTY-Toolkit Kitchen Sink ──────────────────── v0.7.0 │ 2026-03-13 ─┐  ← Header (height: 3, fixed)
│                                                                         │
├─────────────────────┬───────────────────────────────────────────────────┤
│ Search: [_________] │ Current: XjProgressBar                           │  ← Search bar (height: 3, fixed)
├─────────────────────┼───────────────────────────────────────────────────┤
│ ▸ Widgets           │                                                   │
│   ├── XjBox         │  ┌─ Preview ─────────────────────────────────┐   │
│   ├── XjText        │  │                                           │   │
│   ├── XjTextInput   │  │   Loading... ⠋                           │   │
│   ├── XjTable       │  │                                           │   │
│   ├── XjProgressBar │  │   ████████████░░░░░░░░  65% [6.5/10]     │   │
│   ├── XjSpinner     │  │                                           │   │
│   └── XjTree        │  │   Name: demo-bar                          │   │
│ ▸ Styling           │  │   Value: 6.5 / 10.0                       │   │
│   ├── XjStyle       │  │   [←/→ adjust] [Space: toggle bounce]     │   │
│   ├── XjColor       │  │                                           │   │
│   └── XjANSI        │  └──────────────────────────────────────────┘   │
│ ▸ Prompts           │                                                   │
│   ├── Ask           │  ┌─ Properties ──────────────────────────────┐   │
│   ├── Confirm       │  │ Value:  65    Total: 100                  │   │
│   ├── Select        │  │ Format: :bar :percent [:current/:total]   │   │
│   └── ...           │  │ Mode:   Determinate                       │   │
│ ▸ Utilities         │  │ Chars:  █ ░ ▓                             │   │
│   ├── XjFont        │  └──────────────────────────────────────────┘   │  ← Component list (left, 25%) │ Preview area (right, 75%)
│   ├── XjMarkdown    │                                                   │     Both: height auto, fill remaining
│   └── XjPie         │                                                   │
├─────────────────────┴───────────────────────────────────────────────────┤
│ XjProgressBar — Progress bar with format tokens │ ←/→:adjust Space:mode │  ← Status bar (height: 1, fixed)
└─────────────────────────────────────────────────────────────────────────┘
```

### Layout Tree (XjLayoutNode / XjWidget hierarchy)

```
root (XjBox, DIR_COLUMN, border: single, title: "XjTTY-Toolkit Kitchen Sink")
  ├── header (XjBox, DIR_ROW, height: 3, border: none)
  │     ├── titleText (XjText, width: auto, align: left)     — "XjTTY-Toolkit Kitchen Sink"
  │     ├── spacer (XjBox, width: auto)                       — empty fill
  │     ├── versionText (XjText, width: fixed 12, align: right) — "v0.7.0"
  │     └── dateText (XjText, width: fixed 14, align: right)   — "2026-03-13"
  │
  ├── searchBar (XjBox, DIR_ROW, height: 3, border: single)
  │     ├── searchInput (XjTextInput, width: 30%, label: "Search")
  │     └── currentLabel (XjText, width: auto)                — "Current: {name}"
  │
  ├── mainArea (XjBox, DIR_ROW, height: auto)
  │     ├── componentList (XjBox, DIR_COLUMN, width: 25%, min 20, border: single, title: "Components")
  │     │     └── listTree (XjTree)                            — categorized component tree
  │     │
  │     └── previewArea (XjBox, DIR_COLUMN, width: 75%, border: single, title: "Preview")
  │           ├── livePreview (XjBox, height: auto)            — dynamic widget preview
  │           └── properties (XjBox, height: 30%, border: single, title: "Properties")
  │                 └── propTable (XjTable)                    — key-value property display
  │
  └── statusBar (XjBox, DIR_ROW, height: 1, border: none)
        ├── statusDesc (XjText, width: auto)                   — component description
        └── statusKeys (XjText, width: 30%, align: right)      — keybinding hints
```

### Size Constraints

| Region | Width | Height | Min |
|--------|-------|--------|-----|
| Root | 100% | 100% | 80x24 |
| Header | 100% | Fixed 3 | — |
| Search bar | 100% | Fixed 3 | — |
| Component list | 25% | Auto (fill) | minWidth: 20 |
| Preview area | 75% | Auto (fill) | minWidth: 40 |
| Live preview | 100% | Auto (fill) | — |
| Properties panel | 100% | 30% | minHeight: 5 |
| Status bar | 100% | Fixed 1 | — |

### "Terminal Too Small" Guard

If terminal < 80 wide or < 24 tall, skip the layout entirely and render a centered message:

```
Terminal too small (current: 60x18)
Minimum required: 80x24
```

This uses `XjTerminal.Width()` / `XjTerminal.Height()` checked in the resize handler and on initial render.

---

## 3. Component Registry

A module `KSComponentRegistry` that holds the master list of all browsable components. Each entry is a simple data object:

```
KSComponentEntry:
  Name       — "XjProgressBar"
  Category   — "Widgets" | "Styling" | "Prompts" | "Utilities" | "Layout" | "Foundation"
  ShortDesc  — "Progress bar with format tokens and bounce mode"
  LongDesc   — Multi-line description for properties panel
  Keywords   — "progress,bar,loading,percent,eta" (for search filtering)
  IsInteractive — True if preview responds to keys
```

### Categories and Components

#### Widgets (7 interactive previews)
| # | Name | Interactive? | Preview Description |
|---|------|-------------|---------------------|
| 1 | XjBox | Yes | Nested boxes with different border styles (single/double/round/bold/ascii). Arrow keys cycle border style. Space toggles direction (row/column). Shows padding/margin effect. |
| 2 | XjText | Yes | Text block with word wrap. Left/Right cycles alignment (left/center/right). Up/Down scrolls. `w` toggles wrap on/off. |
| 3 | XjTextInput | Yes | Two text inputs — one plain, one with mask. Type to edit. Tab between them. Shows placeholder, label, cursor, Ctrl+A/E/K/U shortcuts. |
| 4 | XjTable | Yes | Sample data table with 4 columns. Left/Right cycles column alignment. `h` toggles header. `b` toggles border. `a` toggles alternating row style. |
| 5 | XjProgressBar | Yes | Animated progress bar. Left/Right adjust value. Space toggles determinate/bounce mode. `f` cycles format strings. Shows :bar :percent :eta tokens. |
| 6 | XjSpinner | Yes | Animated spinner. Left/Right cycles through all 12 formats (dots, braille, arc, star, bounce, arrow, clock, moon, bar, blocks). Space triggers success/error mark. |
| 7 | XjTree | Yes | Expandable tree hierarchy. Up/Down navigates. Enter/Space toggles expand/collapse. Shows nested nodes with box-drawing branches. |

#### Styling (3 visual demos)
| # | Name | Interactive? | Preview Description |
|---|------|-------------|---------------------|
| 8 | XjStyle | Yes | Grid of all style attributes: bold, dim, italic, underline, blink, inverse, strikethrough. Each shown as applied text. Space cycles through semantic presets (Success/Warning/Danger/Info/Muted/Highlight). Arrow keys cycle FG colors. |
| 9 | XjColor | No | Color palette display: 8 basic colors, 8 bright colors, RGB gradient row, 256-color swatch (16x16 grid), and semantic helpers (Success/Warning/Error/Info/Muted). |
| 10 | XjANSI | No | Reference card: FG/BG color code numbers, SGR attribute codes, cursor escape sequences — rendered as a styled cheat sheet. |

#### Prompts (9 — inline demos, non-blocking)
| # | Name | Interactive? | Preview Description |
|---|------|-------------|---------------------|
| 11 | Ask | Info | Shows what XjPrompt.Ask looks like: question text, cursor, default value hint. NOT a live prompt (fullscreen app can't run inline prompts). Instead shows a screenshot-style mockup with ANSI styling. |
| 12 | Confirm | Info | Mockup of Confirm prompt with (Y/n) display. |
| 13 | Password | Info | Mockup of Password prompt with mask characters. |
| 14 | Select | Info | Mockup of Select prompt with arrow indicator, pagination. |
| 15 | MultiSelect | Info | Mockup with checkbox indicators [ ] and [x]. |
| 16 | EnumSelect | Info | Mockup with numbered choices 1-5. |
| 17 | Expand | Info | Mockup with key mappings (y/n/d). |
| 18 | Slider | Info | Mockup with slider bar and value. |
| 19 | MultiLine | Info | Mockup of multi-line editor with line numbers. |

> **Why mockups for prompts?** Prompt classes use `XjInlineRenderer` with raw mode and cursor-up/erase — they take over stdin. In a fullscreen event-loop app, running a prompt would conflict with the main loop. Instead, we render styled text that shows exactly what each prompt looks like, with its XjPromptStyle applied. The properties panel lists the API (parameters, return type, validators).

#### Utilities (6 visual demos)
| # | Name | Interactive? | Preview Description |
|---|------|-------------|---------------------|
| 20 | XjFont | Yes | ASCII art text rendered with XjFont.Render. Type to change text (up to ~8 chars). Shows 5-row block font output. |
| 21 | XjMarkdown | No | Sample markdown rendered through XjMarkdown.Render — showing headers, bold, italic, code, lists, horizontal rules. Output captured and painted into preview box. |
| 22 | XjPie | Yes | Horizontal bar chart with 4 sample slices. Up/Down adjusts selected slice value. Shows legend. |
| 23 | XjLogger | No | Sample log output at each level: DEBUG, INFO, WARN, ERROR, FATAL — showing colored format with timestamps and metadata. |
| 24 | XjSymbols | No | Grid of all symbols: Check, Cross, Circle, Square, Arrow, Bullet, Ellipsis, QuestionMark — both Unicode and ASCII versions side by side. |
| 25 | XjPager | Info | Description and keybindings reference (Space, q, Down). Pager takes over stdout so we show it as a reference card. |

#### Foundation (4 reference cards)
| # | Name | Interactive? | Preview Description |
|---|------|-------------|---------------------|
| 26 | XjCanvas | No | Show a small canvas with SetCell, WriteText, FillRegion, DrawBox, DrawHLine/VLine — all in one preview, demonstrating the drawing API. |
| 27 | XjEventLoop | No | Reference card: shows the 3 delegate signatures, Auto* properties, lifecycle. |
| 28 | XjKeyEvent | Yes | Live key display — press any key and see its KeyCode, KeyName, Char, and modifier flags rendered in a table. (Similar to Phase 1 demo.) |
| 29 | XjConstraint | No | Visual diagram showing Fixed(20), Percent(50%), Auto, MinMax(10-50) with bars showing how they resolve at different terminal widths. |

#### Layout (2 reference cards)
| # | Name | Interactive? | Preview Description |
|---|------|-------------|---------------------|
| 30 | XjLayoutNode | No | Annotated layout diagram showing computed vs content areas, padding/margin/border zones with labeled measurements. |
| 31 | XjLayoutSolver | No | Before/after diagram: constraint tree input → resolved pixel coordinates output. |

**Total: 31 browsable components** across 6 categories.

---

## 4. Application Architecture

### 4.1 App Entry Point (`KSApp.xojo_code`)

```
Class KSApp Inherits ConsoleApplication

  Event Run(args() As String) As Integer
    // 1. Build component registry
    // 2. Build widget tree (layout from Section 2)
    // 3. Populate component list tree
    // 4. Set up XjEventLoop with:
    //    - AutoAlternateScreen = True
    //    - AutoRawMode = True
    //    - AutoHideCursor = True
    //    - SetOnKeyPress → HandleKey
    //    - SetOnResize → HandleResize
    //    - SetOnTick → HandleTick
    // 5. Select first component
    // 6. loop.Run()
    // 7. Return 0

  Private Properties:
    mLoop As XjEventLoop
    mCanvas As XjCanvas
    mRoot As XjBox                    — root widget
    mListTree As XjTree               — component list (left panel)
    mPreviewBox As XjBox              — preview container (right panel)
    mPropTable As XjTable             — properties panel
    mSearchInput As XjTextInput       — search field
    mCurrentLabel As XjText           — "Current: XjFoo"
    mStatusDesc As XjText             — status bar left
    mStatusKeys As XjText             — status bar right (keybindings)
    mFocus As XjFocusManager          — Tab cycling: searchInput, listTree, previewArea
    mRegistry As KSComponentRegistry  — component catalog
    mSelectedIndex As Integer         — current component index
    mCompleter As XjCompleter         — search autocomplete (from component names + keywords)
    mFilteredIndices() As Integer     — indices into registry matching current search
```

### 4.2 Component Registry (`KSComponentRegistry.xojo_code`)

```
Module KSComponentRegistry
  // Master list of all components
  Private mEntries() As KSComponentEntry

  Sub Init()
    // Add all 31 entries with name, category, description, keywords, isInteractive

  Function Count() As Integer
  Function EntryAt(index As Integer) As KSComponentEntry
  Function Categories() As String()           — unique sorted categories
  Function EntriesForCategory(cat As String) As KSComponentEntry()
  Function Search(query As String) As Integer()  — return matching indices
  Function AllNames() As String()             — for XjCompleter
```

### 4.3 Preview Builder (`KSPreviewBuilder.xojo_code`)

```
Module KSPreviewBuilder
  // Factory: builds a preview widget subtree for a given component
  //
  // Each preview is a standalone XjBox containing the demonstration.
  // Interactive previews have HandleKey logic that responds to
  // Left/Right/Up/Down/Space for parameter changes.

  Function BuildPreview(entry As KSComponentEntry) As XjBox
    Select Case entry.Name
    Case "XjBox"
      Return BuildBoxPreview()
    Case "XjProgressBar"
      Return BuildProgressBarPreview()
    // ... one method per component
    End Select

  // State for interactive previews (module-level properties)
  // e.g., mBoxBorderStyle As Integer, mProgressValue As Double, mSpinnerFormat As Integer
  //
  // HandlePreviewKey(entry, key) As Boolean
  //   — routes keystrokes to the current preview's interactive logic
  //   — returns True if consumed
```

### 4.4 Status Bar (`KSStatusBar.xojo_code`)

```
Module KSStatusBar
  // Renders the bottom status line directly to canvas

  Sub Render(canvas As XjCanvas, y As Integer, width As Integer, entry As KSComponentEntry)
    // Left side: "ComponentName — short description"
    // Right side: keybinding hints based on entry.IsInteractive
    //   Interactive: "←/→:adjust  Space:toggle  Tab:focus  q:quit"
    //   Static:      "↑/↓:browse  Tab:focus  q:quit  /:search"
```

---

## 5. Interaction Design

### 5.1 Focus Zones (Tab cycling)

Three focusable zones, cycled with Tab / Shift+Tab:

| Zone | Widget | Behavior when focused |
|------|--------|-----------------------|
| 1. Search | XjTextInput | Type to filter component list. Autocomplete via XjCompleter. Enter selects top match. Esc clears filter. |
| 2. Component List | XjTree | Up/Down navigates. Enter selects and shows preview. Category nodes expand/collapse. |
| 3. Preview Area | XjBox (dynamic) | Keys routed to current preview's HandlePreviewKey. Only active for interactive previews. |

### 5.2 Global Keybindings (always active, regardless of focus)

| Key | Action |
|-----|--------|
| `q` or `Ctrl+C` | Quit application |
| `Tab` | Cycle focus forward |
| `Shift+Tab` | Cycle focus backward |
| `/` | Jump focus to search input |
| `Escape` | If in search: clear and return focus to list. If in preview: return focus to list. |
| `?` | Toggle help overlay (list all keybindings) |
| `1`-`6` | Jump to category by number (when list focused) |

### 5.3 Component List Keybindings (when list is focused)

| Key | Action |
|-----|--------|
| `Up` / `Down` | Navigate list |
| `Enter` / `Right` | Select component → load preview |
| `Space` | Expand/collapse category |
| `Home` / `End` | Jump to first/last |
| `Page Up` / `Page Down` | Scroll by page |

### 5.4 Search Behavior

1. User types in search input → `KSComponentRegistry.Search(query)` runs
2. Search matches against: Name, Category, Keywords (case-insensitive substring)
3. Component list tree filters to show only matching entries (categories with 0 matches are hidden)
4. XjCompleter provides autocomplete suggestions from component names
5. Enter on a suggestion selects that component directly
6. Esc clears the search and restores full list

### 5.5 Preview Interaction

Each interactive preview defines its own key handling. Examples:

**XjProgressBar preview:**
| Key | Action |
|-----|--------|
| Left/Right | Decrease/increase value by 5 |
| Space | Toggle determinate/indeterminate mode |
| `f` | Cycle format: `:bar :percent` → `:bar :percent [:current/:total]` → `:bar :eta` |
| `r` | Reset to 0 |

**XjSpinner preview:**
| Key | Action |
|-----|--------|
| Left/Right | Previous/next format (dots → braille → arc → ...) |
| `s` | Trigger .Success("Done!") |
| `e` | Trigger .Error_("Failed!") |
| `r` | Reset spinner |

**XjStyle preview:**
| Key | Action |
|-----|--------|
| Left/Right | Cycle FG color (black → red → green → ... → white → bright colors) |
| Up/Down | Cycle BG color |
| `b` | Toggle bold |
| `i` | Toggle italic |
| `u` | Toggle underline |
| `d` | Toggle dim |
| `v` | Toggle inverse |
| `1`-`6` | Jump to semantic preset |

---

## 6. Rendering Pipeline

### Per-Tick Cycle (~30fps)

```
HandleTick(tickCount):
  1. Update animated widgets (spinners, progress bars in bounce mode)
  2. If anything is dirty:
     a. XjLayoutSolver.Solve(mRoot.LayoutNode, termWidth, termHeight)
     b. mCanvas.Clear()
     c. mRoot.Paint(mCanvas)
     d. KSStatusBar.Render(mCanvas, termHeight - 1, termWidth, currentEntry)
     e. XjTerminal.Write(mCanvas.Render())
```

### Resize Handling

```
HandleResize(width, height):
  1. If width < 80 Or height < 24:
       Show "too small" message
       Return
  2. mCanvas.Resize(width, height)
  3. mRoot.MarkDirty()   — forces full re-layout on next tick
```

### Full Render vs Diff Render

Start with full render (clear + paint all) for correctness. If performance allows, switch to `DiffRender(previousSnapshot)` — the canvas already supports this. For 30fps at 80x24 (~1920 cells), full render is fine.

---

## 7. Properties Panel

The properties panel (bottom-right, inside preview area) shows a `XjTable` with info about the selected component:

| Column | Content |
|--------|---------|
| Property | Name of the property/method |
| Value | Current value or description |

Example for XjProgressBar:

```
┌─ Properties ────────────────────────────┐
│ Property       │ Value                   │
│────────────────┼─────────────────────────│
│ Class          │ XjProgressBar           │
│ Inherits       │ XjWidget                │
│ Value          │ 65                      │
│ Total          │ 100                     │
│ Percent        │ 65%                     │
│ Format         │ :bar :percent           │
│ Indeterminate  │ No                      │
│ Filled Char    │ █                       │
│ Empty Char     │ ░                       │
│ Key Methods    │ SetValue, SetTotal,     │
│                │ SetFormat, Advance,     │
│                │ Reset                   │
└─────────────────────────────────────────┘
```

For prompt mockups, the properties show the API signature:

```
│ Method    │ XjPrompt.Ask(question, defaultValue) │
│ Returns   │ String                                │
│ Params    │ question: String, defaultValue: String│
│ Validates │ Optional: Required, MinLength, etc.   │
│ History   │ Optional: XjHistory for Up/Down recall│
```

---

## 8. Help Overlay

Pressing `?` toggles a centered modal overlay (rendered on top of the canvas):

```
┌─ Keyboard Shortcuts ──────────────────────┐
│                                           │
│  Navigation                               │
│    Tab / Shift+Tab   Cycle focus zones     │
│    ↑/↓               Browse components    │
│    Enter              Select component    │
│    /                  Jump to search       │
│    Esc                Clear / go back      │
│    1-6                Jump to category     │
│                                           │
│  Preview (when interactive)               │
│    ←/→               Adjust values        │
│    Space              Toggle modes         │
│    r                  Reset                │
│                                           │
│  General                                  │
│    ?                  Toggle this help     │
│    q / Ctrl+C         Quit                │
│                                           │
│           Press any key to close           │
└───────────────────────────────────────────┘
```

Implementation: Draw a `XjBox` with border directly onto the canvas at a centered position, after the main widget tree paints but before `Render()`. This overlay skips the layout solver — it uses fixed coordinates calculated from `(termWidth - overlayWidth) / 2`.

---

## 9. Implementation Plan

### Phase 1: Skeleton (target: compiles and shows layout)
1. Create new `KitchenSink.xojo_project` console app
2. Add all `XjTTYLib/` references
3. Build the widget tree from Section 2 (hard-coded, no dynamic content)
4. Set up XjEventLoop with resize guard
5. Render empty layout with borders and titles
6. **Verify:** App launches fullscreen, shows the 4-panel layout, resizes correctly, `q` quits

### Phase 2: Component List
1. Implement `KSComponentRegistry` with all 31 entries
2. Build the `XjTree` with category grouping
3. Wire Up/Down/Enter/Space navigation
4. Update `currentLabel` and `statusBar` on selection change
5. **Verify:** Can browse full categorized list, status bar updates

### Phase 3: Search
1. Wire `XjTextInput` with `XjCompleter` (component names + keywords)
2. Implement search filtering in registry
3. Filter tree to show matching entries only
4. Wire `/` shortcut, Esc to clear
5. **Verify:** Type "prog" → sees XjProgressBar; type "color" → sees XjColor, XjStyle; Esc restores full list

### Phase 4: Static Previews
1. Implement `KSPreviewBuilder` with static previews first:
   - XjColor palette, XjANSI reference, XjSymbols grid
   - XjLogger sample output, XjMarkdown rendered sample
   - All prompt mockups (styled text showing what each prompt looks like)
   - XjCanvas demo, XjEventLoop reference, XjConstraint diagram
   - XjLayoutNode/XjLayoutSolver reference cards
2. Wire preview loading on component selection
3. Populate properties table
4. **Verify:** Selecting any component shows its preview and properties

### Phase 5: Interactive Previews
1. Add interactive handling for widgets:
   - XjBox (border cycling, direction toggle)
   - XjText (alignment, wrap, scroll)
   - XjTextInput (live editing with 2 inputs + focus)
   - XjTable (column align, header/border toggle)
   - XjProgressBar (value adjust, mode toggle, format cycle)
   - XjSpinner (format cycle, success/error marks)
   - XjTree (expand/collapse, navigate)
2. Add interactive handling for utilities:
   - XjFont (type to change text)
   - XjPie (adjust slice values)
   - XjStyle (cycle colors, toggle attributes)
   - XjKeyEvent (live key display)
3. Wire focus zone 3 (preview) key routing
4. **Verify:** Each interactive preview responds to documented keys

### Phase 6: Polish
1. Help overlay (`?` key)
2. Category jump (`1`-`6` keys)
3. Page Up/Down, Home/End in component list
4. Smooth animations (spinner, progress bounce)
5. Edge cases: rapid resize, empty search results, boundary values
6. **Verify:** Full user testing of all 31 components

---

## 10. Xojo-Specific Implementation Notes

### Delegate Wiring

```xojo
// In App.Run:
Var loop As New XjEventLoop(33)
loop.AutoAlternateScreen = True
loop.AutoRawMode = True
loop.AutoHideCursor = True
loop.SetOnKeyPress(AddressOf HandleKey)
loop.SetOnResize(AddressOf HandleResize)
loop.SetOnTick(AddressOf HandleTick)
loop.Run
```

### Focus Manager Setup

```xojo
mFocus = New XjFocusManager
// Search input, list tree, and preview box are the 3 focusable zones
// Call mFocus.BuildChain(mRoot) after constructing widget tree
// In HandleKey: If Not mFocus.HandleKey(key) Then ... check global keys
```

### Building the Component Tree

```xojo
// For each category:
Var catNode As New XjTreeNode(categoryName)
For Each entry As KSComponentEntry In registry.EntriesForCategory(categoryName)
  Var itemNode As New XjTreeNode(entry.Name)
  catNode.AddChild(itemNode)
Next
mListTree.AddRoot(catNode)
```

### Preview Swapping

When user selects a new component:
```xojo
// 1. Remove old preview children from mPreviewBox
// 2. Build new preview: Var preview As XjBox = KSPreviewBuilder.BuildPreview(entry)
// 3. mPreviewBox.AddChild(preview)
// 4. Update properties table
// 5. Update status bar text
// 6. mRoot.MarkDirty()
```

### Prompt Mockups (non-interactive styled text)

Since prompts can't run inside the event loop, render them as styled text in an XjText widget:

```xojo
// Example: Ask prompt mockup
Var mockup As String = ""
mockup = mockup + XjColor.Green("? ") + XjColor.BoldText("What is your name? ")
mockup = mockup + XjColor.Cyan("(John) ") + XjColor.DimText("_")
// Write mockup into an XjText widget
```

### String Building (Performance)

Follow the performance patterns from PERFORMANCE_EVAL.md:
- Use `parts()` + `String.FromArray(parts, "")` for any string concatenation in loops
- Pre-compute lowercase for search matching
- Use `RemoveAll` instead of loop-based removal

---

## 11. File Count Estimate

| File | Lines (est.) | Purpose |
|------|-------------|---------|
| KitchenSink.xojo_project | 80 | Project file with references |
| KSApp.xojo_code | 400 | App class, event loop, layout, key routing |
| KSComponentRegistry.xojo_code | 300 | 31 component entries with metadata |
| KSPreviewBuilder.xojo_code | 800 | 31 preview builders (largest file) |
| KSStatusBar.xojo_code | 60 | Status bar renderer |
| **Total** | ~1640 | 5 files |

The `KSPreviewBuilder` is the largest because each of the 31 components needs its own builder method. Interactive previews (15 of 31) also need key handler methods. Average ~25 lines per preview builder.

---

## 12. Success Criteria

- [ ] Launches fullscreen, shows the 4-panel layout
- [ ] Resizes smoothly, shows "too small" below 80x24
- [ ] All 31 components browsable in categorized tree
- [ ] Search filters list in real-time with autocomplete
- [ ] Each component shows a meaningful preview
- [ ] 15 interactive previews respond to documented keys
- [ ] Properties panel shows relevant info per component
- [ ] Status bar updates with component description and keybindings
- [ ] Help overlay toggles with `?`
- [ ] Tab cycles between search, list, and preview
- [ ] `q` / `Ctrl+C` exits cleanly (restores terminal)
- [ ] No flickering, no rendering artifacts on resize
- [ ] Runs at 30fps without perceptible lag
