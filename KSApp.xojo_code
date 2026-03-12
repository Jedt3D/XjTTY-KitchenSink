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
		  //      → populate registry → pre-select first item → hand control to loop.
		  // [TH] Entry point เดียว — ถูกเรียกครั้งเดียวโดย Xojo runtime
		  //      ลำดับ: จับขนาด terminal → สร้าง canvas → สร้าง UI tree
		  //      → ป้อนข้อมูล registry → เลือก item แรก → ส่งการควบคุมให้ loop
		  #Pragma Unused args

		  mTermWidth = XjTerminal.Width
		  mTermHeight = XjTerminal.Height
		  mCanvas = New XjCanvas(mTermWidth, mTermHeight)

		  BuildWidgetTree()
		  PopulateTree()
		  If mFlatNodes.Count > 0 Then SelectLine(0)

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
		  // [EN] Construct the 4-panel layout. Phase 2 additions: mListTree in componentList,
		  //      mCurrentLabel in livePreview, mStatusDesc + key hint in statusBar.
		  //      Layout: root(column) → header / searchBar / mainArea / statusBar
		  //              mainArea(row) → componentList(25%) | previewArea(auto)
		  //              previewArea(column) → livePreview(auto) / propertiesPanel(30%)
		  // [TH] สร้างโครงสร้าง layout 4 ส่วน Phase 2 เพิ่ม: mListTree ใน componentList,
		  //      mCurrentLabel ใน livePreview, mStatusDesc + key hint ใน statusBar
		  mRoot = New XjBox
		  Call mRoot.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call mRoot.SetBorder(0, New XjStyle)
		  Call mRoot.SetTitle(" XjTTY-Toolkit Kitchen Sink ")

		  // [EN] Header: fixed 3 rows, no border — placeholder for Phase 6 title/version bar
		  // [TH] Header: ความสูงคงที่ 3 แถว ไม่มีขอบ — พื้นที่สำรองสำหรับ Phase 6 title/version bar
		  Var header As New XjBox
		  Call header.SetDirection(XjLayoutNode.DIR_ROW)
		  Call header.SetHeight(XjConstraint.Fixed(3))
		  mRoot.AddChild(header)

		  // [EN] Search bar: fixed 3 rows, single border — Phase 3 will embed XjTextInput here
		  // [TH] Search bar: ความสูงคงที่ 3 แถว มีขอบ — Phase 3 จะฝัง XjTextInput ที่นี่
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

		  // [EN] Component list: 25% width min 20 cols, single border, owns mListTree
		  // [TH] Component list: กว้าง 25% ขั้นต่ำ 20 คอลัมน์ มีขอบ เป็นเจ้าของ mListTree
		  Var componentList As New XjBox
		  Call componentList.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call componentList.SetWidth(XjConstraint.Percent(25).SetMin(20))
		  Call componentList.SetBorder(0, New XjStyle)
		  Call componentList.SetTitle(" Components ")
		  mainArea.AddChild(componentList)

		  // [EN] XjTree fills the componentList panel — driven by mFlatNodes / mScrollOffset
		  // [TH] XjTree เต็มพื้นที่ componentList — ขับเคลื่อนด้วย mFlatNodes / mScrollOffset
		  mListTree = New XjTree
		  componentList.AddChild(mListTree)

		  // [EN] Preview area: fills remaining width, owns livePreview + propertiesPanel
		  // [TH] Preview area: ขยายเต็มความกว้างที่เหลือ เป็นเจ้าของ livePreview + propertiesPanel
		  Var previewArea As New XjBox
		  Call previewArea.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call previewArea.SetBorder(0, New XjStyle)
		  Call previewArea.SetTitle(" Preview ")
		  mainArea.AddChild(previewArea)

		  // [EN] Live preview: auto height — Phase 4 will swap in KSPreviewBuilder content here
		  // [TH] Live preview: ความสูง auto — Phase 4 จะสลับเนื้อหา KSPreviewBuilder ที่นี่
		  Var livePreview As New XjBox
		  Call livePreview.SetDirection(XjLayoutNode.DIR_COLUMN)
		  previewArea.AddChild(livePreview)

		  // [EN] mCurrentLabel: shows selected component name centered in livePreview
		  // [TH] mCurrentLabel: แสดงชื่อ component ที่เลือกตรงกลาง livePreview
		  mCurrentLabel = New XjText
		  Call mCurrentLabel.SetText("<- select a component")
		  Call mCurrentLabel.SetAlign(XjText.ALIGN_CENTER)
		  livePreview.AddChild(mCurrentLabel)

		  // [EN] Properties panel: 30% of preview height, min 5 rows, single border
		  // [TH] Properties panel: 30% ของความสูง preview, ขั้นต่ำ 5 แถว, มีขอบเดี่ยว
		  Var propertiesPanel As New XjBox
		  Call propertiesPanel.SetHeight(XjConstraint.Percent(30).SetMin(5))
		  Call propertiesPanel.SetBorder(0, New XjStyle)
		  Call propertiesPanel.SetTitle(" Properties ")
		  previewArea.AddChild(propertiesPanel)

		  // [EN] Status bar: fixed 1 row, DIR_ROW — description (auto) + key hint (fixed 24)
		  // [TH] Status bar: ความสูง 1 แถว DIR_ROW — คำอธิบาย (auto) + key hint (fixed 24)
		  Var statusBar As New XjBox
		  Call statusBar.SetDirection(XjLayoutNode.DIR_ROW)
		  Call statusBar.SetHeight(XjConstraint.Fixed(1))
		  mRoot.AddChild(statusBar)

		  // [EN] mStatusDesc fills remaining width; updated by SelectLine on every navigation
		  // [TH] mStatusDesc ขยายเต็มความกว้างที่เหลือ; อัปเดตโดย SelectLine ทุกครั้งที่ navigate
		  mStatusDesc = New XjText
		  Call mStatusDesc.SetText(" Welcome -- use arrow keys to navigate")
		  Call mStatusDesc.SetWidth(XjConstraint.Auto())
		  statusBar.AddChild(mStatusDesc)

		  // [EN] Key hint: right-aligned fixed-width label showing available shortcuts
		  // [TH] Key hint: label กว้างคงที่ชิดขวา แสดง shortcut ที่ใช้ได้
		  Var keysHint As New XjText
		  Call keysHint.SetText("Up/Dn Navigate   q Quit")
		  Call keysHint.SetWidth(XjConstraint.Fixed(24))
		  Call keysHint.SetAlign(XjText.ALIGN_RIGHT)
		  statusBar.AddChild(keysHint)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  // [EN] Global quit: 'q' (graceful) or Chr(3) = Ctrl+C (raw mode intercept).
		  //      All other keys are forwarded to HandleListKey for navigation.
		  // [TH] ออกจากแอปแบบ global: 'q' (ปกติ) หรือ Chr(3) = Ctrl+C (ดักจับใน raw mode)
		  //      key อื่นๆ ทั้งหมดส่งต่อไปยัง HandleListKey สำหรับการ navigate
		  If key.Char = "q" Or key.Char = Chr(3) Then
		    mLoop.Stop_()
		    Return
		  End If

		  HandleListKey(key)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleListKey(key As XjKeyEvent)
		  // [EN] Translate KEY_UP / KEY_DOWN / KEY_ENTER into SelectLine calls.
		  //      Category rows (mFlatEntries = Nil) are navigable but not "selectable"
		  //      for Phase 4 preview purposes — Enter on them is a no-op for now.
		  // [TH] แปลง KEY_UP / KEY_DOWN / KEY_ENTER เป็นการเรียก SelectLine
		  //      แถว category (mFlatEntries = Nil) สามารถ navigate ได้แต่ยังไม่ "select"
		  //      สำหรับ Phase 4 preview — Enter บน category ยังไม่ทำอะไร
		  Select Case key.KeyCode
		  Case XjKeyEvent.KEY_UP
		    If mSelectedLine > 0 Then
		      SelectLine(mSelectedLine - 1)
		    End If

		  Case XjKeyEvent.KEY_DOWN
		    If mSelectedLine < mFlatNodes.Count - 1 Then
		      SelectLine(mSelectedLine + 1)
		    End If

		  Case XjKeyEvent.KEY_ENTER
		    // [EN] Phase 4: launch KSPreviewBuilder for the selected component.
		    //      For now, leaf selection is acknowledged via the status bar only.
		    // [TH] Phase 4: เรียก KSPreviewBuilder สำหรับ component ที่เลือก
		    //      ตอนนี้การเลือก leaf node แสดงผลเฉพาะใน status bar
		    If mSelectedLine >= 0 And mSelectedLine < mFlatEntries.Count Then
		      Var entry As KSComponentEntry = mFlatEntries(mSelectedLine)
		      If Not (entry Is Nil) Then
		        Call mStatusDesc.SetText(" [selected] " + entry.Name + " — " + entry.ShortDesc)
		      End If
		    End If

		  End Select
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
		Private Sub PopulateTree()
		  // [EN] Build the XjTree data from KSComponentRegistry and maintain two parallel
		  //      flat arrays so KSApp can map tree line index ↔ component entry directly.
		  //      mFlatNodes(i) = XjTreeNode for visible line i.
		  //      mFlatEntries(i) = Nil for category headers, KSComponentEntry for leaf rows.
		  // [TH] สร้างข้อมูล XjTree จาก KSComponentRegistry และรักษา flat array คู่ขนาน
		  //      mFlatNodes(i) = XjTreeNode สำหรับบรรทัด i ที่มองเห็น
		  //      mFlatEntries(i) = Nil สำหรับ category header, KSComponentEntry สำหรับ leaf
		  KSComponentRegistry.Init()

		  mFlatNodes.RemoveAll
		  mFlatEntries.RemoveAll
		  mSelectedLine = -1
		  mScrollOffset = 0

		  // [EN] Category nodes styled cyan+bold; leaf nodes use XjTree default (white).
		  // [TH] Category node ใช้สี cyan+bold; leaf node ใช้ค่าเริ่มต้นของ XjTree (ขาว)
		  Var catBase As New XjStyle
		  Var catWithCyan As XjStyle = catBase.SetFG(XjANSI.FG_CYAN)
		  Var catStyle As XjStyle = catWithCyan.SetBold()

		  Var roots() As XjTreeNode
		  Var cats() As String = KSComponentRegistry.Categories()

		  For i As Integer = 0 To cats.Count - 1
		    Var cat As String = cats(i)

		    Var catNode As New XjTreeNode(cat)
		    Call catNode.SetNodeStyle(catStyle)
		    mFlatNodes.Add(catNode)
		    mFlatEntries.Add(Nil)  // category row has no component entry

		    Var entries() As KSComponentEntry = KSComponentRegistry.EntriesForCategory(cat)
		    For j As Integer = 0 To entries.Count - 1
		      Var leafNode As New XjTreeNode(entries(j).Name)
		      Call catNode.AddChild(leafNode)
		      mFlatNodes.Add(leafNode)
		      mFlatEntries.Add(entries(j))
		    Next j

		    roots.Add(catNode)
		  Next i

		  Call mListTree.SetData(roots)
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

	#tag Method, Flags = &h21
		Private Sub SelectLine(lineIdx As Integer)
		  // [EN] Move the selection cursor to lineIdx:
		  //      1. Restore the previous node's style (cyan+bold for category, Nil for leaf).
		  //      2. Apply inverse highlight to the new node.
		  //      3. Update mStatusDesc and mCurrentLabel.
		  //      4. Adjust mScrollOffset to keep the cursor within the visible window.
		  //      5. Call SetScrollOffset to mark XjTree dirty for the next paint.
		  // [TH] เลื่อน cursor การเลือกไปยัง lineIdx:
		  //      1. คืนสไตล์ของ node ก่อนหน้า (cyan+bold สำหรับ category, Nil สำหรับ leaf)
		  //      2. ใส่ inverse highlight บน node ใหม่
		  //      3. อัปเดต mStatusDesc และ mCurrentLabel
		  //      4. ปรับ mScrollOffset ให้ cursor อยู่ในขอบเขตที่มองเห็น
		  //      5. เรียก SetScrollOffset เพื่อ mark XjTree dirty สำหรับการ paint ครั้งถัดไป

		  // [EN] Step 1: restore previous node style
		  // [TH] ขั้นที่ 1: คืนสไตล์ของ node ก่อนหน้า
		  If mSelectedLine >= 0 And mSelectedLine < mFlatNodes.Count Then
		    If mFlatEntries(mSelectedLine) Is Nil Then
		      // [EN] Category header — restore cyan+bold
		      // [TH] Category header — คืน cyan+bold
		      Var restoreBase As New XjStyle
		      Var restoreWithCyan As XjStyle = restoreBase.SetFG(XjANSI.FG_CYAN)
		      Var restoreStyle As XjStyle = restoreWithCyan.SetBold()
		      Call mFlatNodes(mSelectedLine).SetNodeStyle(restoreStyle)
		    Else
		      // [EN] Leaf node — restore XjTree default (Nil = use tree's mNodeStyle = white)
		      // [TH] Leaf node — คืนค่าเริ่มต้น XjTree (Nil = ใช้ mNodeStyle ของ tree = ขาว)
		      Call mFlatNodes(mSelectedLine).SetNodeStyle(Nil)
		    End If
		  End If

		  mSelectedLine = lineIdx

		  // [EN] Guard against out-of-range index
		  // [TH] ป้องกัน index ที่เกินขอบเขต
		  If lineIdx < 0 Or lineIdx >= mFlatNodes.Count Then Return

		  // [EN] Step 2: highlight selected node with inverse style
		  // [TH] ขั้นที่ 2: ไฮไลต์ node ที่เลือกด้วยสไตล์ inverse
		  Var invBase As New XjStyle
		  Var invStyle As XjStyle = invBase.SetInverse()
		  Call mFlatNodes(lineIdx).SetNodeStyle(invStyle)

		  // [EN] Step 3: update status bar description and preview label
		  // [TH] ขั้นที่ 3: อัปเดตคำอธิบาย status bar และ preview label
		  Var entry As KSComponentEntry = mFlatEntries(lineIdx)
		  If entry Is Nil Then
		    Call mStatusDesc.SetText(" [" + mFlatNodes(lineIdx).Label + "] category")
		    Call mCurrentLabel.SetText("<- select a component")
		  Else
		    Call mStatusDesc.SetText(" " + entry.ShortDesc)
		    Call mCurrentLabel.SetText(entry.Name)
		  End If

		  // [EN] Step 4: scroll to keep cursor visible.
		  //      Visible rows = termHeight − 2(mRoot border) − 3(header) − 3(searchBar)
		  //                              − 1(statusBar) − 2(componentList border) = termHeight − 11
		  // [TH] ขั้นที่ 4: เลื่อน scroll เพื่อให้ cursor อยู่ในขอบเขตที่มองเห็น
		  Var visibleH As Integer = mTermHeight - 11
		  If visibleH < 1 Then visibleH = 1
		  If lineIdx < mScrollOffset Then
		    mScrollOffset = lineIdx
		  ElseIf lineIdx >= mScrollOffset + visibleH Then
		    mScrollOffset = lineIdx - visibleH + 1
		  End If

		  // [EN] Step 5: mark XjTree dirty via SetScrollOffset (triggers repaint next tick)
		  // [TH] ขั้นที่ 5: mark XjTree dirty ผ่าน SetScrollOffset (trigger repaint ใน tick ถัดไป)
		  Call mListTree.SetScrollOffset(mScrollOffset)
		End Sub
	#tag EndMethod


	// [EN] mCanvas       — 2D character buffer sized to the current terminal dimensions
	// [EN] mCurrentLabel — XjText in livePreview showing the selected component name
	// [EN] mFlatEntries  — parallel to mFlatNodes; Nil = category row, else KSComponentEntry
	// [EN] mFlatNodes    — XjTreeNode references in visible tree order for highlight/scroll
	// [EN] mListTree     — XjTree widget inside componentList panel
	// [EN] mLoop         — 30fps event loop; owns raw mode, alternate screen, and all callbacks
	// [EN] mRoot         — root of the widget tree; parent of all 4 panels
	// [EN] mScrollOffset — current XjTree scroll position (first visible line index)
	// [EN] mSelectedLine — currently highlighted flat-list index (-1 = none)
	// [EN] mStatusDesc   — XjText in status bar showing the short description on selection
	// [EN] mTermWidth/Height — current terminal dimensions, updated on every resize event
	// [TH] mCanvas       — บัฟเฟอร์อักขระ 2D ที่มีขนาดตรงกับ terminal ปัจจุบัน
	// [TH] mCurrentLabel — XjText ใน livePreview แสดงชื่อ component ที่เลือก
	// [TH] mFlatEntries  — คู่ขนานกับ mFlatNodes; Nil = แถว category, มิฉะนั้น KSComponentEntry
	// [TH] mFlatNodes    — อ้างอิง XjTreeNode ตามลำดับที่มองเห็นใน tree สำหรับ highlight/scroll
	// [TH] mListTree     — XjTree widget ภายใน panel componentList
	// [TH] mLoop         — event loop 30fps; ควบคุม raw mode, alternate screen และ callback ทั้งหมด
	// [TH] mRoot         — root ของ widget tree; parent ของ panel ทั้ง 4 ส่วน
	// [TH] mScrollOffset — ตำแหน่ง scroll ปัจจุบันของ XjTree (index บรรทัดแรกที่มองเห็น)
	// [TH] mSelectedLine — index flat-list ที่ไฮไลต์อยู่ (-1 = ยังไม่เลือก)
	// [TH] mStatusDesc   — XjText ใน status bar แสดงคำอธิบายสั้นเมื่อเลือก
	// [TH] mTermWidth/Height — ขนาด terminal ปัจจุบัน อัปเดตทุกครั้งที่มี resize event
	#tag Property, Flags = &h21
		Private mCanvas As XjCanvas
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCurrentLabel As XjText
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFlatEntries() As KSComponentEntry
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFlatNodes() As XjTreeNode
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mListTree As XjTree
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLoop As XjEventLoop
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRoot As XjBox
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScrollOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelectedLine As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStatusDesc As XjText
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
