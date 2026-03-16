# KitchenSink Walk Through

> A comprehensive in-depth technical walkthrough for developers working on XjTTY-KitchenSink.
> Updated: 2026-03-17

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Source Files](#source-files)
4. [Layout System](#layout-system)
5. [Event Loop & Rendering](#event-loop--rendering)
6. [Key Routing & Focus Zones](#key-routing--focus-zones)
7. [Component Registry](#component-registry)
8. [Component Demos](#component-demos)
9. [Overlay System](#overlay-system)
10. [Design Patterns & Gotchas](#design-patterns--gotchas)

---

## Project Overview

**XjTTY-KitchenSink** is a fullscreen TUI (Text User Interface) console application built with Xojo. It serves as an interactive browser, live-demo tool, and reference for developers learning the **XjTTY-Toolkit** library (59 components).

The app displays all 31 showcased components in a 4-panel layout: a component list on the left, a preview panel with live demos on the right, a search bar at the top, and a status bar at the bottom.

### How to Run

```bash
./xojo.sh run        # Run the app
./xojo.sh analyze    # Check for compilation errors
```

### XjTTYLib Location

`XjTTYLib` in the project root is a **macOS alias** pointing to:
```
/Users/worajedt/Xojo Projects/XjTTY-Toolkit/XjTTYLib/
```
This folder contains 59 `.xojo_code` files (61 including ExportModule and ThemeModule). **Do NOT modify** any library files.

---

## Architecture

### High-Level Flow

```
App.Run()
  -> mTermWidth/mTermHeight = XjTerminal.Width/Height
  -> mCanvas = New XjCanvas(w, h)
  -> BuildWidgetTree()          // Construct all 4 panels + demo widgets
  -> PopulateTree()             // Fill component list with 31 entries
  -> XjEventLoop(33).Run()      // ~30fps main loop
       -> HandleKey(key)        // Key routing per focus zone
       -> HandleTick(tickCount) // Render + animate
       -> HandleResize(w, h)    // Resize canvas
```

### Widget Tree Hierarchy

```
mRoot (XjBox, DIR_COLUMN, cyan border, title "XjTTY-Toolkit Kitchen Sink")
 +-- header (XjBox, DIR_ROW, Fixed(3))
 +-- searchBar (XjBox, DIR_ROW, Fixed(3), cyan border, title " Search ")
 |    +-- mSearchInput (XjTextInput, placeholder "Press / to search...")
 +-- mainArea (XjBox, DIR_ROW, auto height)
 |    +-- componentList (XjBox, DIR_COLUMN, 25% width min 20, cyan border)
 |    |    +-- mListTree (XjTree)
 |    +-- previewArea (XjBox, DIR_COLUMN, auto width, cyan border, title " Preview ")
 |         +-- livePreview (XjBox, DIR_COLUMN, auto)
 |         |    +-- mPreviewTitle (XjText, Fixed(1), cyan+bold, center aligned)
 |         |    +-- mPreviewBody (XjText, auto, word-wrap, left aligned)
 |         |    +-- mDemoInput (XjTextInput, Fixed(0))        // Phase 5
 |         |    +-- mDemoBar (XjProgressBar, Fixed(0))        // Phase 5
 |         |    +-- mDemoSpinnerWidget (XjSpinner, Fixed(0))  // Phase 5
 |         |    +-- mDemoKeyText (XjText, Fixed(0))           // Phase 5
 |         +-- propertiesPanel (XjBox, 30% height min 5, cyan border)
 |              +-- mPropsTable (XjTable, 2 columns, col-0 width=12)
 +-- statusBar (XjBox, DIR_ROW, Fixed(1))
      +-- mStatusDesc (XjText, auto width)
      +-- keysHint (XjText, Fixed(32), right aligned, dim style)
```

---

## Source Files

### App Source Files (5 files)

| File | Type | Purpose |
|------|------|---------|
| `KSApp.xojo_code` | Class (ConsoleApplication) | Main app: widget tree, event loop, key routing, rendering, all demo widgets |
| `KSComponentEntry.xojo_code` | Class | Data record with 6 fields: Name, Category, ShortDesc, LongDesc, Keywords, IsInteractive |
| `KSComponentRegistry.xojo_code` | Module | Static registry of 31 components. `Init()` populates once. Query methods: `Categories()`, `EntriesForCategory()`, `Search()`, `EntryAt()`, `Count()` |
| `KSPreviewBuilder.xojo_code` | Module | Stateless factory. `LoadInto(entry, title, body, table)` populates the 3 preview widgets |
| `KSInteractiveLoader.xojo_code` | Module | Maps component name to demo type string: `"textinput"`, `"progressbar"`, `"spinner"`, `"keyevent"`, `"mockup"`, or `""` |

### KSApp Properties (All Private)

| Property | Type | Purpose |
|----------|------|---------|
| `mCanvas` | XjCanvas | 2D character buffer sized to terminal |
| `mRoot` | XjBox | Root of the widget tree |
| `mLoop` | XjEventLoop | 30fps event loop with raw mode |
| `mListTree` | XjTree | Component list tree widget |
| `mFlatNodes()` | XjTreeNode | Flat array mirroring tree visible order |
| `mFlatEntries()` | KSComponentEntry | Parallel to mFlatNodes; Nil = category header |
| `mSelectedLine` | Integer | Currently highlighted index (-1 = none) |
| `mScrollOffset` | Integer | First visible line in tree scroll |
| `mSearchInput` | XjTextInput | Search bar text input widget |
| `mSearchMode` | Boolean | True while typing in search bar |
| `mPreviewTitle` | XjText | Preview header: "Name [Category]" |
| `mPreviewBody` | XjText | Preview long description |
| `mPropsTable` | XjTable | Properties panel 2-column table |
| `mPreviewFocus` | Boolean | True when Tab has entered demo focus |
| `mDemoType` | String | Active demo type key |
| `mDemoInput` | XjTextInput | Phase 5 text input demo widget |
| `mDemoBar` | XjProgressBar | Phase 5 progress bar demo widget |
| `mDemoSpinnerWidget` | XjSpinner | Phase 5 spinner demo widget |
| `mDemoKeyText` | XjText | Phase 5 key event display widget |
| `mShowHelp` | Boolean | True while help overlay is visible |
| `mStatusDesc` | XjText | Status bar description text |
| `mTermWidth` | Integer | Current terminal width |
| `mTermHeight` | Integer | Current terminal height |

### KSApp Methods (All Private except Run event)

| Method | Purpose |
|--------|---------|
| `Run(args)` | Entry point: init canvas, build tree, start loop |
| `BuildWidgetTree()` | Constructs full widget hierarchy + pre-builds demo widgets |
| `PopulateTree()` | Loads all 31 entries into tree via RebuildTree |
| `RebuildTree(entries)` | Builds mFlatNodes/mFlatEntries from arbitrary entry slice |
| `SelectLine(lineIdx)` | Moves highlight, updates preview, adjusts scroll |
| `HandleKey(key)` | Three-mode key router |
| `HandleListKey(key)` | Arrow/Page/Home/End navigation in list |
| `HandleTick(tickCount)` | Drives render + demo animation |
| `HandleResize(w, h)` | Updates dimensions, resizes canvas |
| `Render()` | Layout solve -> canvas clear -> paint -> flush |
| `RenderHelp()` | ANSI overlay: help keyboard shortcuts |
| `EnterSearchMode()` | Activates search bar, focuses input |
| `ExitSearchMode()` | Deactivates search, restores full tree, preserves selection |
| `ApplySearch(query)` | Filters tree to matching entries |
| `ActivateDemoWidget(type)` | Shows/hides demo widgets by swapping height constraints |
| `DemoKeyHint(type)` | Returns status bar hint text for active demo |

---

## Layout System

### 4-Panel Layout

```
+--------------------------------------------+
|  XjTTY-Toolkit Kitchen Sink                |  <- mRoot border + title
+--------------------------------------------+
|  (header - Fixed 3 rows)                   |
+--------------------------------------------+
|  [ Search ]  Press / to search...          |  <- searchBar
+--------------------------------------------+
| Components   | Preview                     |
| (25% width)  | (auto width)                |
|              |  Title [Category]           |
|  > Layout    |  Long description...        |
|    XjBox     |                             |
|    XjLayout  |  [Demo Widget Area]         |
|    ...       |                             |
|              +----- Properties ------------|
|  > Widgets   |  Name      | XjBox          |
|   *XjText*   |  Category  | Layout         |
|    XjInput   |  Interactive | No           |
+--------------+-----------------------------+
|  ShortDesc here          / Search  ?Help q |  <- statusBar
+--------------------------------------------+
```

### Height Formula

- **Visible rows in component list**: `mTermHeight - 11`
- Breakdown: mRoot border(2) + header(3) + searchBar(3) + statusBar(1) + componentList border(2) = 11
- Minimum terminal size: 80x24

### Constraint Types

| Type | Usage |
|------|-------|
| `XjConstraint.Fixed(n)` | Exact height/width in rows/cols |
| `XjConstraint.Percent(p)` | Percentage of parent |
| `XjConstraint.Auto()` | Fill remaining space |
| `.SetMin(n)` / `.SetMax(n)` | Clamp values (chainable) |

---

## Event Loop & Rendering

### Render Pipeline (every tick, ~30fps)

```
HandleTick(tickCount)
  1. If mShowHelp -> RenderHelp() -> return
  2. Advance animated demos (spinner, progressbar)
  3. Render()
       a. Guard: terminal < 80x24 -> show error message
       b. XjLayoutSolver.Solve(mRoot.LayoutNode, width, height)
       c. mCanvas.Clear()
       d. mRoot.Paint(mCanvas)        // Recursive widget painting
       e. XjTerminal.Write(mCanvas.Render())   // Flush to terminal
```

### Event Loop Configuration

```vb
mLoop = New XjEventLoop(33)     // 33ms = ~30fps
mLoop.AutoAlternateScreen = True // Use alternate screen buffer
mLoop.AutoHideCursor = True      // Hide cursor during render
mLoop.SetOnKeyPress(AddressOf HandleKey)
mLoop.SetOnResize(AddressOf HandleResize)
mLoop.SetOnTick(AddressOf HandleTick)
mLoop.Run()                      // Blocks until Stop_() called
```

---

## Key Routing & Focus Zones

### Three Focus Zones

```
HandleKey(key)
  |
  +-- Ctrl+C always quits
  |
  +-- mShowHelp? -> any key dismisses overlay
  |
  +-- Zone 1: mPreviewFocus (demo widget has focus)
  |     Esc -> return to list
  |     Other keys -> route to active demo widget
  |
  +-- Zone 2: mSearchMode (search bar has focus)
  |     Esc -> exit search, restore full tree
  |     Up/Down/Enter -> navigate filtered list
  |     Tab -> exit search, fall through to list Tab
  |     Other -> mSearchInput.HandleKey() -> ApplySearch()
  |
  +-- Zone 3: List mode (default)
        q -> quit
        / -> enter search mode
        Tab -> enter preview focus (if live demo available)
        ? -> show help overlay
        1-6 -> jump to category header
        Arrow/Page/Home/End -> HandleListKey()
```

### Demo Widget Key Routing (Zone 1)

| Demo Type | Key Handling |
|-----------|-------------|
| `"textinput"` | All keys forwarded to `mDemoInput.HandleKey(key)` |
| `"progressbar"` | `+`/`=` increment by 10, `-` decrement by 10, Space/`r` reset |
| `"spinner"` | No key handling; auto-animates via HandleTick |
| `"keyevent"` | Any key displays its KeyCode, Char, and Modifier properties |

---

## Component Registry

### 31 Components in 6 Categories

#### KSComponentEntry Fields

| Field | Type | Description |
|-------|------|-------------|
| `Name` | String | Xojo class/module name (e.g. "XjBox") |
| `Category` | String | One of: Layout, Widgets, Prompts, Style, I/O, Utility |
| `ShortDesc` | String | One-line summary for status bar |
| `LongDesc` | String | Multi-sentence description for preview body |
| `Keywords` | String | Space-separated search terms |
| `IsInteractive` | Boolean | True if component accepts live key input |

#### Full Component List

| # | Name | Category | IsInteractive | Current Demo |
|---|------|----------|---------------|-------------|
| 1 | XjBox | Layout | No | Static preview |
| 2 | XjLayoutNode | Layout | No | Static preview |
| 3 | XjConstraint | Layout | No | Static preview |
| 4 | XjLayoutSolver | Layout | No | Static preview |
| 5 | XjText | Widgets | No | Static preview |
| 6 | XjTextInput | Widgets | Yes | **Live: "textinput"** |
| 7 | XjProgressBar | Widgets | No | **Live: "progressbar"** |
| 8 | XjSpinner | Widgets | No | **Live: "spinner"** |
| 9 | XjTree | Widgets | Yes | Mockup (static text) |
| 10 | XjTable | Widgets | No | Static preview |
| 11 | XjAskPrompt | Prompts | Yes | Mockup (static text) |
| 12 | XjConfirmPrompt | Prompts | Yes | Mockup (static text) |
| 13 | XjSelectPrompt | Prompts | Yes | Mockup (static text) |
| 14 | XjMultiSelectPrompt | Prompts | Yes | Mockup (static text) |
| 15 | XjExpandPrompt | Prompts | Yes | Mockup (static text) |
| 16 | XjEnumSelectPrompt | Prompts | Yes | Mockup (static text) |
| 17 | XjSuggestPrompt | Prompts | Yes | Mockup (static text) |
| 18 | XjCollectPrompt | Prompts | Yes | Mockup (static text) |
| 19 | XjKeyPressPrompt | Prompts | Yes | Mockup (static text) |
| 20 | XjStyle | Style | No | Static preview |
| 21 | XjFont | Style | No | Static preview |
| 22 | XjPie | Style | No | Static preview |
| 23 | XjColor | Style | No | Static preview |
| 24 | XjCanvas | I/O | No | Static preview |
| 25 | XjTerminal | I/O | No | Static preview |
| 26 | XjReader | I/O | No | Static preview |
| 27 | XjPager | I/O | No | Static preview |
| 28 | XjEventLoop | Utility | No | Static preview |
| 29 | XjKeyEvent | Utility | No | **Live: "keyevent"** |
| 30 | XjFocusManager | Utility | No | Static preview |
| 31 | XjCommand | Utility | No | Static preview |

---

## Component Demos

### Current Live Demos (Phase 5-6)

#### XjTextInput Demo (type: `"textinput"`)

**Interactive design:** User presses Tab to enter the text field, then types freely. All keyboard input is forwarded directly to `mDemoInput.HandleKey(key)`. The XjTextInput widget handles cursor movement, backspace, delete, Home/End, and Ctrl shortcuts internally. Press Esc to return to list.

**Component parameters:**
- `SetPlaceholder("Type here to demo XjTextInput...")` — shown when empty
- `SetHeight(XjConstraint.Fixed(3))` when active, `Fixed(0)` when hidden
- `SetFocused(True)` — **required** before key routing works; XjTextInput returns False without processing if `mFocused = False`

**Implementation:**
- Pre-built in `BuildWidgetTree()` (lines 225-228)
- Height toggled by `ActivateDemoWidget("textinput")` -> `Fixed(3)`
- Key routing: `HandleKey()` line 385 -> `mDemoInput.HandleKey(key)`
- Focus: `SetFocused(True)` called when Tab enters preview (line 462)
- No tick handling needed; cursor state maintained internally

---

#### XjProgressBar Demo (type: `"progressbar"`)

**Interactive design:** User presses `+`/`=` to increment the bar by 10, `-` to decrement by 10, Space or `r` to reset to 0. The bar auto-animates on each tick via `HandleTick()`. The green-styled fill grows/shrinks smoothly.

**Component parameters:**
- `SetTotal(100)` — bar range 0-100
- `SetFilledStyle(greenStyle)` — green foreground for filled portion (built via `XjStyle.SetFG(XjANSI.FG_GREEN)`)
- `SetHeight(XjConstraint.Fixed(2))` when active, `Fixed(0)` when hidden

**Implementation:**
- Pre-built in `BuildWidgetTree()` (lines 232-238)
- Height toggled by `ActivateDemoWidget("progressbar")` -> `Fixed(2)`
- Key routing: `HandleKey()` lines 387-395
  - `+` or `=` -> `mDemoBar.Advance(10)`
  - `-` -> `mDemoBar.SetValue(mDemoBar.Value - 10)`
  - Space or `r` -> `mDemoBar.Reset()`
- Tick: `HandleTick()` line 596-597 -> `mDemoBar.HandleTick(tickCount)` (drives smooth animation)

---

#### XjSpinner Demo (type: `"spinner"`)

**Interactive design:** No user interaction needed. The spinner auto-animates continuously. The frame advances on every tick via `HandleTick()`. The "dots" format shows rotating dot patterns. Tab enters focus but no keys do anything; Esc returns to list.

**Component parameters:**
- `SetFormat("dots")` — spinner style (12+ formats available: dots, dots2, dots3, line, arc, star, bounce, arrow, clock, moon, bar, blocks)
- `SetMessage("Spinner demo - animates automatically")` — text beside spinner
- `SetHeight(XjConstraint.Fixed(2))` when active, `Fixed(0)` when hidden

**Implementation:**
- Pre-built in `BuildWidgetTree()` (lines 242-246)
- Height toggled by `ActivateDemoWidget("spinner")` -> `Fixed(2)`
- No key routing; spinner is display-only
- Tick: `HandleTick()` line 595 -> `mDemoSpinnerWidget.HandleTick(tickCount)` (advances frame)

---

#### XjKeyEvent Demo (type: `"keyevent"`)

**Interactive design:** User presses any key while in preview focus. The `mDemoKeyText` widget displays the key's properties: KeyCode (numeric), Char (the character or "(none)"), and Modifier (Ctrl flag). This demonstrates how XjKeyEvent captures and decodes terminal input.

**Component parameters:**
- `mDemoKeyText` is an XjText (not XjKeyEvent — which is a data class, not a widget)
- `SetText("Press any key...")` — initial prompt text
- `SetHeight(XjConstraint.Fixed(4))` when active, `Fixed(0)` when hidden

**Implementation:**
- Pre-built in `BuildWidgetTree()` (lines 250-253)
- Height toggled by `ActivateDemoWidget("keyevent")` -> `Fixed(4)`
- Key routing: `HandleKey()` lines 397-408
  - Formats key info: `"KeyCode : " + key.KeyCode.ToString`
  - Appends Char: `"Char    : '" + key.Char + "'"` or `"(none)"`
  - Appends modifier: `"Modifier: Ctrl"` if `key.IsCtrl`
  - Updates via `mDemoKeyText.SetText(kDesc)`
- No tick handling; purely event-driven

---

### Demo Infrastructure Pattern

All live demos follow this pattern:

**1. Pre-build at startup** (`BuildWidgetTree()`):
```vb
mDemoWidget = New XjWidgetType
Call mDemoWidget.SetHeight(XjConstraint.Fixed(0))   // Hidden
Call mDemoWidget.SetSomeConfig(...)                  // Configure
livePreview.AddChild(mDemoWidget)                    // Add to tree
```

**2. Reveal on navigation** (`ActivateDemoWidget(type)`):
```vb
// Collapse all demo widgets first
Call mDemoInput.SetHeight(XjConstraint.Fixed(0))
Call mDemoBar.SetHeight(XjConstraint.Fixed(0))
// ... etc for all

// Reveal the matching one
Select Case demoType
Case "textinput"
  Call mDemoInput.SetHeight(XjConstraint.Fixed(3))
Case "progressbar"
  Call mDemoBar.SetHeight(XjConstraint.Fixed(2))
// ... etc
End Select
```

**3. Map entry to demo type** (`KSInteractiveLoader.DemoTypeFor(entry)`):
```vb
Select Case entry.Name
Case "XjTextInput"  -> Return "textinput"
Case "XjProgressBar" -> Return "progressbar"
Case "XjSpinner"    -> Return "spinner"
Case "XjKeyEvent"   -> Return "keyevent"
Case Else
  If entry.IsInteractive Then Return "mockup"
  Return ""
End Select
```

**4. Route keys** (`HandleKey()` under `mPreviewFocus`):
```vb
Select Case mDemoType
Case "textinput"
  Call mDemoInput.HandleKey(key)
Case "progressbar"
  // +/- /Space/r key handling
Case "keyevent"
  // Display key properties
End Select
```

**5. Drive animation** (`HandleTick()`):
```vb
Select Case mDemoType
Case "spinner"
  mDemoSpinnerWidget.HandleTick(tickCount)
Case "progressbar"
  mDemoBar.HandleTick(tickCount)
End Select
```

### Planned Demo Batches

#### Batch 1 — Widget Demos (XjText, XjTable, XjTree)
**Status:** Pending

Uses the same embed-in-preview pattern as existing Phase 5 demos. Pre-build widgets with `Fixed(0)`, reveal with `ActivateDemoWidget()`.

- **XjText**: Keys `l`/`c`/`r` change alignment, `w` toggles word-wrap. Height: Fixed(4).
- **XjTable**: Keys `b` toggle border, `h` toggle header. Height: Fixed(8).
- **XjTree**: Up/Down scroll a sample hierarchy. Height: Fixed(6).

#### Batch 2 — Rendered-Output Demos (XjPie, XjStyle, XjColor, XjCanvas)
**Status:** Pending

These aren't XjWidget subclasses but produce visual output. Uses **overlay rendering** (ANSI cursor positioning like `RenderHelp()`) to paint styled content over the preview area.

Introduces `RenderDemoOverlay()` — a reusable overlay method that Batches 3-4 also use.

#### Batch 3 — Simple Prompt Overlay Mockups (5 prompts)
**Status:** Pending

Components: XjConfirmPrompt, XjKeyPressPrompt, XjExpandPrompt, XjAskPrompt, XjEnumSelectPrompt.

Overlay mockups that visually replicate each prompt's appearance as a floating dialog box with limited interactivity (press Y/N, type text, select number).

Introduces `mOverlayMode` as a 4th focus zone.

#### Batch 4 — Complex Prompt Overlay Mockups (4 prompts)
**Status:** Pending

Components: XjSelectPrompt, XjMultiSelectPrompt, XjSuggestPrompt, XjCollectPrompt.

Same overlay mechanism as Batch 3 but with stateful interactions: arrow-key list navigation, checkbox toggling, autocomplete filtering, multi-step wizards.

#### Batch 5 — Enhanced Static Previews (Infrastructure)
**Status:** Pending

Components: XjBox, XjLayoutNode, XjConstraint, XjLayoutSolver, XjTerminal, XjReader, XjPager, XjEventLoop, XjFocusManager, XjCommand, XjFont.

Richer descriptions with "you're looking at it" callouts and optional live property values (e.g., terminal dimensions, tick count).

---

## Overlay System

### Help Overlay Pattern (Phase 6)

The `RenderHelp()` method demonstrates how to draw floating content on top of the rendered UI without modifying the widget tree:

1. Call `Render()` first (paint normal UI)
2. Build an output string using ANSI escape codes:
   - `ESC[row;colH` — cursor positioning
   - `ESC[36m` — cyan foreground
   - `ESC[1m` — bold
   - `ESC[90m` — dim (bright black)
   - `ESC[0m` — reset
3. Draw borders with `+` and `-` characters
4. Pad content lines to fixed width for clean box edges
5. Write the complete string in one `XjTerminal.Write()` call

**State management:** `mShowHelp As Boolean`. Set True on `?` key, set False on any key press. Checked at top of `HandleKey()` before all mode blocks.

**Positioning:** Box centered on screen:
```vb
startCol = (mTermWidth - inner - 2) \ 2 + 1
startRow = (mTermHeight - boxH) \ 2 + 1
```

### Planned: Demo Overlay (Batch 2+)

`RenderDemoOverlay()` will extend this pattern for prompt mockups and rendered-output demos. It will:
- Accept `lines() As String` and a title
- Position over the preview panel area (not full-screen center)
- Support interactive state updates via `HandleOverlayKey()`
- Dismiss with Esc

---

## Design Patterns & Gotchas

### Parallel Flat Arrays
`mFlatNodes()` and `mFlatEntries()` mirror XjTree's internal flat list. `mFlatEntries(i)` is `Nil` for category header rows. This gives O(1) cursor-to-entry lookup.

### Tree Highlight (No Rebuild)
Change `node.SetNodeStyle(...)` then call `mListTree.SetScrollOffset(mScrollOffset)` to mark XjTree dirty. No tree rebuild needed.

### Scroll Visible Height
Always use `mTermHeight - 11` (not `-9`). Breakdown: mRoot border(2) + header(3) + searchBar(3) + statusBar(1) + componentList border(2) = 11.

### Registry Init Guard
`KSComponentRegistry.mInitialized` prevents double-population. Call `Init()` freely; it no-ops after first call.

### XjTextInput Focus
Call `SetFocused(True)` before routing keys to XjTextInput. It returns False without processing if `mFocused = False`.

### XjStyle Chaining (Xojo Gotcha)
Xojo does not allow method calls on temporary `New` expressions. Always assign first:
```vb
Var s As New XjStyle
Var withCyan As XjStyle = s.SetFG(XjANSI.FG_CYAN)
Var final As XjStyle = withCyan.SetBold()
```

### No RemoveAllChildren
`XjWidget` / `XjBox` has no `RemoveAllChildren()` method. Use persistent pre-built widgets and update content via `SetText()` / `ClearRows()` / `AddRow()` instead of swapping child widgets.

### Widget Tick
XjSpinner and XjProgressBar require explicit `widget.HandleTick(tickCount)` calls from `KSApp.HandleTick()`. The render pipeline does NOT auto-call HandleTick on child widgets.

### ExitSearchMode Preserves Selection
Saves `mFlatEntries(mSelectedLine)` before `PopulateTree()`, then finds and re-selects it by name in the rebuilt tree. Falls back to line 0 if nothing was selected.

### btop-Inspired Theme
All panel `SetBorder` calls use `cyanBorder` (FG_CYAN). Selected tree node uses `BG_MAGENTA + FG_WHITE`. Key hint uses `FG_BRIGHT_BLACK` (dim). Theme styles built once at top of `BuildWidgetTree()`.

### Array Clearing
Use `.RemoveAll` to clear dynamic arrays (confirmed in XjTree source). Do NOT use `Redim arr(-1)`.
