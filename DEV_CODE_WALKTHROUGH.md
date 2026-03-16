# DEV_CODE_WALKTHROUGH.md

> คู่มือสำหรับนักพัฒนาที่เพิ่งเริ่มทำงานกับโปรเจกต์นี้
>
> A guided walkthrough of the XjTTY-KitchenSink codebase for new developers.

---

## 1. The Big Picture

XjTTY-KitchenSink is a **pure consumer** of the `XjTTYLib` library. The app has 7 source files:

```
KSApp.xojo_code               ← Entry point. Owns everything.
KSComponentRegistry.xojo_code  ← Data: what components exist and their metadata
KSPreviewBuilder.xojo_code     ← Factory: populates preview widgets for each component
KSInteractiveLoader.xojo_code  ← Maps component entries to demo types
KSFontRenderer.xojo_code       ← Local block-art renderer (bypasses XjFont.Render crash)
KSComponentEntry.xojo_code     ← Data class: 6 fields per component
XjTTYKitchenSink.xojo_project  ← Project file (references all the above + XjTTYLib/)
```

**The rule:** `KSApp` orchestrates. `KSComponentRegistry` owns data. `KSPreviewBuilder` builds UI. `KSInteractiveLoader` maps demos. `KSFontRenderer` renders block art safely. Each file knows its job and nothing else.

---

## 2. Application Startup Flow

```
App.Run(args)
  │
  ├── 1. KSComponentRegistry.Init()        ← Load all 31 component entries
  │
  ├── 2. BuildWidgetTree()                  ← Construct the 4-panel XjBox hierarchy
  │         root (XjBox, DIR_COLUMN)
  │           ├── header
  │           ├── searchBar → mSearchInput, mCurrentLabel
  │           ├── mainArea → mListTree (left 25%) + mPreviewBox + mPropTable (right 75%)
  │           └── statusBar → mStatusDesc, mStatusKeys
  │
  ├── 3. PopulateTree()                     ← Fill mListTree from registry categories
  │
  ├── 4. SetupEventLoop()                   ← XjEventLoop(33ms) with 3 delegates:
  │         HandleKey   ← keyboard input
  │         HandleResize ← terminal resize
  │         HandleTick  ← ~30fps render cycle
  │
  ├── 5. SelectComponent(0)                 ← Load first component preview
  │
  └── 6. mLoop.Run()                        ← Hand control to event loop (blocks until quit)
```

---

## 3. KSApp — Key Properties

| Property | Type | Role |
|----------|------|------|
| `mLoop` | XjEventLoop | The 30fps event loop |
| `mCanvas` | XjCanvas | Drawing surface, sized to terminal |
| `mRoot` | XjBox | Root of the widget tree |
| `mListTree` | XjTree | Left-panel component list |
| `mPreviewBox` | XjBox | Right-panel preview container |
| `mPropTable` | XjTable | Properties panel |
| `mSearchInput` | XjTextInput | Search field |
| `mCurrentLabel` | XjText | "Current: XjFoo" label |
| `mStatusDesc` | XjText | Status bar left side |
| `mStatusKeys` | XjText | Status bar right side (keybindings) |
| `mFocus` | XjFocusManager | Tab-cycle through 3 focus zones |
| `mRegistry` | KSComponentRegistry | Component catalog |
| `mSelectedIndex` | Integer | Currently selected component (index into registry) |
| `mCompleter` | XjCompleter | Autocomplete for search |
| `mFilteredIndices()` | Integer array | Registry indices matching current search |

---

## 4. KSComponentRegistry — Data Layer

### What it stores

Each component entry (`KSComponentEntry`) has:

```xojo
// [EN] One entry per browsable component in the kitchen sink
// [TH] ข้อมูลของแต่ละ component ที่สามารถเรียกดูได้ในแอป
Name          As String    // "XjProgressBar"
Category      As String    // "Widgets"
ShortDesc     As String    // "Progress bar with format tokens and bounce mode"
LongDesc      As String    // Multi-line API description for properties panel
Keywords      As String    // "progress,bar,loading,percent,eta"
IsInteractive As Boolean   // True if preview responds to keyboard
```

### Key methods

```xojo
KSComponentRegistry.Init()                        // Populate all 31 entries
KSComponentRegistry.Count()    As Integer         // 31
KSComponentRegistry.EntryAt(i) As KSComponentEntry
KSComponentRegistry.Categories() As String()      // ["Foundation","Layout","Prompts","Styling","Utilities","Widgets"]
KSComponentRegistry.EntriesForCategory(cat) As KSComponentEntry()
KSComponentRegistry.Search(query) As Integer()    // returns matching indices
KSComponentRegistry.AllNames() As String()        // for XjCompleter
```

### Search logic

```
query → lowercase → substring match against:
  - entry.Name (lowercase)
  - entry.Category (lowercase)
  - entry.Keywords (comma-split, each lowercase)
Returns array of matching indices (empty = no results)
```

---

## 5. KSPreviewBuilder — Factory Layer

### How it works

```xojo
// [EN] The main factory: dispatches to the correct builder based on component name
// [TH] ฟังก์ชันหลักที่เลือก builder ที่ถูกต้องตามชื่อ component
Function BuildPreview(entry As KSComponentEntry) As XjBox
  Select Case entry.Name
  Case "XjBox"        : Return BuildBoxPreview()
  Case "XjProgressBar": Return BuildProgressBarPreview()
  // ... one case per component (31 total)
  End Select
```

Each `BuildXxxPreview()` method returns a standalone `XjBox` ready to drop into `mPreviewBox`.

### Interactive state

Module-level `Private` properties hold interactive preview state:

```xojo
// [EN] State for interactive previews — survives between renders
// [TH] สถานะของ preview แบบโต้ตอบ — คงอยู่ระหว่างการ render แต่ละครั้ง
Private mProgressValue   As Double   // XjProgressBar current value
Private mProgressMode    As Integer  // 0=determinate, 1=bounce
Private mSpinnerFormat   As Integer  // 0–11, current spinner format
Private mBoxBorderStyle  As Integer  // current XjBox border style
// ... etc.
```

### HandlePreviewKey

```xojo
// [EN] Routes keystrokes to the active preview's interactive handler
// [TH] ส่ง keystroke ไปยัง handler ของ preview ที่กำลังแสดงอยู่
Function HandlePreviewKey(entry As KSComponentEntry, key As XjKeyEvent) As Boolean
  // Returns True if the key was consumed by the preview
```

---

## 6. Rendering Pipeline

### Per-tick cycle (called ~30fps)

```
HandleTick(tickCount As Integer)
  │
  ├── 1. Advance animated widgets (spinner frames, progress bounce)
  │
  ├── 2. If dirty:
  │       a. XjLayoutSolver.Solve(mRoot.LayoutNode, termWidth, termHeight)
  │       b. mCanvas.Clear()
  │       c. mRoot.Paint(mCanvas)
  │       d. KSStatusBar.Render(mCanvas, termHeight-1, termWidth, currentEntry)
  │       e. XjTerminal.Write(mCanvas.Render())
  │
  └── 3. Clear dirty flag
```

### Resize handling

```
HandleResize(width, height As Integer)
  │
  ├── If width < 80 Or height < 24:
  │       Show "Terminal too small (WxH)\nMinimum required: 80x24"
  │       Return
  │
  ├── mCanvas.Resize(width, height)
  └── mRoot.MarkDirty()   ← forces full re-layout next tick
```

---

## 7. Focus System

Three focus zones cycled with `Tab` / `Shift+Tab`:

```
Zone 1: mSearchInput  → typing filters component list
Zone 2: mListTree     → arrow keys navigate, Enter selects
Zone 3: mPreviewBox   → keys routed to HandlePreviewKey (only active for interactive previews)
```

```xojo
// [EN] Build focus chain and register focusable widgets
// [TH] สร้างลำดับ focus และลงทะเบียน widget ที่รับ focus ได้
mFocus = New XjFocusManager
mFocus.BuildChain(mRoot)   // discovers XjTextInput and XjTree automatically

// [EN] In HandleKey: let focus manager try first, then check global keys
// [TH] ใน HandleKey: ให้ focus manager จัดการก่อน แล้วค่อยตรวจ global keys
If Not mFocus.HandleKey(key) Then
  // check q, ?, Tab, /, etc.
End If
```

---

## 8. Preview Swapping

When the user selects a new component:

```xojo
// [EN] Swap in a new preview by removing old children and building fresh
// [TH] สลับ preview ใหม่โดยลบ widget เก่าออกแล้วสร้างใหม่ทั้งหมด
Sub SelectComponent(index As Integer)
  mSelectedIndex = index
  Var entry As KSComponentEntry = mRegistry.EntryAt(index)

  // 1. Clear old preview
  mPreviewBox.RemoveAllChildren()

  // 2. Build and attach new preview
  Var preview As XjBox = KSPreviewBuilder.BuildPreview(entry)
  mPreviewBox.AddChild(preview)

  // 3. Populate properties table
  UpdatePropertiesTable(entry)

  // 4. Update labels
  mCurrentLabel.SetText("Current: " + entry.Name)

  // 5. Force re-render
  mRoot.MarkDirty()
End Sub
```

---

## 9. Prompt Mockups (non-interactive)

Prompts cannot run inside the event loop — they take over stdin. Instead, render styled text mockups:

```xojo
// [EN] Render a styled mockup showing what the Ask prompt looks like
// [TH] แสดงตัวอย่างรูปลักษณ์ของ Ask prompt โดยใช้ styled text แทนการรันจริง
Function BuildAskPreview() As XjBox
  Var box As New XjBox
  Var mockText As String
  mockText = XjColor.Green("? ") + XjColor.BoldText("What is your name? ")
  mockText = mockText + XjColor.Cyan("(John) ") + XjColor.DimText("_")
  Var t As New XjText(mockText)
  box.AddChild(t)
  Return box
End Function
```

---

## 10. String Performance Pattern

Follow the XjTTY-Toolkit performance convention for string building in loops:

```xojo
// [EN] Build strings efficiently using array + join (avoid += in loops)
// [TH] สร้าง string อย่างมีประสิทธิภาพโดยใช้ array แล้ว join (หลีกเลี่ยง += ใน loop)
Var parts() As String
For Each entry As KSComponentEntry In entries
  parts.Add(entry.Name)
Next
Var result As String = String.FromArray(parts, ", ")
```

---

## 11. Adding a New Component Preview

1. Add entry in `KSComponentRegistry.Init()` with name, category, description, keywords, isInteractive
2. Add a `Case "XjFoo"` branch in `KSPreviewBuilder.BuildPreview()`
3. Implement `BuildFooPreview() As XjBox`
4. If interactive: add module-level state property + case in `HandlePreviewKey()`
5. Add properties table data in `KSApp.UpdatePropertiesTable()`

---

## 12. XjTTYLib Quick Reference

Key classes used by the kitchen sink:

| Class / Module | Used for |
|----------------|----------|
| `XjBox` | All layout containers |
| `XjText` | Labels and mockup text |
| `XjTextInput` | Search field |
| `XjTable` | Properties panel |
| `XjTree` / `XjTreeNode` | Component list |
| `XjProgressBar` | Progress preview |
| `XjSpinner` | Spinner preview |
| `XjCanvas` | Drawing surface |
| `XjLayoutNode` / `XjLayoutSolver` | Layout engine |
| `XjEventLoop` | 30fps tick loop |
| `XjFocusManager` | Tab-cycle focus |
| `XjCompleter` | Search autocomplete |
| `XjTerminal` | Width/Height, Write |
| `XjColor` | ANSI color helpers |
| `XjStyle` | Text styling |

Full API for each class: see `XjTTYLib/*.xojo_code`.

---

## 13. KSFontRenderer — Tahoe-Safe Block Art

XjFont.Render() builds a large Dictionary on first call, which crashes on macOS Tahoe.
`KSFontRenderer` replicates the same glyph data as hardcoded Select Case lookups,
split across 4 small methods to stay under Tahoe's method body threshold:

```xojo
// [EN] Dispatch chain — tries each glyph group in order
// [TH] ลำดับค้นหา glyph — ลองแต่ละกลุ่มตามลำดับ
Private Function GetGlyph(ch As String) As String
  Var u As String = ch.Uppercase
  Var result As String
  result = GlyphAJ(u)   // A-J
  If result <> "" Then Return result
  result = GlyphKT(u)   // K-T
  If result <> "" Then Return result
  result = GlyphUZ(u)   // U-Z + space
  If result <> "" Then Return result
  Return GlyphNum(u)    // 0-9, punctuation
End Function
```

The demo renders into `mDemoTextWidget` (a pre-built XjText) rather than using
`RenderDemoOverlay()`, which crashes for XjFont specifically. See CLAUDE.md for details.

---

*เขียนโดย @documentator · 2026-03-17*
