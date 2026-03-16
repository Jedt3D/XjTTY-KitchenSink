#tag Module
// [EN] KSComponentRegistry — stateless factory / data store for all 31 showcased components.
//      Call Init() once; all other methods are read-only queries.
//      Categories in order: Layout (4) · Widgets (6) · Prompts (9) · Style (4) · I/O (4) · Utility (4)
// [TH] KSComponentRegistry — factory/data store ที่ไม่มี state สำหรับ component ทั้ง 31 รายการ
//      เรียก Init() ครั้งเดียว; method อื่นๆ เป็นการค้นหาแบบ read-only
//      หมวดหมู่เรียงตามลำดับ: Layout (4) · Widgets (6) · Prompts (9) · Style (4) · I/O (4) · Utility (4)
Protected Module KSComponentRegistry
	#tag Method, Flags = &h0
		Function Categories() As String()
		  // [EN] Return the distinct category names in the order they first appear in mEntries.
		  // [TH] คืนชื่อ category ที่ไม่ซ้ำกันตามลำดับที่ปรากฏครั้งแรกใน mEntries
		  Init
		  Var result() As String
		  For i As Integer = 0 To mEntries.Count - 1
		    Var cat As String = mEntries(i).Category
		    Var found As Boolean = False
		    For j As Integer = 0 To result.Count - 1
		      If result(j) = cat Then
		        found = True
		        Exit
		      End If
		    Next j
		    If Not found Then
		      result.Add(cat)
		    End If
		  Next i
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count() As Integer
		  // [EN] Total number of registered components (always 31 after Init).
		  // [TH] จำนวน component ทั้งหมดที่ลงทะเบียนแล้ว (31 เสมอหลัง Init)
		  Init
		  Return mEntries.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EntriesForCategory(cat As String) As KSComponentEntry()
		  // [EN] Return all entries whose Category matches cat, in insertion order.
		  // [TH] คืน entry ทั้งหมดที่ Category ตรงกับ cat เรียงตามลำดับที่ใส่
		  Init
		  Var result() As KSComponentEntry
		  For i As Integer = 0 To mEntries.Count - 1
		    If mEntries(i).Category = cat Then
		      result.Add(mEntries(i))
		    End If
		  Next i
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Search(query As String) As KSComponentEntry()
		  // [EN] Case-insensitive substring search across Name, Category, ShortDesc, and Keywords.
		  //      Empty query returns an empty result (caller decides what to show).
		  // [TH] ค้นหาแบบ substring ไม่คำนึงตัวพิมพ์เล็ก/ใหญ่ ครอบคลุม Name, Category, ShortDesc, Keywords
		  //      query ว่างเปล่าคืน array ว่าง (ผู้เรียกตัดสินใจว่าจะแสดงอะไร)
		  Init
		  Var result() As KSComponentEntry
		  If query = "" Then Return result

		  Var q As String = query.Lowercase
		  For i As Integer = 0 To mEntries.Count - 1
		    Var e As KSComponentEntry = mEntries(i)
		    If Instr(e.Name.Lowercase, q) > 0 Or _
		       Instr(e.ShortDesc.Lowercase, q) > 0 Or _
		       Instr(e.Keywords.Lowercase, q) > 0 Or _
		       Instr(e.Category.Lowercase, q) > 0 Then
		      result.Add(e)
		    End If
		  Next i
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EntryAt(i As Integer) As KSComponentEntry
		  // [EN] Return entry at flat index i, or Nil if out of range.
		  // [TH] คืน entry ที่ index i หรือ Nil ถ้าเกินขอบเขต
		  Init
		  If i < 0 Or i >= mEntries.Count Then Return Nil
		  Return mEntries(i)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Init()
		  // [EN] Idempotent — builds mEntries once, no-ops on subsequent calls.
		  //      31 components across 6 categories; order determines tree display order.
		  // [TH] Idempotent — สร้าง mEntries ครั้งเดียว ไม่ทำอะไรถ้าเรียกซ้ำ
		  //      31 components ใน 6 หมวดหมู่; ลำดับกำหนดการแสดงผลใน tree
		  If mInitialized Then Return
		  mInitialized = True

		  // --- Layout (4) ---
		  mEntries.Add(New KSComponentEntry( _
		    "XjBox", "Layout", _
		    "Flex container (DIR_ROW / DIR_COLUMN)", _
		    "XjBox is the primary layout container. It arranges children horizontally (DIR_ROW) or vertically (DIR_COLUMN) using XjLayoutSolver to honour each child's XjConstraint.", _
		    "layout flex container box row column direction", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjLayoutNode", "Layout", _
		    "Layout data node attached to each widget", _
		    "XjLayoutNode stores the resolved position and size of a widget after XjLayoutSolver.Solve. Every XjWidget exposes a LayoutNode property.", _
		    "layout node solved position size computed", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjConstraint", "Layout", _
		    "Size rule: Fixed / Percent / Auto / MinMax", _
		    "XjConstraint defines how a widget is sized within its parent. Chain SetMin/SetMax to clamp the result. Factories: Fixed(n), Percent(p), Auto, MinMax(lo,hi).", _
		    "constraint fixed percent auto minmax min max size", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjLayoutSolver", "Layout", _
		    "Resolves constraints to pixel coordinates", _
		    "XjLayoutSolver.Solve walks the widget tree, honours DIR_ROW/DIR_COLUMN, and writes ComputedX/Y/W/H into each XjLayoutNode. Called every frame before Paint.", _
		    "solver layout algorithm flex resolve pixel", False))

		  // --- Widgets (6) ---
		  mEntries.Add(New KSComponentEntry( _
		    "XjText", "Widgets", _
		    "Static/dynamic text label with alignment", _
		    "XjText renders one or more lines of text with left, center, or right alignment and optional word-wrap. Update live with SetText.", _
		    "text label align center left right wrap static dynamic", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjTextInput", "Widgets", _
		    "Single-line editable text field", _
		    "XjTextInput is an interactive single-line editor with a visible cursor, backspace, delete, and left/right arrow movement. Used by XjAskPrompt internally.", _
		    "input text edit cursor backspace arrow field", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjProgressBar", "Widgets", _
		    "Horizontal fill bar showing 0–100%", _
		    "XjProgressBar renders a filled horizontal bar proportional to a 0–100 value. Supports custom fill and track characters via XjStyle.", _
		    "progress bar fill percent horizontal track", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjSpinner", "Widgets", _
		    "Animated busy indicator", _
		    "XjSpinner cycles through a list of frame strings on each tick. Call Advance to step manually or let XjEventLoop drive it.", _
		    "spinner animation busy indicator frames tick cycle", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjTree", "Widgets", _
		    "Hierarchical tree with branch characters", _
		    "XjTree renders a tree with box-drawing branch characters (└─ ├─ │). Populate via AddRoot or SetData. Supports per-node XjStyle and scroll offset.", _
		    "tree hierarchy branch node expand collapse box-drawing", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjTable", "Widgets", _
		    "Multi-column tabular data grid", _
		    "XjTable renders rows and columns with optional header row and column width constraints. Useful for property sheets and comparison views.", _
		    "table grid column row header data tabular", True))

		  // --- Prompts (9) ---
		  mEntries.Add(New KSComponentEntry( _
		    "XjAskPrompt", "Prompts", _
		    "Single-line text input prompt", _
		    "XjAskPrompt presents a labeled text field. The user types a value and presses Enter. Supports optional default value and validation callback.", _
		    "ask prompt input text answer single-line label", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjConfirmPrompt", "Prompts", _
		    "Yes/No confirmation dialog", _
		    "XjConfirmPrompt shows a question with Y/N keys. Returns Boolean. Supports custom true/false labels and default answer.", _
		    "confirm yes no question dialog boolean", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjSelectPrompt", "Prompts", _
		    "Single-item selection from a list", _
		    "XjSelectPrompt lets the user pick one item from an XjOption array using arrow keys and Enter. Supports search-to-filter.", _
		    "select list choice single pick arrow option", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjMultiSelectPrompt", "Prompts", _
		    "Multi-item selection with checkboxes", _
		    "XjMultiSelectPrompt allows toggling multiple items with Space and confirming with Enter. Each item is displayed with a [x] checkbox.", _
		    "multiselect checkbox pick multiple toggle space confirm", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjExpandPrompt", "Prompts", _
		    "Collapsed/expanded key-choice prompt", _
		    "XjExpandPrompt shows a compact key list (e.g. [y/n/a/?]). Typing ? expands to the full option list. Ideal for git-style prompts.", _
		    "expand collapse choice key shortcut compact git-style", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjEnumSelectPrompt", "Prompts", _
		    "Enum-based single choice prompt", _
		    "XjEnumSelectPrompt wraps XjSelectPrompt with enum string labels. Returns the selected enum value as a String.", _
		    "enum select type choice string value", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjSuggestPrompt", "Prompts", _
		    "Text input with autocomplete dropdown", _
		    "XjSuggestPrompt combines XjTextInput with XjCompleter. Typing filters a dropdown of suggestions; Tab or Enter accepts the top match.", _
		    "suggest autocomplete completion dropdown hint tab", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjCollectPrompt", "Prompts", _
		    "Multi-entry collection builder", _
		    "XjCollectPrompt lets the user build a list by entering values one at a time. An empty entry finalises the list.", _
		    "collect list entries multi add build empty done", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjKeyPressPrompt", "Prompts", _
		    "Single keystroke capture", _
		    "XjKeyPressPrompt waits for one keypress and returns it as XjKeyEvent without requiring Enter. Used for menu shortcuts and pagers.", _
		    "key press capture keystroke raw single menu", True))

		  // --- Style (4) ---
		  mEntries.Add(New KSComponentEntry( _
		    "XjStyle", "Style", _
		    "Composable ANSI text style (immutable builder)", _
		    "XjStyle is an immutable-style builder. Chain SetFG/SetBG/SetBold/SetInverse etc.; each returns a new instance. Apply(text) wraps with ANSI codes + reset.", _
		    "style ansi bold color fg bg italic underline inverse dim", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjFont", "Style", _
		    "Large text art renderer using glyphs", _
		    "XjFont renders large ASCII-art text using pre-defined glyph matrices. Useful for banners, headers, and numeric displays.", _
		    "font art text glyph large render banner ascii", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjPie", "Style", _
		    "ASCII pie chart using block characters", _
		    "XjPie renders a circular pie chart using Unicode block and braille characters. Supply slice percentages and optional labels.", _
		    "pie chart visual ascii graph slice block braille", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjColor", "Style", _
		    "Color constants and palette helpers", _
		    "XjColor provides named constants for the 16-color ANSI palette and helpers for 256-color and 24-bit RGB lookups.", _
		    "color ansi 256 palette rgb 16 named constant", True))

		  // --- I/O (4) ---
		  mEntries.Add(New KSComponentEntry( _
		    "XjCanvas", "I/O", _
		    "2D character buffer for off-screen rendering", _
		    "XjCanvas is a width×height grid of XjCell. Widgets paint into it with WriteText/DrawBox. Render() converts to an ANSI string; DiffRender() sends only changed cells.", _
		    "canvas buffer cell render diff screen offscreen 2d", True))
		  mEntries.Add(New KSComponentEntry( _
		    "XjTerminal", "I/O", _
		    "Terminal size, write, and raw-mode control", _
		    "XjTerminal is a low-level module wrapping POSIX terminal I/O: Width/Height, Write, EnableRawMode, DisableRawMode, GetSize (TIOCGWINSZ).", _
		    "terminal raw size write read sigwinch ioctl posix", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjReader", "I/O", _
		    "Line-by-line terminal input reader", _
		    "XjReader reads complete lines from stdin with optional prompt. Supports history navigation if paired with XjHistory.", _
		    "reader input line stdin buffer history prompt", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjPager", "I/O", _
		    "Scrollable multi-page content viewer", _
		    "XjPager renders paginated content with Page Up/Down, Home, End, and q-to-quit navigation. Accepts a String array of lines.", _
		    "pager scroll page view content lines up down home end", False))

		  // --- Utility (4) ---
		  mEntries.Add(New KSComponentEntry( _
		    "XjEventLoop", "Utility", _
		    "30fps loop with raw mode and SIGWINCH", _
		    "XjEventLoop drives the TUI render cycle at a configurable tick rate. AutoAlternateScreen, AutoHideCursor, AutoRawMode. Fires OnKeyPress, OnResize, OnTick.", _
		    "eventloop tick fps raw resize sigwinch alternate cursor", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjKeyEvent", "Utility", _
		    "Key event model with codes and modifiers", _
		    "XjKeyEvent wraps a terminal keypress: KeyCode (KEY_UP, KEY_DOWN, KEY_ENTER, KEY_TAB…), Char, IsCtrl, IsShift. KEY_CHAR=0 for printable input.", _
		    "key event code char ctrl shift modifier arrow tab enter", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjFocusManager", "Utility", _
		    "Tab-cycling focus chain manager", _
		    "XjFocusManager collects focusable widgets via BuildChain, then routes Tab/Shift-Tab for cycling and forwards other keys to the focused widget.", _
		    "focus manager tab chain cycle widget backtab shift", False))
		  mEntries.Add(New KSComponentEntry( _
		    "XjCommand", "Utility", _
		    "Shell command runner with output capture", _
		    "XjCommand runs a shell command synchronously and returns an XjCommandResult with stdout, stderr, and exit code. Safe for build tools and linters.", _
		    "command shell run execute result stdout stderr exit code", False))
		End Sub
	#tag EndMethod


	// [EN] mEntries — flat ordered list of all 31 component records.
	// [TH] mEntries — รายการเรียงลำดับของ component record ทั้ง 31 รายการ
	#tag Property, Flags = &h21
		Private mEntries() As KSComponentEntry
	#tag EndProperty

	// [EN] mInitialized — guard flag so Init() populates mEntries only once.
	// [TH] mInitialized — flag ป้องกันไม่ให้ Init() สร้าง mEntries ซ้ำ
	#tag Property, Flags = &h21
		Private mInitialized As Boolean
	#tag EndProperty

End Module
#tag EndModule
