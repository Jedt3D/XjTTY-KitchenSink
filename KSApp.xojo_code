#tag Class
// [EN] KSApp is the application entry point. It owns the widget tree, event loop,
//      canvas, and all top-level UI state. Other modules (Registry, PreviewBuilder,
//      StatusBar) are stateless factories or data stores that KSApp orchestrates.
// [TH] KSApp คือจุดเริ่มต้นของแอปพลิเคชัน เป็นเจ้าของ widget tree, event loop,
//      canvas และ state ระดับบนสุดทั้งหมด โมดูลอื่นๆ (Registry, PreviewBuilder,
//      StatusBar) เป็น factory หรือ data store ที่ไม่มี state โดย KSApp เป็นตัวประสาน
Protected Class KSApp
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  // [EN] Single entry point — called once by the Xojo runtime.
		  //      Sequence: snapshot terminal size → create canvas → build UI tree
		  //      → configure event loop → hand control to loop (blocks until quit).
		  // [TH] Entry point เดียว — ถูกเรียกครั้งเดียวโดย Xojo runtime
		  //      ลำดับ: จับขนาด terminal → สร้าง canvas → สร้าง UI tree
		  //      → ตั้งค่า event loop → ส่งการควบคุมให้ loop (บล็อกจนกว่าจะออก)
		  #Pragma Unused args

		  mTermWidth = XjTerminal.Width
		  mTermHeight = XjTerminal.Height
		  mCanvas = New XjCanvas(mTermWidth, mTermHeight)

		  BuildWidgetTree()

		  // [EN] 33ms interval ≈ 30fps. AutoAlternateScreen enters fullscreen TUI mode
		  //      and restores the normal terminal on exit automatically.
		  // [TH] ช่วง 33ms ≈ 30fps. AutoAlternateScreen เข้าสู่โหมด fullscreen TUI
		  //      และคืนค่า terminal ปกติเมื่อออกโดยอัตโนมัติ
		  mLoop = New XjEventLoop(33)
		  mLoop.AutoAlternateScreen = True
		  mLoop.AutoHideCursor = True
		  mLoop.SetOnKeyPress(AddressOf HandleKey)
		  mLoop.SetOnResize(AddressOf HandleResize)
		  mLoop.SetOnTick(AddressOf HandleTick)
		  mLoop.Run()

		  Return 0
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub BuildWidgetTree()
		  // [EN] Construct the static 4-panel layout skeleton. No content yet —
		  //      just the container hierarchy with constraints.
		  //      Layout: root(column) → header / searchBar / mainArea / statusBar
		  //              mainArea(row) → componentList(25%) | previewArea(75%)
		  //              previewArea(column) → livePreview(auto) / propertiesPanel(30%)
		  // [TH] สร้างโครงสร้าง layout 4 ส่วนแบบ static ยังไม่มีเนื้อหา —
		  //      เป็นเพียง container hierarchy พร้อม constraint
		  //      Layout: root(column) → header / searchBar / mainArea / statusBar
		  //              mainArea(row) → componentList(25%) | previewArea(75%)
		  //              previewArea(column) → livePreview(auto) / propertiesPanel(30%)
		  mRoot = New XjBox
		  Call mRoot.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call mRoot.SetBorder(0, New XjStyle)
		  Call mRoot.SetTitle(" XjTTY-Toolkit Kitchen Sink ")

		  // [EN] Header: fixed 3 rows, no border — reserved for title/version/date (Phase 2+)
		  // [TH] Header: ความสูงคงที่ 3 แถว ไม่มีขอบ — สำรองไว้สำหรับ title/version/date (Phase 2+)
		  Var header As New XjBox
		  Call header.SetDirection(XjLayoutNode.DIR_ROW)
		  Call header.SetHeight(XjConstraint.Fixed(3))
		  mRoot.AddChild(header)

		  // [EN] Search bar: fixed 3 rows, single border — will hold XjTextInput (Phase 3)
		  // [TH] Search bar: ความสูงคงที่ 3 แถว มีขอบ — จะใส่ XjTextInput ใน Phase 3
		  Var searchBar As New XjBox
		  Call searchBar.SetDirection(XjLayoutNode.DIR_ROW)
		  Call searchBar.SetHeight(XjConstraint.Fixed(3))
		  Call searchBar.SetBorder(0, New XjStyle)
		  mRoot.AddChild(searchBar)

		  // [EN] Main area: fills remaining height, splits left/right via DIR_ROW
		  // [TH] Main area: ขยายเต็มความสูงที่เหลือ แบ่งซ้าย/ขวาด้วย DIR_ROW
		  Var mainArea As New XjBox
		  Call mainArea.SetDirection(XjLayoutNode.DIR_ROW)
		  mRoot.AddChild(mainArea)

		  // [EN] Component list: 25% width, min 20 cols to stay usable on small terminals
		  // [TH] Component list: กว้าง 25% โดยมีขั้นต่ำ 20 คอลัมน์เพื่อให้ใช้งานได้บน terminal เล็ก
		  Var componentList As New XjBox
		  Call componentList.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call componentList.SetWidth(XjConstraint.Percent(25).SetMin(20))
		  Call componentList.SetBorder(0, New XjStyle)
		  Call componentList.SetTitle(" Components ")
		  mainArea.AddChild(componentList)

		  // [EN] Preview area: fills remaining width (auto), holds livePreview + propertiesPanel
		  // [TH] Preview area: ขยายเต็มความกว้างที่เหลือ (auto) รองรับ livePreview และ propertiesPanel
		  Var previewArea As New XjBox
		  Call previewArea.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call previewArea.SetBorder(0, New XjStyle)
		  Call previewArea.SetTitle(" Preview ")
		  mainArea.AddChild(previewArea)

		  // [EN] Live preview: auto height — expands to fill space above the properties panel
		  // [TH] Live preview: ความสูง auto — ขยายเต็มพื้นที่เหนือ properties panel
		  Var livePreview As New XjBox
		  previewArea.AddChild(livePreview)

		  // [EN] Properties panel: 30% of preview height, min 5 rows, single border
		  // [TH] Properties panel: 30% ของความสูง preview, ขั้นต่ำ 5 แถว, มีขอบเดี่ยว
		  Var propertiesPanel As New XjBox
		  Call propertiesPanel.SetHeight(XjConstraint.Percent(30).SetMin(5))
		  Call propertiesPanel.SetBorder(0, New XjStyle)
		  Call propertiesPanel.SetTitle(" Properties ")
		  previewArea.AddChild(propertiesPanel)

		  // [EN] Status bar: fixed 1 row, no border — shows description + keybindings (Phase 2+)
		  // [TH] Status bar: ความสูงคงที่ 1 แถว ไม่มีขอบ — แสดงคำอธิบายและ keybinding (Phase 2+)
		  Var statusBar As New XjBox
		  Call statusBar.SetDirection(XjLayoutNode.DIR_ROW)
		  Call statusBar.SetHeight(XjConstraint.Fixed(1))
		  mRoot.AddChild(statusBar)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  // [EN] Global quit: 'q' (graceful) or Chr(3) = Ctrl+C (raw mode intercept)
		  // [TH] ออกจากแอปแบบ global: 'q' (ปกติ) หรือ Chr(3) = Ctrl+C (ดักจับใน raw mode)
		  If key.Char = "q" Or key.Char = Chr(3) Then
		    mLoop.Stop_()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleResize(w As Integer, h As Integer)
		  // [EN] Resize handler: update stored dimensions and resize the canvas buffer.
		  //      The next Render() call will re-solve the layout at the new size.
		  // [TH] Resize handler: อัปเดตขนาดที่เก็บไว้และปรับขนาด canvas buffer
		  //      การเรียก Render() ครั้งถัดไปจะคำนวณ layout ใหม่ตามขนาดที่เปลี่ยนไป
		  mTermWidth = w
		  mTermHeight = h
		  mCanvas.Resize(w, h)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleTick(tickCount As Integer)
		  // [EN] Called ~30fps by XjEventLoop. Drives the render cycle every frame.
		  //      Animated widgets (spinners, progress bounce) will update here in Phase 5.
		  // [TH] ถูกเรียก ~30fps โดย XjEventLoop ขับเคลื่อน render cycle ทุกเฟรม
		  //      widget ที่มีแอนิเมชัน (spinner, progress bounce) จะอัปเดตที่นี่ใน Phase 5
		  #Pragma Unused tickCount
		  Render()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Render()
		  // [EN] Guard: if terminal is too small, skip layout and show a plain message.
		  //      Minimum 80×24 is required for the 4-panel layout to be usable.
		  // [TH] ตรวจสอบ: ถ้า terminal เล็กเกินไป ข้ามการคำนวณ layout และแสดงข้อความธรรมดา
		  //      ต้องการขั้นต่ำ 80×24 เพื่อให้ layout 4 ส่วนทำงานได้
		  If mTermWidth < 80 Or mTermHeight < 24 Then
		    XjScreen.Clear()
		    XjTerminal.Write("Terminal too small (" + mTermWidth.ToString + "x" + mTermHeight.ToString + ")" + Chr(10) + "Minimum required: 80x24")
		    Return
		  End If

		  // [EN] Render pipeline: solve layout → clear canvas → paint widget tree → flush to terminal
		  // [TH] Render pipeline: คำนวณ layout → ล้าง canvas → วาด widget tree → ส่งออกไปยัง terminal
		  XjLayoutSolver.Solve(mRoot.LayoutNode, mTermWidth, mTermHeight)
		  mCanvas.Clear()
		  mRoot.Paint(mCanvas)
		  XjTerminal.Write(mCanvas.Render())
		End Sub
	#tag EndMethod


	// [EN] mCanvas  — 2D character buffer sized to the current terminal dimensions
	// [EN] mLoop    — 30fps event loop; owns raw mode, alternate screen, and all callbacks
	// [EN] mRoot    — root of the widget tree; parent of all 4 panels
	// [EN] mTermWidth/Height — current terminal dimensions, updated on every resize event
	// [TH] mCanvas  — บัฟเฟอร์อักขระ 2D ที่มีขนาดตรงกับ terminal ปัจจุบัน
	// [TH] mLoop    — event loop 30fps; ควบคุม raw mode, alternate screen และ callback ทั้งหมด
	// [TH] mRoot    — root ของ widget tree; parent ของ panel ทั้ง 4 ส่วน
	// [TH] mTermWidth/Height — ขนาด terminal ปัจจุบัน อัปเดตทุกครั้งที่มี resize event
	#tag Property, Flags = &h21
		Private mCanvas As XjCanvas
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLoop As XjEventLoop
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRoot As XjBox
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTermHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTermWidth As Integer
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
