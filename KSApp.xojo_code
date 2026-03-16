#tag Class
// [EN] KSApp is the application entry point. It owns the widget tree, event loop,
//      canvas, and all top-level UI state. Other modules (Registry, PreviewBuilder,
//      InteractiveLoader) are stateless factories or data stores that KSApp orchestrates.
//      Phase 3: two-mode key routing — list mode (default) and search mode.
//      Phase 4: static previews — KSPreviewBuilder populates mPreviewTitle,
//               mPreviewBody, and mPropsTable on every navigation step.
//      Phase 5: interactive previews — three focus zones; Tab enters the live demo
//               widget in the preview panel; Esc returns to list navigation.
//      Phase 6: polish — help overlay (? key), category jump (1–6),
//               Page Up/Down, Home/End in component list.
// [TH] KSApp คือจุดเริ่มต้นของแอปพลิเคชัน เป็นเจ้าของ widget tree, event loop,
//      canvas และ state ระดับบนสุดทั้งหมด
//      Phase 3: key routing สองโหมด — list mode (เริ่มต้น) และ search mode
//      Phase 4: static previews — KSPreviewBuilder ป้อนข้อมูล mPreviewTitle,
//               mPreviewBody และ mPropsTable ทุกครั้งที่ navigate
//      Phase 5: interactive previews — 3 focus zones; Tab เข้า live demo widget
//               ใน preview panel; Esc กลับสู่ list navigation
//      Phase 6: polish — help overlay (? key), category jump (1–6),
//               PgUp/PgDn/Home/End ใน component list
Protected Class KSApp
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  // [EN] Single entry point. Sequence: snapshot terminal → canvas → UI tree
		  //      → populate registry → pre-select first item → event loop.
		  // [TH] Entry point เดียว ลำดับ: จับขนาด terminal → canvas → UI tree
		  //      → ป้อน registry → เลือก item แรก → event loop
		  #Pragma Unused args

		  mTermWidth = XjTerminal.Width
		  mTermHeight = XjTerminal.Height
		  mCanvas = New XjCanvas(mTermWidth, mTermHeight)

		  BuildWidgetTree()
		  PopulateTree()

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
		Private Sub ActivateDemoWidget(demoType As String)
		  // [EN] Collapse all Phase 5 demo widgets, then reveal the one matching demoType.
		  //      Also resets mPreviewFocus when the demo type changes (no focus to nothing).
		  // [TH] ย่อ demo widget ทั้งหมด แล้วเปิดเฉพาะ widget ที่ตรงกับ demoType
		  //      รีเซ็ต mPreviewFocus เมื่อ demo type เปลี่ยน

		  // [EN] Reset focus if switching away from current interactive widget
		  // [TH] รีเซ็ต focus เมื่อออกจาก interactive widget ปัจจุบัน
		  If demoType <> mDemoType Then
		    mPreviewFocus = False
		    Call mDemoInput.SetFocused(False)
		  End If

		  mDemoType = demoType

		  // [EN] Collapse all demo widgets first
		  // [TH] ย่อ demo widget ทั้งหมดก่อน
		  Call mDemoInput.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoBar.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoSpinnerWidget.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoKeyText.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoTextWidget.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoTableWidget.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoTreeWidget.SetHeight(XjConstraint.Fixed(0))

		  // [EN] Reveal the relevant demo widget
		  // [TH] เปิด demo widget ที่เกี่ยวข้อง
		  Select Case demoType
		  Case "textinput"
		    Call mDemoInput.SetHeight(XjConstraint.Fixed(3))
		  Case "progressbar"
		    Call mDemoBar.SetHeight(XjConstraint.Fixed(2))
		  Case "spinner"
		    Call mDemoSpinnerWidget.SetHeight(XjConstraint.Fixed(2))
		  Case "keyevent"
		    Call mDemoKeyText.SetHeight(XjConstraint.Fixed(4))
		  Case "text"
		    // [EN] Batch 1: XjText alignment/wrap demo
		    // [TH] Batch 1: demo XjText จัดตำแหน่ง/ตัดคำ
		    Call mDemoTextWidget.SetHeight(XjConstraint.Fixed(4))
		  Case "table"
		    // [EN] Batch 1: XjTable border/header toggle demo
		    // [TH] Batch 1: demo XjTable สลับ border/header
		    Call mDemoTableWidget.SetHeight(XjConstraint.Fixed(8))
		  Case "tree"
		    // [EN] Batch 1: XjTree scroll navigation demo
		    // [TH] Batch 1: demo XjTree เลื่อนดู navigation
		    Call mDemoTreeWidget.SetHeight(XjConstraint.Fixed(6))
		    mDemoTreeScroll = 0
		    Call mDemoTreeWidget.SetScrollOffset(0)
		  Case "pie"
		    mPieDataset = 0
		    mOverlayLines = BuildPieDemo(mPieDataset)
		  Case "style"
		    mOverlayLines = BuildStyleDemo()
		  Case "color"
		    mOverlayLines = BuildColorDemo()
		  Case "canvas"
		    mOverlayLines = BuildCanvasDemo()
		  Case "confirm", "keypress", "expand", "ask", "enum"
		    // [EN] Batch 3: prompt overlay mockups — reset state and build initial overlay
		    // [TH] Batch 3: overlay mockup ของ prompt — รีเซ็ต state และสร้าง overlay เริ่มต้น
		    mPromptState = 0
		    mPromptInput = ""
		    mPromptAnswer = ""
		    mExpandExpanded = False
		    BuildPromptOverlayLines()
		  Case "select", "multiselect", "suggest", "collect"
		    // [EN] Batch 4: complex prompt overlay mockups — reset all state
		    // [TH] Batch 4: overlay mockup prompt ซับซ้อน — รีเซ็ต state ทั้งหมด
		    mPromptState = 0
		    mPromptInput = ""
		    mPromptAnswer = ""
		    mSelectIndex = 0
		    InitBatch4State()
		    BuildPromptOverlayLines()
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplySearch(query As String)
		  // [EN] Filter the component tree to entries matching query.
		  //      Empty query shows all components. Updates status bar with match count.
		  //      Always resets selection to the first visible item after filtering.
		  // [TH] กรอง component tree ให้แสดงเฉพาะรายการที่ตรงกับ query
		  //      query ว่างแสดงทั้งหมด อัปเดต status bar ด้วยจำนวนที่พบ
		  //      รีเซ็ต selection ไปยัง item แรกเสมอหลังกรอง
		  If query = "" Then
		    Var allEntries() As KSComponentEntry
		    For i As Integer = 0 To KSComponentRegistry.Count() - 1
		      allEntries.Add(KSComponentRegistry.EntryAt(i))
		    Next i
		    RebuildTree(allEntries)
		    If mFlatNodes.Count > 0 Then SelectLine(0)
		    Call mStatusDesc.SetText(" Type to filter   Esc cancel")
		    Return
		  End If

		  Var matches() As KSComponentEntry = KSComponentRegistry.Search(query)
		  RebuildTree(matches)

		  If mFlatNodes.Count > 0 Then
		    SelectLine(0)
		    Call mStatusDesc.SetText(" " + matches.Count.ToString + " of 31 match   Esc cancel")
		  Else
		    mSelectedLine = -1
		    Call mStatusDesc.SetText(" No matches   Esc cancel")
		    Call mPreviewTitle.SetText("")
		    Call mPreviewBody.SetText("")
		    mPropsTable.ClearRows()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildWidgetTree()
		  // [EN] Construct the 4-panel layout. Phase 3: mSearchInput embedded in searchBar.
		  //      Layout: root(column) → header / searchBar / mainArea / statusBar
		  //              mainArea(row) → componentList(25%) | previewArea(auto)
		  //              previewArea(column) → livePreview(auto) / propertiesPanel(30%)
		  // [TH] สร้างโครงสร้าง layout 4 ส่วน Phase 3: mSearchInput ฝังใน searchBar

		  // [EN] Theme styles — btop-inspired: cyan borders, dim key hints
		  // [TH] Theme styles — ดีไซน์แบบ btop: ขอบสี cyan, key hint สี dim
		  Var themeBase As New XjStyle
		  Var cyanBorder As XjStyle = themeBase.SetFG(XjANSI.FG_CYAN)
		  Var dimHint As XjStyle = themeBase.SetFG(XjANSI.FG_BRIGHT_BLACK)

		  mRoot = New XjBox
		  Call mRoot.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call mRoot.SetBorder(0, cyanBorder)
		  Call mRoot.SetTitle(" XjTTY-Toolkit Kitchen Sink ")

		  // [EN] Header: fixed 3 rows, no border — Phase 6 title/version bar placeholder
		  // [TH] Header: ความสูงคงที่ 3 แถว ไม่มีขอบ — พื้นที่สำรอง Phase 6 title/version bar
		  Var header As New XjBox
		  Call header.SetDirection(XjLayoutNode.DIR_ROW)
		  Call header.SetHeight(XjConstraint.Fixed(3))
		  mRoot.AddChild(header)

		  // [EN] Search bar: fixed 3 rows, single border, holds mSearchInput.
		  //      Inner height = 1 row (3 outer − 2 border). Title acts as "mode" label.
		  // [TH] Search bar: ความสูงคงที่ 3 แถว มีขอบ รองรับ mSearchInput
		  //      ความสูงภายใน = 1 แถว (3 รวมขอบ − 2 ขอบ) Title แสดงโหมด
		  Var searchBar As New XjBox
		  Call searchBar.SetDirection(XjLayoutNode.DIR_ROW)
		  Call searchBar.SetHeight(XjConstraint.Fixed(3))
		  Call searchBar.SetBorder(0, cyanBorder)
		  Call searchBar.SetTitle(" Search ")
		  mRoot.AddChild(searchBar)

		  // [EN] mSearchInput: fills the single inner row of searchBar.
		  //      Placeholder visible when not in search mode; cursor appears on activation.
		  // [TH] mSearchInput: เต็มพื้นที่ 1 แถวภายใน searchBar
		  //      placeholder มองเห็นเมื่อไม่อยู่ใน search mode; cursor ปรากฏเมื่อเปิดใช้งาน
		  mSearchInput = New XjTextInput
		  Call mSearchInput.SetPlaceholder("Press / to search components...")
		  searchBar.AddChild(mSearchInput)

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
		  Call componentList.SetBorder(0, cyanBorder)
		  Call componentList.SetTitle(" Components ")
		  mainArea.AddChild(componentList)

		  mListTree = New XjTree
		  componentList.AddChild(mListTree)

		  // [EN] Preview area: fills remaining width, owns livePreview + propertiesPanel
		  // [TH] Preview area: ขยายเต็มความกว้างที่เหลือ เป็นเจ้าของ livePreview + propertiesPanel
		  Var previewArea As New XjBox
		  Call previewArea.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call previewArea.SetBorder(0, cyanBorder)
		  Call previewArea.SetTitle(" Preview ")
		  mainArea.AddChild(previewArea)

		  Var livePreview As New XjBox
		  Call livePreview.SetDirection(XjLayoutNode.DIR_COLUMN)
		  previewArea.AddChild(livePreview)

		  // [EN] mPreviewTitle: 1-row header showing "Name  [Category]" in cyan bold
		  // [TH] mPreviewTitle: header 1 แถว แสดง "ชื่อ  [Category]" สี cyan ตัวหนา
		  mPreviewTitle = New XjText
		  Call mPreviewTitle.SetHeight(XjConstraint.Fixed(1))
		  Call mPreviewTitle.SetText("<- select a component")
		  Call mPreviewTitle.SetAlign(XjText.ALIGN_CENTER)
		  Var titleBase As New XjStyle
		  Var titleWithCyan As XjStyle = titleBase.SetFG(XjANSI.FG_CYAN)
		  Var titleStyle As XjStyle = titleWithCyan.SetBold()
		  Call mPreviewTitle.SetStyle(titleStyle)
		  livePreview.AddChild(mPreviewTitle)

		  // [EN] mPreviewBody: fills remaining height, word-wrapped long description
		  // [TH] mPreviewBody: ขยายเต็มความสูงที่เหลือ คำอธิบายยาวตัดคำ
		  mPreviewBody = New XjText
		  Call mPreviewBody.SetWrap(True)
		  Call mPreviewBody.SetAlign(XjText.ALIGN_LEFT)
		  livePreview.AddChild(mPreviewBody)

		  // [EN] Phase 5 demo widgets — all start collapsed (Fixed(0) height).
		  //      ActivateDemoWidget() reveals one at a time by swapping height constraints.
		  // [TH] Phase 5 demo widget ทั้งหมด — เริ่มต้นย่อ (Fixed(0))
		  //      ActivateDemoWidget() เปิดทีละ widget โดยสลับ height constraint

		  // [EN] mDemoInput: live XjTextInput demo — user types freely
		  // [TH] mDemoInput: demo XjTextInput สด — ผู้ใช้พิมพ์ได้เลย
		  mDemoInput = New XjTextInput
		  Call mDemoInput.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoInput.SetPlaceholder("Type here to demo XjTextInput...")
		  livePreview.AddChild(mDemoInput)

		  // [EN] mDemoBar: live XjProgressBar demo — + increments, - decrements, Space resets
		  // [TH] mDemoBar: demo XjProgressBar สด — + เพิ่ม, - ลด, Space รีเซ็ต
		  mDemoBar = New XjProgressBar
		  Call mDemoBar.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoBar.SetTotal(100)
		  Var barFmtBase As New XjStyle
		  Var barFmtGreen As XjStyle = barFmtBase.SetFG(XjANSI.FG_GREEN)
		  Call mDemoBar.SetFilledStyle(barFmtGreen)
		  livePreview.AddChild(mDemoBar)

		  // [EN] mDemoSpinnerWidget: auto-animates via HandleTick; message shows key hint
		  // [TH] mDemoSpinnerWidget: auto-animate ผ่าน HandleTick; message แสดง key hint
		  mDemoSpinnerWidget = New XjSpinner
		  Call mDemoSpinnerWidget.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoSpinnerWidget.SetFormat("dots")
		  Call mDemoSpinnerWidget.SetMessage("Spinner demo — animates automatically")
		  livePreview.AddChild(mDemoSpinnerWidget)

		  // [EN] mDemoKeyText: shows the last key event (code, char, modifiers)
		  // [TH] mDemoKeyText: แสดง key event ล่าสุด (code, char, modifier)
		  mDemoKeyText = New XjText
		  Call mDemoKeyText.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoKeyText.SetText("Press any key...")
		  livePreview.AddChild(mDemoKeyText)

		  // --- Batch 1 demo widgets ---

		  // [EN] mDemoTextWidget: XjText alignment/wrap demo — l/c/r change alignment, w toggles wrap
		  // [TH] mDemoTextWidget: demo XjText จัดตำแหน่ง/ตัดคำ — l/c/r เปลี่ยน alignment, w สลับ wrap
		  mDemoTextWidget = New XjText
		  Call mDemoTextWidget.SetHeight(XjConstraint.Fixed(0))
		  Call mDemoTextWidget.SetWrap(True)
		  Call mDemoTextWidget.SetText("The quick brown fox jumps over the lazy dog. This sample text demonstrates XjText alignment and word-wrap capabilities.")
		  livePreview.AddChild(mDemoTextWidget)

		  // [EN] mDemoTableWidget: XjTable demo — b toggles border, h toggles header
		  // [TH] mDemoTableWidget: demo XjTable — b สลับ border, h สลับ header
		  mDemoTableWidget = New XjTable
		  Call mDemoTableWidget.SetHeight(XjConstraint.Fixed(0))
		  Var tblHeaders() As String
		  tblHeaders.Add("Component")
		  tblHeaders.Add("Type")
		  tblHeaders.Add("Status")
		  Call mDemoTableWidget.SetHeaders(tblHeaders)
		  Call mDemoTableWidget.SetColumnWidth(0, 16)
		  Call mDemoTableWidget.SetColumnWidth(1, 10)
		  Call mDemoTableWidget.SetColumnWidth(2, 10)
		  Var tr1() As String
		  tr1.Add("XjTextInput")
		  tr1.Add("Widget")
		  tr1.Add("Active")
		  mDemoTableWidget.AddRow(tr1)
		  Var tr2() As String
		  tr2.Add("XjProgressBar")
		  tr2.Add("Widget")
		  tr2.Add("Active")
		  mDemoTableWidget.AddRow(tr2)
		  Var tr3() As String
		  tr3.Add("XjSpinner")
		  tr3.Add("Widget")
		  tr3.Add("Active")
		  mDemoTableWidget.AddRow(tr3)
		  Var tr4() As String
		  tr4.Add("XjConfirmPrompt")
		  tr4.Add("Prompt")
		  tr4.Add("Planned")
		  mDemoTableWidget.AddRow(tr4)
		  Var tr5() As String
		  tr5.Add("XjSelectPrompt")
		  tr5.Add("Prompt")
		  tr5.Add("Planned")
		  mDemoTableWidget.AddRow(tr5)
		  livePreview.AddChild(mDemoTableWidget)

		  // [EN] mDemoTreeWidget: XjTree demo — Up/Down scroll a sample project hierarchy
		  // [TH] mDemoTreeWidget: demo XjTree — Up/Down เลื่อนดู hierarchy โปรเจกต์ตัวอย่าง
		  mDemoTreeWidget = New XjTree
		  Call mDemoTreeWidget.SetHeight(XjConstraint.Fixed(0))
		  Var projNode As New XjTreeNode("MyProject")
		  Var srcNode As New XjTreeNode("src")
		  Call srcNode.AddChild(New XjTreeNode("App.xojo_code"))
		  Call srcNode.AddChild(New XjTreeNode("MainWindow.xojo_window"))
		  Call srcNode.AddChild(New XjTreeNode("Utils.xojo_code"))
		  Call projNode.AddChild(srcNode)
		  Var testNode As New XjTreeNode("tests")
		  Call testNode.AddChild(New XjTreeNode("TestRunner.xojo_code"))
		  Call testNode.AddChild(New XjTreeNode("TestUtils.xojo_code"))
		  Call projNode.AddChild(testNode)
		  Var docsNode As New XjTreeNode("docs")
		  Call docsNode.AddChild(New XjTreeNode("README.md"))
		  Call docsNode.AddChild(New XjTreeNode("CHANGELOG.md"))
		  Call projNode.AddChild(docsNode)
		  Var treeRoots() As XjTreeNode
		  treeRoots.Add(projNode)
		  Call mDemoTreeWidget.SetData(treeRoots)
		  mDemoTreeScroll = 0
		  mDemoTextWrap = True
		  mDemoTableBorder = True
		  mDemoTableHeader = True
		  livePreview.AddChild(mDemoTreeWidget)

		  // [EN] Properties panel: 30% of preview height, min 5 rows
		  // [TH] Properties panel: 30% ของความสูง preview, ขั้นต่ำ 5 แถว
		  Var propertiesPanel As New XjBox
		  Call propertiesPanel.SetHeight(XjConstraint.Percent(30).SetMin(5))
		  Call propertiesPanel.SetBorder(0, cyanBorder)
		  Call propertiesPanel.SetTitle(" Properties ")
		  previewArea.AddChild(propertiesPanel)

		  // [EN] mPropsTable: 2-column property sheet; column 0 fixed at 12 chars
		  // [TH] mPropsTable: ตาราง property 2 คอลัมน์; คอลัมน์ 0 กว้างคงที่ 12 ตัวอักษร
		  mPropsTable = New XjTable
		  Var propHeaders() As String
		  propHeaders.Add("Property")
		  propHeaders.Add("Value")
		  Call mPropsTable.SetHeaders(propHeaders)
		  Call mPropsTable.SetColumnWidth(0, 12)
		  propertiesPanel.AddChild(mPropsTable)

		  // [EN] Status bar: 1 row, DIR_ROW — description (auto) + key hint (fixed 30)
		  // [TH] Status bar: 1 แถว DIR_ROW — คำอธิบาย (auto) + key hint (fixed 30)
		  Var statusBar As New XjBox
		  Call statusBar.SetDirection(XjLayoutNode.DIR_ROW)
		  Call statusBar.SetHeight(XjConstraint.Fixed(1))
		  mRoot.AddChild(statusBar)

		  mStatusDesc = New XjText
		  Call mStatusDesc.SetText(" Welcome -- use arrow keys or press / to search")
		  Call mStatusDesc.SetWidth(XjConstraint.Auto())
		  statusBar.AddChild(mStatusDesc)

		  Var keysHint As New XjText
		  Call keysHint.SetText("/ Search  Up/Dn  ?Help  q Quit")
		  Call keysHint.SetWidth(XjConstraint.Fixed(32))
		  Call keysHint.SetAlign(XjText.ALIGN_RIGHT)
		  Call keysHint.SetStyle(dimHint)
		  statusBar.AddChild(keysHint)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnterSearchMode()
		  // [EN] Activate search mode: clear the input, focus it, update status bar hint.
		  // [TH] เปิด search mode: ล้าง input, โฟกัสไปที่ input, อัปเดต status bar hint
		  mSearchMode = True
		  Call mSearchInput.SetValue("")
		  Call mSearchInput.SetFocused(True)
		  Call mStatusDesc.SetText(" Type to filter   Esc cancel")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ExitSearchMode()
		  // [EN] Deactivate search mode: unfocus input, restore full tree, then re-select
		  //      the previously selected entry so the cursor does not jump to line 0.
		  //      If the selected line was a category header (Nil entry), line 0 is used.
		  // [TH] ปิด search mode: ยกเลิกโฟกัส input, คืน tree เต็ม แล้ว re-select
		  //      entry ที่เคยเลือกไว้ ป้องกันไม่ให้กระโดดไปบรรทัดแรก
		  //      ถ้า line ที่เลือกเป็น category header (Nil) ให้ใช้บรรทัดแรกแทน

		  // [EN] Save the selected component entry before the tree is rebuilt
		  // [TH] บันทึก entry ที่เลือกก่อนที่ tree จะถูกสร้างใหม่
		  Var savedEntry As KSComponentEntry
		  If mSelectedLine >= 0 And mSelectedLine < mFlatEntries.Count Then
		    savedEntry = mFlatEntries(mSelectedLine)
		  End If

		  mSearchMode = False
		  Call mSearchInput.SetFocused(False)
		  Call mSearchInput.SetValue("")
		  PopulateTree()

		  // [EN] Re-select the saved entry in the restored full list
		  // [TH] Re-select entry ที่บันทึกไว้ในรายการ tree เต็มที่กู้คืนแล้ว
		  If Not (savedEntry Is Nil) Then
		    For i As Integer = 0 To mFlatEntries.Count - 1
		      If Not (mFlatEntries(i) Is Nil) Then
		        If mFlatEntries(i).Name = savedEntry.Name Then
		          SelectLine(i)
		          Return
		        End If
		      End If
		    Next i
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  // [EN] Three-mode key router (Phase 5).
		  //      Ctrl+C always quits from any mode.
		  //      Search mode: Esc exits; Up/Down/Enter navigate filtered list.
		  //      Preview focus mode: routes keys to active demo widget; Esc returns to list.
		  //      List mode (default): '/' search; Tab enters preview (interactive only);
		  //                           'q' quits; arrows navigate tree.
		  // [TH] key router สามโหมด (Phase 5)
		  //      Ctrl+C ออกเสมอไม่ว่าจะอยู่โหมดไหน
		  //      Search mode: Esc ออก; Up/Down/Enter navigate list ที่กรองแล้ว
		  //      Preview focus mode: ส่ง key ไปยัง demo widget; Esc กลับ list
		  //      List mode (เริ่มต้น): '/' search; Tab เข้า preview; 'q' ออก; arrow navigate

		  // [EN] Ctrl+C always quits
		  // [TH] Ctrl+C ออกเสมอ
		  If key.Char = Chr(3) Then
		    mLoop.Stop_()
		    Return
		  End If

		  // [EN] Help overlay: any key press dismisses it
		  // [TH] Help overlay: กด key ใดๆ เพื่อปิด
		  If mShowHelp Then
		    mShowHelp = False
		    Return
		  End If

		  // [EN] Preview focus zone: route keys to the active demo widget
		  // [TH] Preview focus zone: ส่ง key ไปยัง demo widget ที่ active
		  If mPreviewFocus Then
		    // [EN] Esc: exit preview focus, return to list navigation
		    // [TH] Esc: ออก preview focus กลับสู่ list navigation
		    If key.KeyCode = XjKeyEvent.KEY_ESCAPE Then
		      mPreviewFocus = False
		      Call mDemoInput.SetFocused(False)
		      Call mStatusDesc.SetText(" Tab to enter preview   / search   q quit")
		      Return
		    End If

		    // [EN] Route key to the active demo widget
		    // [TH] ส่ง key ไปยัง demo widget ที่ active
		    Select Case mDemoType
		    Case "textinput"
		      Call mDemoInput.HandleKey(key)
		    Case "progressbar"
		      // [EN] + / = increment; - decrement; Space reset; r reset
		      // [TH] + / = เพิ่ม; - ลด; Space/r รีเซ็ต
		      If key.Char = "+" Or key.Char = "=" Then
		        Call mDemoBar.Advance(10)
		      ElseIf key.Char = "-" Then
		        Call mDemoBar.SetValue(mDemoBar.Value - 10)
		      ElseIf key.Char = " " Or key.Char = "r" Then
		        Call mDemoBar.Reset()
		      End If
		    Case "keyevent"
		      // [EN] Display the received key's properties in mDemoKeyText
		      // [TH] แสดง property ของ key ที่กดใน mDemoKeyText
		      Var kDesc As String = "KeyCode : " + key.KeyCode.ToString
		      kDesc = kDesc + Chr(10) + "Char    : "
		      If key.Char <> "" Then
		        kDesc = kDesc + "'" + key.Char + "'"
		      Else
		        kDesc = kDesc + "(none)"
		      End If
		      If key.IsCtrl Then kDesc = kDesc + Chr(10) + "Modifier: Ctrl"
		      Call mDemoKeyText.SetText(kDesc)

		    Case "text"
		      // [EN] Batch 1: XjText demo — l/c/r change alignment, w toggles wrap
		      // [TH] Batch 1: demo XjText — l/c/r เปลี่ยน alignment, w สลับ wrap
		      If key.Char = "l" Then
		        Call mDemoTextWidget.SetAlign(XjText.ALIGN_LEFT)
		        Call mStatusDesc.SetText(" Align: LEFT   l/c/r align  w wrap  Esc back")
		      ElseIf key.Char = "c" Then
		        Call mDemoTextWidget.SetAlign(XjText.ALIGN_CENTER)
		        Call mStatusDesc.SetText(" Align: CENTER   l/c/r align  w wrap  Esc back")
		      ElseIf key.Char = "r" Then
		        Call mDemoTextWidget.SetAlign(XjText.ALIGN_RIGHT)
		        Call mStatusDesc.SetText(" Align: RIGHT   l/c/r align  w wrap  Esc back")
		      ElseIf key.Char = "w" Then
		        mDemoTextWrap = Not mDemoTextWrap
		        Call mDemoTextWidget.SetWrap(mDemoTextWrap)
		        If mDemoTextWrap Then
		          Call mStatusDesc.SetText(" Wrap: ON   l/c/r align  w wrap  Esc back")
		        Else
		          Call mStatusDesc.SetText(" Wrap: OFF   l/c/r align  w wrap  Esc back")
		        End If
		      End If

		    Case "table"
		      // [EN] Batch 1: XjTable demo — b toggles border, h toggles header
		      // [TH] Batch 1: demo XjTable — b สลับ border, h สลับ header
		      If key.Char = "b" Then
		        mDemoTableBorder = Not mDemoTableBorder
		        Call mDemoTableWidget.SetShowBorder(mDemoTableBorder)
		        If mDemoTableBorder Then
		          Call mStatusDesc.SetText(" Border: ON   b border  h header  Esc back")
		        Else
		          Call mStatusDesc.SetText(" Border: OFF   b border  h header  Esc back")
		        End If
		      ElseIf key.Char = "h" Then
		        mDemoTableHeader = Not mDemoTableHeader
		        Call mDemoTableWidget.SetShowHeader(mDemoTableHeader)
		        If mDemoTableHeader Then
		          Call mStatusDesc.SetText(" Header: ON   b border  h header  Esc back")
		        Else
		          Call mStatusDesc.SetText(" Header: OFF   b border  h header  Esc back")
		        End If
		      End If

		    Case "tree"
		      // [EN] Batch 1: XjTree demo — Up/Down scroll through sample hierarchy
		      // [TH] Batch 1: demo XjTree — Up/Down เลื่อนดู hierarchy ตัวอย่าง
		      If key.KeyCode = XjKeyEvent.KEY_UP Then
		        If mDemoTreeScroll > 0 Then
		          mDemoTreeScroll = mDemoTreeScroll - 1
		          Call mDemoTreeWidget.SetScrollOffset(mDemoTreeScroll)
		        End If
		      ElseIf key.KeyCode = XjKeyEvent.KEY_DOWN Then
		        Var maxScroll As Integer = mDemoTreeWidget.LineCount() - 4
		        If maxScroll < 0 Then maxScroll = 0
		        If mDemoTreeScroll < maxScroll Then
		          mDemoTreeScroll = mDemoTreeScroll + 1
		          Call mDemoTreeWidget.SetScrollOffset(mDemoTreeScroll)
		        End If
		      End If

		    Case "pie"
		      HandlePieDemoKey(key)
		    Case "confirm"
		      HandleConfirmDemoKey(key)
		    Case "keypress"
		      HandleKeyPressDemoKey(key)
		    Case "expand"
		      HandleExpandDemoKey(key)
		    Case "ask"
		      HandleAskDemoKey(key)
		    Case "enum"
		      HandleEnumDemoKey(key)
		    Case "select"
		      HandleSelectDemoKey(key)
		    Case "multiselect"
		      HandleMultiSelectDemoKey(key)
		    Case "suggest"
		      HandleSuggestDemoKey(key)
		    Case "collect"
		      HandleCollectDemoKey(key)

		    End Select
		    Return
		  End If

		  If mSearchMode Then
		    // [EN] Esc: exit search, restore full list
		    // [TH] Esc: ออก search, คืน list เต็ม
		    If key.KeyCode = XjKeyEvent.KEY_ESCAPE Then
		      ExitSearchMode()
		      Return
		    End If

		    // [EN] Up / Down / Enter: navigate the filtered list while staying in search mode
		    // [TH] Up / Down / Enter: navigate list ที่กรองแล้วขณะยังอยู่ใน search mode
		    If key.KeyCode = XjKeyEvent.KEY_UP Or _
		       key.KeyCode = XjKeyEvent.KEY_DOWN Or _
		       key.KeyCode = XjKeyEvent.KEY_ENTER Then
		      HandleListKey(key)
		      Return
		    End If

		    // [EN] Tab: exit search first, then fall through to list-mode Tab handling below
		    // [TH] Tab: ออก search ก่อน แล้วต่อไปยัง Tab handling ของ list mode ด้านล่าง
		    If key.KeyCode = XjKeyEvent.KEY_TAB Then
		      ExitSearchMode()
		      // fall through — no Return
		    Else
		      // [EN] All other keys: feed to text input, then re-filter
		      // [TH] key อื่นๆ ทั้งหมด: ส่งไป text input แล้วกรองใหม่
		      If mSearchInput.HandleKey(key) Then
		        ApplySearch(mSearchInput.Value)
		      End If
		      Return
		    End If
		  End If

		  // [EN] List mode
		  // [TH] List mode
		  If key.Char = "q" Then
		    mLoop.Stop_()
		    Return
		  End If

		  If key.Char = "/" Then
		    EnterSearchMode()
		    Return
		  End If

		  // [EN] Tab: enter preview focus (only when a live demo widget is active)
		  // [TH] Tab: เข้า preview focus (เฉพาะเมื่อ live demo widget ทำงานอยู่)
		  If key.KeyCode = XjKeyEvent.KEY_TAB Then
		    If mDemoType <> "" And mDemoType <> "mockup" Then
		      mPreviewFocus = True
		      If mDemoType = "textinput" Then
		        Call mDemoInput.SetFocused(True)
		      End If
		      Call mStatusDesc.SetText(" Esc back to list   " + DemoKeyHint(mDemoType))
		    End If
		    Return
		  End If

		  // [EN] ? key: show help overlay
		  // [TH] ? key: แสดง help overlay
		  If key.Char = "?" Then
		    mShowHelp = True
		    Return
		  End If

		  // [EN] 1–6: jump to the Nth category header in the component list
		  // [TH] 1–6: กระโดดไปยัง category header ที่ N ใน component list
		  If key.Char >= "1" And key.Char <= "6" Then
		    Var catIdx As Integer = Val(key.Char) - 1
		    Var catCount As Integer = -1
		    For i As Integer = 0 To mFlatNodes.Count - 1
		      If mFlatEntries(i) Is Nil Then
		        catCount = catCount + 1
		        If catCount = catIdx Then
		          SelectLine(i)
		          Return
		        End If
		      End If
		    Next i
		    Return
		  End If

		  HandleListKey(key)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleListKey(key As XjKeyEvent)
		  // [EN] Arrow-key navigation within the visible (possibly filtered) component list.
		  // [TH] navigation ด้วย arrow key ภายใน component list ที่มองเห็น (อาจกรองแล้ว)
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
		    // [EN] Enter: re-select current line to refresh preview (navigation already handles it via SelectLine)
		    // [TH] Enter: เลือก line ปัจจุบันอีกครั้งเพื่อรีเฟรช preview
		    If mSelectedLine >= 0 And mSelectedLine < mFlatEntries.Count Then
		      Var entry As KSComponentEntry = mFlatEntries(mSelectedLine)
		      If Not (entry Is Nil) Then
		        Call mStatusDesc.SetText(" [selected] " + entry.Name + " — " + entry.ShortDesc)
		      End If
		    End If

		  Case XjKeyEvent.KEY_PAGEUP
		    // [EN] Page Up: scroll up one visible page
		    // [TH] Page Up: เลื่อนขึ้นหนึ่งหน้า
		    Var visH As Integer = mTermHeight - 11
		    If visH < 1 Then visH = 1
		    Var pgUpLine As Integer = mSelectedLine - visH
		    If pgUpLine < 0 Then pgUpLine = 0
		    SelectLine(pgUpLine)

		  Case XjKeyEvent.KEY_PAGEDOWN
		    // [EN] Page Down: scroll down one visible page
		    // [TH] Page Down: เลื่อนลงหนึ่งหน้า
		    Var visH2 As Integer = mTermHeight - 11
		    If visH2 < 1 Then visH2 = 1
		    Var pgDnLine As Integer = mSelectedLine + visH2
		    If pgDnLine >= mFlatNodes.Count Then pgDnLine = mFlatNodes.Count - 1
		    SelectLine(pgDnLine)

		  Case XjKeyEvent.KEY_HOME
		    // [EN] Home: jump to first item
		    // [TH] Home: กระโดดไปรายการแรก
		    If mFlatNodes.Count > 0 Then SelectLine(0)

		  Case XjKeyEvent.KEY_END_
		    // [EN] End: jump to last item
		    // [TH] End: กระโดดไปรายการสุดท้าย
		    If mFlatNodes.Count > 0 Then SelectLine(mFlatNodes.Count - 1)

		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleResize(w As Integer, h As Integer)
		  // [EN] Update stored dimensions and resize the canvas buffer.
		  // [TH] อัปเดตขนาดที่เก็บไว้และปรับขนาด canvas buffer
		  mTermWidth = w
		  mTermHeight = h
		  mCanvas.Resize(w, h)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DemoKeyHint(demoType As String) As String
		  // [EN] Return a short status-bar key hint for the active demo type.
		  // [TH] คืน key hint สั้นๆ ใน status bar สำหรับ demo type ที่ active
		  Select Case demoType
		  Case "textinput"
		    Return "Type freely"
		  Case "progressbar"
		    Return "+ inc   - dec   r reset"
		  Case "spinner"
		    Return "Animates automatically"
		  Case "keyevent"
		    Return "Press any key to inspect"
		  Case "text"
		    Return "l/c/r align   w wrap"
		  Case "table"
		    Return "b border   h header"
		  Case "tree"
		    Return "Up/Dn scroll tree"
		  Case "pie"
		    Return "1/2/3 switch dataset"
		  Case "style"
		    Return "Style showcase"
		  Case "color"
		    Return "Color palette"
		  Case "canvas"
		    Return "Canvas concept"
		  Case "confirm"
		    Return "Y/N to answer"
		  Case "keypress"
		    Return "Press any key"
		  Case "expand"
		    Return "y/n select   h expand"
		  Case "ask"
		    Return "Type text   Enter submit"
		  Case "enum"
		    Return "1-3 select   Enter confirm"
		  Case "select"
		    Return "Up/Dn navigate   Enter select"
		  Case "multiselect"
		    Return "Up/Dn   Space toggle   Enter"
		  Case "suggest"
		    Return "Type   Tab accept   Enter"
		  Case "collect"
		    Return "Multi-step wizard"
		  Case Else
		    Return ""
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleTick(tickCount As Integer)
		  // [EN] Called ~30fps. Drives render cycle and advances animated demo widgets.
		  //      When the help overlay is active, calls RenderHelp() instead of Render().
		  // [TH] ถูกเรียก ~30fps ขับเคลื่อน render cycle และ advance demo widget ที่ animate
		  //      เมื่อ help overlay เปิดอยู่ เรียก RenderHelp() แทน Render()
		  If mShowHelp Then
		    RenderHelp()
		    Return
		  End If
		  Select Case mDemoType
		  Case "spinner"
		    mDemoSpinnerWidget.HandleTick(tickCount)
		  Case "progressbar"
		    mDemoBar.HandleTick(tickCount)
		  End Select
		  Render()
		  RenderOverlayIfNeeded()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RenderOverlayIfNeeded()
		  // [EN] Check if an overlay demo should be rendered on top of the normal UI.
		  // [TH] ตรวจสอบว่าควร render overlay demo ทับ UI ปกติหรือไม่
		  If mPreviewFocus Then
		    Select Case mDemoType
		    Case "pie", "style", "color", "canvas", "confirm", "keypress", "expand", "ask", "enum", "select", "multiselect", "suggest", "collect"
		      RenderDemoOverlay()
		    End Select
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandlePieDemoKey(key As XjKeyEvent)
		  // [EN] Batch 2: XjPie demo — 1/2/3 switch datasets
		  // [TH] Batch 2: demo XjPie — 1/2/3 สลับ dataset
		  If key.Char = "1" Then
		    mPieDataset = 0
		    mOverlayLines = BuildPieDemo(mPieDataset)
		    Call mStatusDesc.SetText(" Dataset: Languages   1/2/3 switch  Esc back")
		  ElseIf key.Char = "2" Then
		    mPieDataset = 1
		    mOverlayLines = BuildPieDemo(mPieDataset)
		    Call mStatusDesc.SetText(" Dataset: Platforms   1/2/3 switch  Esc back")
		  ElseIf key.Char = "3" Then
		    mPieDataset = 2
		    mOverlayLines = BuildPieDemo(mPieDataset)
		    Call mStatusDesc.SetText(" Dataset: Components  1/2/3 switch  Esc back")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildPromptOverlayLines()
		  // [EN] Batch 3: dispatch to the correct prompt overlay builder based on mDemoType.
		  //      Separated from ActivateDemoWidget to keep method bodies small (Tahoe workaround).
		  // [TH] Batch 3: ส่งต่อไปยัง builder overlay prompt ที่ถูกต้องตาม mDemoType
		  //      แยกจาก ActivateDemoWidget เพื่อให้ method body เล็ก (workaround Tahoe)
		  Select Case mDemoType
		  Case "confirm"
		    mOverlayLines = BuildConfirmOverlay()
		  Case "keypress"
		    mOverlayLines = BuildKeyPressOverlay()
		  Case "expand"
		    mOverlayLines = BuildExpandOverlay()
		  Case "ask"
		    mOverlayLines = BuildAskOverlay()
		  Case "enum"
		    mOverlayLines = BuildEnumOverlay()
		  Case "select"
		    mOverlayLines = BuildSelectOverlay()
		  Case "multiselect"
		    mOverlayLines = BuildMultiSelectOverlay()
		  Case "suggest"
		    UpdateSuggestFilter()
		    mOverlayLines = BuildSuggestOverlay()
		  Case "collect"
		    mOverlayLines = BuildCollectOverlay()
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildConfirmOverlay() As String()
		  // [EN] Batch 3: build overlay lines for XjConfirmPrompt mockup.
		  //      State 0: active — shows "? Are you sure? (Y/n) _"
		  //      State 1: settled — shows "✓ Are you sure? Yes/No"
		  // [TH] Batch 3: สร้าง overlay lines สำหรับ mockup XjConfirmPrompt
		  //      State 0: active — แสดง "? Are you sure? (Y/n) _"
		  //      State 1: settled — แสดง "✓ Are you sure? Yes/No"
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjConfirmPrompt Demo"))
		  lines.Add("")

		  Var prefixGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var prefixBold As XjStyle = prefixGreen.SetBold
		  Var qStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE)
		  Var qBold As XjStyle = qStyle.SetBold
		  Var ansStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var helpDim As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var cursorInv As XjStyle = base.SetInverse

		  If mPromptState = 0 Then
		    Var line As String = "  " + prefixBold.Apply("?") + " "
		    line = line + qBold.Apply("Are you sure?") + " "
		    line = line + helpDim.Apply("(Y/n)") + " "
		    line = line + cursorInv.Apply(" ")
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press Y or N to answer"))
		  Else
		    Var checkMark As String = Chr(&h2714)
		    Var line As String = "  " + prefixBold.Apply(checkMark) + " "
		    line = line + qBold.Apply("Are you sure?") + " "
		    line = line + ansStyle.Apply(mPromptAnswer)
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press any key to reset"))
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildKeyPressOverlay() As String()
		  // [EN] Batch 3: build overlay lines for XjKeyPressPrompt mockup.
		  //      State 0: active — shows "? Press any key: _"
		  //      State 1: settled — shows "✓ Press any key: <keyname>"
		  // [TH] Batch 3: สร้าง overlay lines สำหรับ mockup XjKeyPressPrompt
		  //      State 0: active — แสดง "? Press any key: _"
		  //      State 1: settled — แสดง "✓ Press any key: <keyname>"
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjKeyPressPrompt Demo"))
		  lines.Add("")

		  Var prefixGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var prefixBold As XjStyle = prefixGreen.SetBold
		  Var qStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE)
		  Var qBold As XjStyle = qStyle.SetBold
		  Var ansStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var helpDim As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var cursorInv As XjStyle = base.SetInverse

		  If mPromptState = 0 Then
		    Var line As String = "  " + prefixBold.Apply("?") + " "
		    line = line + qBold.Apply("Press any key:") + " "
		    line = line + cursorInv.Apply(" ")
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press any key to capture it"))
		  Else
		    Var checkMark As String = Chr(&h2714)
		    Var line As String = "  " + prefixBold.Apply(checkMark) + " "
		    line = line + qBold.Apply("Press any key:") + " "
		    line = line + ansStyle.Apply(mPromptAnswer)
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press any key to try again"))
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildExpandOverlay() As String()
		  // [EN] Batch 3: build overlay lines for XjExpandPrompt mockup.
		  //      State 0 collapsed: compact key list with h for help
		  //      State 0 expanded: full choice list with key + description
		  //      State 1: settled answer
		  // [TH] Batch 3: สร้าง overlay lines สำหรับ mockup XjExpandPrompt
		  //      State 0 ย่อ: key list สั้นพร้อม h สำหรับ help
		  //      State 0 ขยาย: choice list เต็มพร้อม key + คำอธิบาย
		  //      State 1: คำตอบ settled
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjExpandPrompt Demo"))
		  lines.Add("")

		  Var prefixGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var prefixBold As XjStyle = prefixGreen.SetBold
		  Var qStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE)
		  Var qBold As XjStyle = qStyle.SetBold
		  Var ansStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var helpDim As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var activeClr As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var cursorInv As XjStyle = base.SetInverse

		  If mPromptState = 1 Then
		    // [EN] Settled — show final answer
		    // [TH] Settled — แสดงคำตอบสุดท้าย
		    Var line As String = "  " + prefixBold.Apply("?") + " "
		    line = line + qBold.Apply("Overwrite?") + " "
		    line = line + ansStyle.Apply(mPromptAnswer)
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press any key to reset"))
		  ElseIf mExpandExpanded Then
		    // [EN] Expanded — full option list
		    // [TH] ขยาย — option list เต็ม
		    Var qLine As String = "  " + prefixBold.Apply("?") + " "
		    qLine = qLine + qBold.Apply("Overwrite?")
		    lines.Add(qLine)
		    lines.Add("    " + activeClr.Apply("y") + ") Yes")
		    lines.Add("    " + activeClr.Apply("n") + ") No")
		    lines.Add("    " + activeClr.Apply("h") + ") Help")
		    lines.Add("  Choice: " + cursorInv.Apply(" "))
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press y or n to select"))
		  Else
		    // [EN] Collapsed — compact key hint
		    // [TH] ย่อ — key hint แบบสั้น
		    Var line As String = "  " + prefixBold.Apply("?") + " "
		    line = line + qBold.Apply("Overwrite?") + " "
		    line = line + helpDim.Apply("(enter h for help)") + " "
		    line = line + helpDim.Apply("[y/n/h]")
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press y, n, or h to expand"))
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildAskOverlay() As String()
		  // [EN] Batch 3: build overlay lines for XjAskPrompt mockup.
		  //      State 0: active — text input with cursor and default hint
		  //      State 1: settled — shows final answer
		  // [TH] Batch 3: สร้าง overlay lines สำหรับ mockup XjAskPrompt
		  //      State 0: active — input ข้อความพร้อม cursor และ default hint
		  //      State 1: settled — แสดงคำตอบสุดท้าย
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjAskPrompt Demo"))
		  lines.Add("")

		  Var prefixGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var prefixBold As XjStyle = prefixGreen.SetBold
		  Var qStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE)
		  Var qBold As XjStyle = qStyle.SetBold
		  Var ansStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var helpDim As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var cursorInv As XjStyle = base.SetInverse

		  If mPromptState = 0 Then
		    Var line As String = "  " + prefixBold.Apply("?") + " "
		    line = line + qBold.Apply("What is your name?")
		    If mPromptInput = "" Then
		      line = line + " " + helpDim.Apply("(John)") + " " + cursorInv.Apply(" ")
		    Else
		      line = line + " " + mPromptInput + cursorInv.Apply(" ")
		    End If
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Type text, Enter to submit, Backspace to delete"))
		  Else
		    Var checkMark As String = Chr(&h2714)
		    Var line As String = "  " + prefixBold.Apply(checkMark) + " "
		    line = line + qBold.Apply("What is your name?") + " "
		    line = line + ansStyle.Apply(mPromptAnswer)
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press any key to reset"))
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildEnumOverlay() As String()
		  // [EN] Batch 3: build overlay lines for XjEnumSelectPrompt mockup.
		  //      State 0: active — numbered list with input line
		  //      State 1: settled — shows selected choice
		  // [TH] Batch 3: สร้าง overlay lines สำหรับ mockup XjEnumSelectPrompt
		  //      State 0: active — รายการลำดับเลขพร้อม input line
		  //      State 1: settled — แสดง choice ที่เลือก
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjEnumSelectPrompt Demo"))
		  lines.Add("")

		  Var prefixGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var prefixBold As XjStyle = prefixGreen.SetBold
		  Var qStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE)
		  Var qBold As XjStyle = qStyle.SetBold
		  Var ansStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var helpDim As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var activeClr As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var cursorInv As XjStyle = base.SetInverse

		  If mPromptState = 0 Then
		    Var qLine As String = "  " + prefixBold.Apply("?") + " "
		    qLine = qLine + qBold.Apply("What action?")
		    lines.Add(qLine)
		    lines.Add("    " + activeClr.Apply("1") + ") Save")
		    lines.Add("    " + activeClr.Apply("2") + ") Load")
		    lines.Add("    " + activeClr.Apply("3") + ") Quit")
		    Var inputLine As String = "  Enter number: "
		    If mPromptInput <> "" Then
		      inputLine = inputLine + mPromptInput
		    End If
		    inputLine = inputLine + cursorInv.Apply(" ")
		    lines.Add(inputLine)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press 1-3 then Enter"))
		  Else
		    Var line As String = "  " + prefixBold.Apply("?") + " "
		    line = line + qBold.Apply("What action?") + " "
		    line = line + ansStyle.Apply(mPromptAnswer)
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press any key to reset"))
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleConfirmDemoKey(key As XjKeyEvent)
		  // [EN] Batch 3: key handler for XjConfirmPrompt demo.
		  //      Active: Y→Yes, N→No. Settled: any key resets.
		  // [TH] Batch 3: key handler สำหรับ demo XjConfirmPrompt
		  //      Active: Y→Yes, N→No. Settled: กด key ใดๆ รีเซ็ต
		  If mPromptState = 1 Then
		    mPromptState = 0
		    mPromptAnswer = ""
		    mOverlayLines = BuildConfirmOverlay()
		    Return
		  End If
		  If key.Char = "y" Or key.Char = "Y" Then
		    mPromptState = 1
		    mPromptAnswer = "Yes"
		    mOverlayLines = BuildConfirmOverlay()
		  ElseIf key.Char = "n" Or key.Char = "N" Then
		    mPromptState = 1
		    mPromptAnswer = "No"
		    mOverlayLines = BuildConfirmOverlay()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKeyPressDemoKey(key As XjKeyEvent)
		  // [EN] Batch 3: key handler for XjKeyPressPrompt demo.
		  //      Active: captures any key and shows its name. Settled: any key resets.
		  //      Uses XjKeyEvent.KeyName() for display.
		  // [TH] Batch 3: key handler สำหรับ demo XjKeyPressPrompt
		  //      Active: จับ key ใดๆ แล้วแสดงชื่อ Settled: กด key ใดๆ รีเซ็ต
		  //      ใช้ XjKeyEvent.KeyName() สำหรับการแสดงผล
		  If mPromptState = 1 Then
		    mPromptState = 0
		    mPromptAnswer = ""
		    mOverlayLines = BuildKeyPressOverlay()
		    Return
		  End If
		  // [EN] Capture key and show its name
		  // [TH] จับ key และแสดงชื่อ
		  mPromptState = 1
		  mPromptAnswer = key.KeyName()
		  mOverlayLines = BuildKeyPressOverlay()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleExpandDemoKey(key As XjKeyEvent)
		  // [EN] Batch 3: key handler for XjExpandPrompt demo.
		  //      Active collapsed: h expands, y/n selects.
		  //      Active expanded: y/n selects.
		  //      Settled: any key resets.
		  // [TH] Batch 3: key handler สำหรับ demo XjExpandPrompt
		  //      Active ย่อ: h ขยาย, y/n เลือก
		  //      Active ขยาย: y/n เลือก
		  //      Settled: กด key ใดๆ รีเซ็ต
		  If mPromptState = 1 Then
		    mPromptState = 0
		    mPromptAnswer = ""
		    mExpandExpanded = False
		    mOverlayLines = BuildExpandOverlay()
		    Return
		  End If
		  If key.Char = "h" Or key.Char = "H" Then
		    mExpandExpanded = Not mExpandExpanded
		    mOverlayLines = BuildExpandOverlay()
		  ElseIf key.Char = "y" Or key.Char = "Y" Then
		    mPromptState = 1
		    mPromptAnswer = "Yes"
		    mOverlayLines = BuildExpandOverlay()
		  ElseIf key.Char = "n" Or key.Char = "N" Then
		    mPromptState = 1
		    mPromptAnswer = "No"
		    mOverlayLines = BuildExpandOverlay()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleAskDemoKey(key As XjKeyEvent)
		  // [EN] Batch 3: key handler for XjAskPrompt demo.
		  //      Active: printable chars append to mPromptInput, Backspace deletes last char,
		  //      Enter submits (uses default "John" if empty). Settled: any key resets.
		  // [TH] Batch 3: key handler สำหรับ demo XjAskPrompt
		  //      Active: ตัวอักษรที่พิมพ์ได้ต่อท้าย mPromptInput, Backspace ลบตัวสุดท้าย,
		  //      Enter ส่ง (ใช้ "John" เป็นค่าเริ่มต้นถ้าว่าง) Settled: กด key ใดๆ รีเซ็ต
		  If mPromptState = 1 Then
		    mPromptState = 0
		    mPromptInput = ""
		    mPromptAnswer = ""
		    mOverlayLines = BuildAskOverlay()
		    Return
		  End If
		  If key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    mPromptState = 1
		    If mPromptInput = "" Then
		      mPromptAnswer = "John"
		    Else
		      mPromptAnswer = mPromptInput
		    End If
		    mOverlayLines = BuildAskOverlay()
		  ElseIf key.KeyCode = XjKeyEvent.KEY_BACKSPACE Then
		    If mPromptInput.Length > 0 Then
		      mPromptInput = mPromptInput.Left(mPromptInput.Length - 1)
		      mOverlayLines = BuildAskOverlay()
		    End If
		  ElseIf key.Char <> "" And key.Char >= " " Then
		    mPromptInput = mPromptInput + key.Char
		    mOverlayLines = BuildAskOverlay()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleEnumDemoKey(key As XjKeyEvent)
		  // [EN] Batch 3: key handler for XjEnumSelectPrompt demo.
		  //      Active: digit keys (1-3) build input, Backspace deletes last digit,
		  //      Enter validates and selects. Settled: any key resets.
		  // [TH] Batch 3: key handler สำหรับ demo XjEnumSelectPrompt
		  //      Active: ปุ่มตัวเลข (1-3) สร้าง input, Backspace ลบตัวสุดท้าย,
		  //      Enter ตรวจสอบและเลือก Settled: กด key ใดๆ รีเซ็ต
		  If mPromptState = 1 Then
		    mPromptState = 0
		    mPromptInput = ""
		    mPromptAnswer = ""
		    mOverlayLines = BuildEnumOverlay()
		    Return
		  End If
		  If key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    Var n As Integer = Val(mPromptInput)
		    If n >= 1 And n <= 3 Then
		      mPromptState = 1
		      Select Case n
		      Case 1
		        mPromptAnswer = "Save"
		      Case 2
		        mPromptAnswer = "Load"
		      Case 3
		        mPromptAnswer = "Quit"
		      End Select
		      mOverlayLines = BuildEnumOverlay()
		    End If
		  ElseIf key.KeyCode = XjKeyEvent.KEY_BACKSPACE Then
		    If mPromptInput.Length > 0 Then
		      mPromptInput = mPromptInput.Left(mPromptInput.Length - 1)
		      mOverlayLines = BuildEnumOverlay()
		    End If
		  ElseIf key.Char >= "0" And key.Char <= "9" Then
		    mPromptInput = mPromptInput + key.Char
		    mOverlayLines = BuildEnumOverlay()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitBatch4State()
		  // [EN] Batch 4: type-specific state initialisation for complex prompt demos.
		  //      Called from ActivateDemoWidget to set up arrays/counters per demo type.
		  // [TH] Batch 4: เริ่มต้น state เฉพาะประเภทสำหรับ demo prompt ซับซ้อน
		  //      เรียกจาก ActivateDemoWidget เพื่อตั้งค่า array/counter ตาม demo type
		  Select Case mDemoType
		  Case "multiselect"
		    mSelectChecked.RemoveAll
		    Var i As Integer
		    For i = 0 To 4
		      mSelectChecked.Add(False)
		    Next
		  Case "suggest"
		    mSuggestFiltered.RemoveAll
		  Case "collect"
		    mCollectStep = 0
		    mCollectAnswers.RemoveAll
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateSuggestFilter()
		  // [EN] Batch 4: rebuild mSuggestFiltered from hardcoded color list based on mPromptInput.
		  //      Case-insensitive substring matching. Resets mSelectIndex if out of bounds.
		  // [TH] Batch 4: สร้าง mSuggestFiltered ใหม่จากรายการสีที่กำหนดตาม mPromptInput
		  //      จับคู่ substring ไม่สนตัวพิมพ์ รีเซ็ต mSelectIndex ถ้าเกินขอบเขต
		  mSuggestFiltered.RemoveAll
		  Var all() As String
		  all.Add("Red")
		  all.Add("Green")
		  all.Add("Blue")
		  all.Add("Yellow")
		  all.Add("Cyan")
		  all.Add("Magenta")
		  all.Add("White")
		  all.Add("Orange")
		  all.Add("Purple")
		  all.Add("Pink")
		  Var query As String = mPromptInput.Lowercase
		  Var i As Integer
		  For i = 0 To all.Count - 1
		    If query = "" Or Instr(all(i).Lowercase, query) > 0 Then
		      mSuggestFiltered.Add(all(i))
		    End If
		  Next
		  If mSelectIndex >= mSuggestFiltered.Count Then
		    mSelectIndex = 0
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildSelectOverlay() As String()
		  // [EN] Batch 4: build overlay for XjSelectPrompt mockup.
		  //      Active: arrow list with ❯ marker, Up/Down navigate, Enter selects.
		  //      Settled: shows selected choice.
		  // [TH] Batch 4: สร้าง overlay สำหรับ mockup XjSelectPrompt
		  //      Active: รายการลูกศรพร้อม ❯, Up/Down navigate, Enter เลือก
		  //      Settled: แสดง choice ที่เลือก
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjSelectPrompt Demo"))
		  lines.Add("")

		  Var prefixGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var prefixBold As XjStyle = prefixGreen.SetBold
		  Var qStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE)
		  Var qBold As XjStyle = qStyle.SetBold
		  Var ansStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var helpDim As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var activeInv As XjStyle = base.SetInverse

		  Var items() As String
		  items.Add("React")
		  items.Add("Vue")
		  items.Add("Angular")
		  items.Add("Svelte")
		  items.Add("Ember")

		  If mPromptState = 0 Then
		    Var qLine As String = "  " + prefixBold.Apply("?") + " "
		    qLine = qLine + qBold.Apply("Choose a framework:")
		    lines.Add(qLine)
		    Var marker As String = Chr(&h276F)
		    Var i As Integer
		    For i = 0 To items.Count - 1
		      If i = mSelectIndex Then
		        lines.Add("  " + ansStyle.Apply(marker) + " " + activeInv.Apply(items(i)))
		      Else
		        lines.Add("    " + items(i))
		      End If
		    Next
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Up/Dn navigate   Enter select"))
		  Else
		    Var line As String = "  " + prefixBold.Apply("?") + " "
		    line = line + qBold.Apply("Choose a framework:") + " "
		    line = line + ansStyle.Apply(mPromptAnswer)
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press any key to reset"))
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildMultiSelectOverlay() As String()
		  // [EN] Batch 4: build overlay for XjMultiSelectPrompt mockup.
		  //      Active: checkbox list with ■/□ symbols, Space toggles, Enter confirms.
		  //      Settled: shows comma-separated selected items.
		  // [TH] Batch 4: สร้าง overlay สำหรับ mockup XjMultiSelectPrompt
		  //      Active: รายการ checkbox พร้อม ■/□, Space สลับ, Enter ยืนยัน
		  //      Settled: แสดง item ที่เลือกคั่นด้วยเครื่องหมายจุลภาค
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjMultiSelectPrompt Demo"))
		  lines.Add("")

		  Var prefixGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var prefixBold As XjStyle = prefixGreen.SetBold
		  Var qStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE)
		  Var qBold As XjStyle = qStyle.SetBold
		  Var ansStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var helpDim As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var activeInv As XjStyle = base.SetInverse
		  Var greenClr As XjStyle = base.SetFG(XjANSI.FG_GREEN)

		  Var items() As String
		  items.Add("Cheese")
		  items.Add("Pepperoni")
		  items.Add("Mushrooms")
		  items.Add("Olives")
		  items.Add("Peppers")

		  If mPromptState = 0 Then
		    Var qLine As String = "  " + prefixBold.Apply("?") + " "
		    qLine = qLine + qBold.Apply("Select toppings:")
		    lines.Add(qLine)
		    Var marker As String = Chr(&h276F)
		    Var checked As String = Chr(&h25A0)
		    Var unchecked As String = Chr(&h25A1)
		    Var i As Integer
		    For i = 0 To items.Count - 1
		      Var box As String
		      If mSelectChecked.Count > i And mSelectChecked(i) Then
		        box = greenClr.Apply(checked)
		      Else
		        box = unchecked
		      End If
		      If i = mSelectIndex Then
		        lines.Add("  " + ansStyle.Apply(marker) + " " + box + " " + activeInv.Apply(items(i)))
		      Else
		        lines.Add("    " + box + " " + items(i))
		      End If
		    Next
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Up/Dn   Space toggle   a all   n none   Enter"))
		  Else
		    Var line As String = "  " + prefixBold.Apply("?") + " "
		    line = line + qBold.Apply("Select toppings:") + " "
		    line = line + ansStyle.Apply(mPromptAnswer)
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press any key to reset"))
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildSuggestOverlay() As String()
		  // [EN] Batch 4: build overlay for XjSuggestPrompt mockup.
		  //      Active: text input with filtered suggestion dropdown.
		  //      Settled: shows confirmed value.
		  // [TH] Batch 4: สร้าง overlay สำหรับ mockup XjSuggestPrompt
		  //      Active: input ข้อความพร้อม dropdown suggestion ที่กรองแล้ว
		  //      Settled: แสดงค่าที่ยืนยัน
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjSuggestPrompt Demo"))
		  lines.Add("")

		  Var prefixGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var prefixBold As XjStyle = prefixGreen.SetBold
		  Var qStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE)
		  Var qBold As XjStyle = qStyle.SetBold
		  Var ansStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var helpDim As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var cursorInv As XjStyle = base.SetInverse
		  Var activeInv As XjStyle = base.SetInverse

		  If mPromptState = 0 Then
		    Var inputLine As String = "  " + prefixBold.Apply("?") + " "
		    inputLine = inputLine + qBold.Apply("Enter a color:") + " "
		    If mPromptInput <> "" Then
		      inputLine = inputLine + mPromptInput
		    End If
		    inputLine = inputLine + cursorInv.Apply(" ")
		    lines.Add(inputLine)

		    // [EN] Show filtered suggestions (max 5 visible)
		    // [TH] แสดง suggestion ที่กรองแล้ว (สูงสุด 5 รายการ)
		    Var marker As String = Chr(&h276F)
		    Var maxShow As Integer = 5
		    If mSuggestFiltered.Count > 0 Then
		      Var showCount As Integer = mSuggestFiltered.Count
		      If showCount > maxShow Then showCount = maxShow
		      Var i As Integer
		      For i = 0 To showCount - 1
		        If i = mSelectIndex Then
		          lines.Add("  " + ansStyle.Apply(marker) + " " + activeInv.Apply(mSuggestFiltered(i)))
		        Else
		          lines.Add("    " + mSuggestFiltered(i))
		        End If
		      Next
		      If mSuggestFiltered.Count > maxShow Then
		        Var remaining As Integer = mSuggestFiltered.Count - maxShow
		        lines.Add("  " + helpDim.Apply("(" + remaining.ToString + " more)"))
		      End If
		    End If
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Type to filter   Tab accept   Enter confirm"))
		  Else
		    Var checkMark As String = Chr(&h2714)
		    Var line As String = "  " + prefixBold.Apply(checkMark) + " "
		    line = line + qBold.Apply("Enter a color:") + " "
		    line = line + ansStyle.Apply(mPromptAnswer)
		    lines.Add(line)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press any key to reset"))
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildCollectOverlay() As String()
		  // [EN] Batch 4: build overlay for XjCollectPrompt mockup.
		  //      Shows completed steps above current step. 3-step wizard:
		  //      Step 0: Ask "Your name?" / Step 1: Confirm "Accept terms?" / Step 2: Select "Language:"
		  // [TH] Batch 4: สร้าง overlay สำหรับ mockup XjCollectPrompt
		  //      แสดงขั้นตอนที่เสร็จแล้วเหนือขั้นตอนปัจจุบัน wizard 3 ขั้นตอน:
		  //      Step 0: Ask "Your name?" / Step 1: Confirm "Accept terms?" / Step 2: Select "Language:"
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjCollectPrompt Demo"))
		  lines.Add("")

		  Var prefixGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var prefixBold As XjStyle = prefixGreen.SetBold
		  Var qStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE)
		  Var qBold As XjStyle = qStyle.SetBold
		  Var ansStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var helpDim As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var cursorInv As XjStyle = base.SetInverse
		  Var activeInv As XjStyle = base.SetInverse
		  Var checkMark As String = Chr(&h2714)

		  // [EN] Show completed steps
		  // [TH] แสดงขั้นตอนที่เสร็จแล้ว
		  If mCollectAnswers.Count > 0 Then
		    lines.Add("  " + prefixBold.Apply(checkMark) + " " + qBold.Apply("Your name?") + " " + ansStyle.Apply(mCollectAnswers(0)))
		  End If
		  If mCollectAnswers.Count > 1 Then
		    lines.Add("  " + prefixBold.Apply(checkMark) + " " + qBold.Apply("Accept terms?") + " " + ansStyle.Apply(mCollectAnswers(1)))
		  End If
		  If mCollectAnswers.Count > 2 Then
		    lines.Add("  " + prefixBold.Apply(checkMark) + " " + qBold.Apply("Language:") + " " + ansStyle.Apply(mCollectAnswers(2)))
		  End If

		  If mPromptState = 1 Then
		    // [EN] All steps complete
		    // [TH] ทุกขั้นตอนเสร็จสิ้น
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("All steps complete! Press any key to reset"))
		    Return lines
		  End If

		  // [EN] Show current step
		  // [TH] แสดงขั้นตอนปัจจุบัน
		  Var stepNum As Integer = mCollectStep + 1
		  Var stepLabel As String = "Step " + stepNum.ToString + "/3"
		  lines.Add("  " + helpDim.Apply(stepLabel))

		  Var langs() As String
		  langs.Add("English")
		  langs.Add("Thai")
		  langs.Add("Japanese")

		  Select Case mCollectStep
		  Case 0
		    Var askLine As String = "  " + prefixBold.Apply("?") + " " + qBold.Apply("Your name?")
		    If mPromptInput = "" Then
		      askLine = askLine + " " + cursorInv.Apply(" ")
		    Else
		      askLine = askLine + " " + mPromptInput + cursorInv.Apply(" ")
		    End If
		    lines.Add(askLine)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Type text, Enter to next step"))
		  Case 1
		    Var confLine As String = "  " + prefixBold.Apply("?") + " "
		    confLine = confLine + qBold.Apply("Accept terms?") + " "
		    confLine = confLine + helpDim.Apply("(Y/n)") + " "
		    confLine = confLine + cursorInv.Apply(" ")
		    lines.Add(confLine)
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Press Y or N"))
		  Case 2
		    Var selLine As String = "  " + prefixBold.Apply("?") + " " + qBold.Apply("Language:")
		    lines.Add(selLine)
		    Var marker As String = Chr(&h276F)
		    Var i As Integer
		    For i = 0 To langs.Count - 1
		      If i = mSelectIndex Then
		        lines.Add("  " + ansStyle.Apply(marker) + " " + activeInv.Apply(langs(i)))
		      Else
		        lines.Add("    " + langs(i))
		      End If
		    Next
		    lines.Add("")
		    lines.Add("  " + helpDim.Apply("Up/Dn navigate   Enter select"))
		  End Select

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleSelectDemoKey(key As XjKeyEvent)
		  // [EN] Batch 4: key handler for XjSelectPrompt demo.
		  //      Up/Down navigate, Enter selects. Settled: any key resets.
		  // [TH] Batch 4: key handler สำหรับ demo XjSelectPrompt
		  //      Up/Down navigate, Enter เลือก Settled: กด key ใดๆ รีเซ็ต
		  If mPromptState = 1 Then
		    mPromptState = 0
		    mSelectIndex = 0
		    mPromptAnswer = ""
		    mOverlayLines = BuildSelectOverlay()
		    Return
		  End If
		  If key.KeyCode = XjKeyEvent.KEY_UP Then
		    If mSelectIndex > 0 Then
		      mSelectIndex = mSelectIndex - 1
		    Else
		      mSelectIndex = 4
		    End If
		    mOverlayLines = BuildSelectOverlay()
		  ElseIf key.KeyCode = XjKeyEvent.KEY_DOWN Then
		    If mSelectIndex < 4 Then
		      mSelectIndex = mSelectIndex + 1
		    Else
		      mSelectIndex = 0
		    End If
		    mOverlayLines = BuildSelectOverlay()
		  ElseIf key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    Var items() As String
		    items.Add("React")
		    items.Add("Vue")
		    items.Add("Angular")
		    items.Add("Svelte")
		    items.Add("Ember")
		    mPromptState = 1
		    mPromptAnswer = items(mSelectIndex)
		    mOverlayLines = BuildSelectOverlay()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleMultiSelectDemoKey(key As XjKeyEvent)
		  // [EN] Batch 4: key handler for XjMultiSelectPrompt demo.
		  //      Up/Down navigate, Space toggles, a=all, n=none, Enter confirms.
		  // [TH] Batch 4: key handler สำหรับ demo XjMultiSelectPrompt
		  //      Up/Down navigate, Space สลับ, a=เลือกทั้งหมด, n=ยกเลิกทั้งหมด, Enter ยืนยัน
		  If mPromptState = 1 Then
		    mPromptState = 0
		    mSelectIndex = 0
		    mPromptAnswer = ""
		    Var k As Integer
		    For k = 0 To mSelectChecked.Count - 1
		      mSelectChecked(k) = False
		    Next
		    mOverlayLines = BuildMultiSelectOverlay()
		    Return
		  End If
		  If key.KeyCode = XjKeyEvent.KEY_UP Then
		    If mSelectIndex > 0 Then
		      mSelectIndex = mSelectIndex - 1
		    Else
		      mSelectIndex = 4
		    End If
		    mOverlayLines = BuildMultiSelectOverlay()
		  ElseIf key.KeyCode = XjKeyEvent.KEY_DOWN Then
		    If mSelectIndex < 4 Then
		      mSelectIndex = mSelectIndex + 1
		    Else
		      mSelectIndex = 0
		    End If
		    mOverlayLines = BuildMultiSelectOverlay()
		  ElseIf key.Char = " " Then
		    If mSelectIndex < mSelectChecked.Count Then
		      mSelectChecked(mSelectIndex) = Not mSelectChecked(mSelectIndex)
		    End If
		    mOverlayLines = BuildMultiSelectOverlay()
		  ElseIf key.Char = "a" Or key.Char = "A" Then
		    Var k As Integer
		    For k = 0 To mSelectChecked.Count - 1
		      mSelectChecked(k) = True
		    Next
		    mOverlayLines = BuildMultiSelectOverlay()
		  ElseIf key.Char = "n" Or key.Char = "N" Then
		    Var k As Integer
		    For k = 0 To mSelectChecked.Count - 1
		      mSelectChecked(k) = False
		    Next
		    mOverlayLines = BuildMultiSelectOverlay()
		  ElseIf key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    Var items() As String
		    items.Add("Cheese")
		    items.Add("Pepperoni")
		    items.Add("Mushrooms")
		    items.Add("Olives")
		    items.Add("Peppers")
		    Var selected() As String
		    Var k As Integer
		    For k = 0 To mSelectChecked.Count - 1
		      If mSelectChecked(k) Then selected.Add(items(k))
		    Next
		    If selected.Count > 0 Then
		      mPromptState = 1
		      mPromptAnswer = String.FromArray(selected, ", ")
		      mOverlayLines = BuildMultiSelectOverlay()
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleSuggestDemoKey(key As XjKeyEvent)
		  // [EN] Batch 4: key handler for XjSuggestPrompt demo.
		  //      Type to filter, Tab accepts suggestion, Up/Down navigate, Enter confirms.
		  // [TH] Batch 4: key handler สำหรับ demo XjSuggestPrompt
		  //      พิมพ์เพื่อกรอง, Tab รับ suggestion, Up/Down navigate, Enter ยืนยัน
		  If mPromptState = 1 Then
		    mPromptState = 0
		    mPromptInput = ""
		    mPromptAnswer = ""
		    mSelectIndex = 0
		    UpdateSuggestFilter()
		    mOverlayLines = BuildSuggestOverlay()
		    Return
		  End If
		  If key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    If mPromptInput <> "" Then
		      mPromptState = 1
		      mPromptAnswer = mPromptInput
		      mOverlayLines = BuildSuggestOverlay()
		    End If
		  ElseIf key.KeyCode = XjKeyEvent.KEY_TAB Then
		    If mSuggestFiltered.Count > 0 And mSelectIndex < mSuggestFiltered.Count Then
		      mPromptInput = mSuggestFiltered(mSelectIndex)
		      UpdateSuggestFilter()
		      mOverlayLines = BuildSuggestOverlay()
		    End If
		  ElseIf key.KeyCode = XjKeyEvent.KEY_UP Then
		    If mSuggestFiltered.Count > 0 Then
		      If mSelectIndex > 0 Then
		        mSelectIndex = mSelectIndex - 1
		      Else
		        mSelectIndex = mSuggestFiltered.Count - 1
		        If mSelectIndex > 4 Then mSelectIndex = 4
		      End If
		      mOverlayLines = BuildSuggestOverlay()
		    End If
		  ElseIf key.KeyCode = XjKeyEvent.KEY_DOWN Then
		    If mSuggestFiltered.Count > 0 Then
		      Var maxIdx As Integer = mSuggestFiltered.Count - 1
		      If maxIdx > 4 Then maxIdx = 4
		      If mSelectIndex < maxIdx Then
		        mSelectIndex = mSelectIndex + 1
		      Else
		        mSelectIndex = 0
		      End If
		      mOverlayLines = BuildSuggestOverlay()
		    End If
		  ElseIf key.KeyCode = XjKeyEvent.KEY_BACKSPACE Then
		    If mPromptInput.Length > 0 Then
		      mPromptInput = mPromptInput.Left(mPromptInput.Length - 1)
		      mSelectIndex = 0
		      UpdateSuggestFilter()
		      mOverlayLines = BuildSuggestOverlay()
		    End If
		  ElseIf key.Char <> "" And key.Char >= " " Then
		    mPromptInput = mPromptInput + key.Char
		    mSelectIndex = 0
		    UpdateSuggestFilter()
		    mOverlayLines = BuildSuggestOverlay()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleCollectDemoKey(key As XjKeyEvent)
		  // [EN] Batch 4: key handler for XjCollectPrompt demo.
		  //      Routes to step-specific logic. All-done: any key resets.
		  // [TH] Batch 4: key handler สำหรับ demo XjCollectPrompt
		  //      ส่งต่อไปยัง logic เฉพาะขั้นตอน เสร็จทั้งหมด: กด key ใดๆ รีเซ็ต
		  If mPromptState = 1 Then
		    mPromptState = 0
		    mPromptInput = ""
		    mSelectIndex = 0
		    mCollectStep = 0
		    mCollectAnswers.RemoveAll
		    mOverlayLines = BuildCollectOverlay()
		    Return
		  End If
		  Select Case mCollectStep
		  Case 0
		    HandleCollectAskStep(key)
		  Case 1
		    HandleCollectConfirmStep(key)
		  Case 2
		    HandleCollectSelectStep(key)
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleCollectAskStep(key As XjKeyEvent)
		  // [EN] Batch 4: collect step 0 — text input for "Your name?"
		  // [TH] Batch 4: collect ขั้นตอน 0 — input ข้อความสำหรับ "Your name?"
		  If key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    If mPromptInput <> "" Then
		      mCollectAnswers.Add(mPromptInput)
		      mPromptInput = ""
		      mCollectStep = 1
		      mOverlayLines = BuildCollectOverlay()
		    End If
		  ElseIf key.KeyCode = XjKeyEvent.KEY_BACKSPACE Then
		    If mPromptInput.Length > 0 Then
		      mPromptInput = mPromptInput.Left(mPromptInput.Length - 1)
		      mOverlayLines = BuildCollectOverlay()
		    End If
		  ElseIf key.Char <> "" And key.Char >= " " Then
		    mPromptInput = mPromptInput + key.Char
		    mOverlayLines = BuildCollectOverlay()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleCollectConfirmStep(key As XjKeyEvent)
		  // [EN] Batch 4: collect step 1 — Y/N for "Accept terms?"
		  // [TH] Batch 4: collect ขั้นตอน 1 — Y/N สำหรับ "Accept terms?"
		  If key.Char = "y" Or key.Char = "Y" Then
		    mCollectAnswers.Add("Yes")
		    mSelectIndex = 0
		    mCollectStep = 2
		    mOverlayLines = BuildCollectOverlay()
		  ElseIf key.Char = "n" Or key.Char = "N" Then
		    mCollectAnswers.Add("No")
		    mSelectIndex = 0
		    mCollectStep = 2
		    mOverlayLines = BuildCollectOverlay()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleCollectSelectStep(key As XjKeyEvent)
		  // [EN] Batch 4: collect step 2 — select "Language:" from list
		  // [TH] Batch 4: collect ขั้นตอน 2 — เลือก "Language:" จากรายการ
		  If key.KeyCode = XjKeyEvent.KEY_UP Then
		    If mSelectIndex > 0 Then
		      mSelectIndex = mSelectIndex - 1
		    Else
		      mSelectIndex = 2
		    End If
		    mOverlayLines = BuildCollectOverlay()
		  ElseIf key.KeyCode = XjKeyEvent.KEY_DOWN Then
		    If mSelectIndex < 2 Then
		      mSelectIndex = mSelectIndex + 1
		    Else
		      mSelectIndex = 0
		    End If
		    mOverlayLines = BuildCollectOverlay()
		  ElseIf key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    Var langs() As String
		    langs.Add("English")
		    langs.Add("Thai")
		    langs.Add("Japanese")
		    mCollectAnswers.Add(langs(mSelectIndex))
		    mPromptState = 1
		    mOverlayLines = BuildCollectOverlay()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PopulateTree()
		  // [EN] Initialise the registry and show all 31 components in the tree.
		  //      Delegates to RebuildTree so the same builder handles filtered views too.
		  // [TH] เริ่มต้น registry และแสดง component ทั้ง 31 รายการใน tree
		  //      ส่งต่อไปยัง RebuildTree เพื่อให้ใช้ builder เดียวกันกับ filtered view ด้วย
		  KSComponentRegistry.Init()
		  Var allEntries() As KSComponentEntry
		  For i As Integer = 0 To KSComponentRegistry.Count() - 1
		    allEntries.Add(KSComponentRegistry.EntryAt(i))
		  Next i
		  RebuildTree(allEntries)
		  If mFlatNodes.Count > 0 Then SelectLine(0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RebuildTree(entries() As KSComponentEntry)
		  // [EN] Rebuild mFlatNodes, mFlatEntries, and the XjTree from an arbitrary slice
		  //      of component entries. Categories with no matching entries are omitted.
		  //      Resets mScrollOffset and mSelectedLine; caller calls SelectLine if needed.
		  // [TH] สร้าง mFlatNodes, mFlatEntries และ XjTree ใหม่จาก entry ที่กำหนด
		  //      หมวดหมู่ที่ไม่มี entry ที่ตรงจะถูกละเว้น
		  //      รีเซ็ต mScrollOffset และ mSelectedLine; ผู้เรียกเรียก SelectLine ถ้าต้องการ
		  mFlatNodes.RemoveAll
		  mFlatEntries.RemoveAll
		  mScrollOffset = 0
		  mSelectedLine = -1

		  Var catBase As New XjStyle
		  Var catWithCyan As XjStyle = catBase.SetFG(XjANSI.FG_CYAN)
		  Var catStyle As XjStyle = catWithCyan.SetBold()

		  Var roots() As XjTreeNode
		  Var cats() As String = KSComponentRegistry.Categories()

		  For i As Integer = 0 To cats.Count - 1
		    Var cat As String = cats(i)

		    // [EN] Collect entries that belong to this category
		    // [TH] รวบรวม entry ที่อยู่ใน category นี้
		    Var catEntries() As KSComponentEntry
		    For j As Integer = 0 To entries.Count - 1
		      If entries(j).Category = cat Then
		        catEntries.Add(entries(j))
		      End If
		    Next j

		    // [EN] Skip categories with no matching entries (relevant in search mode)
		    // [TH] ข้าม category ที่ไม่มี entry ที่ตรง (สำคัญใน search mode)
		    If catEntries.Count = 0 Then
		      // nothing to add for this category
		    Else
		      Var catNode As New XjTreeNode(cat)
		      Call catNode.SetNodeStyle(catStyle)
		      mFlatNodes.Add(catNode)
		      mFlatEntries.Add(Nil)

		      For j As Integer = 0 To catEntries.Count - 1
		        Var leafNode As New XjTreeNode(catEntries(j).Name)
		        Call catNode.AddChild(leafNode)
		        mFlatNodes.Add(leafNode)
		        mFlatEntries.Add(catEntries(j))
		      Next j

		      roots.Add(catNode)
		    End If
		  Next i

		  Call mListTree.SetData(roots)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Render()
		  // [EN] Guard: terminal smaller than 80×24 — skip layout, show plain message.
		  // [TH] ตรวจสอบ: terminal เล็กกว่า 80×24 — ข้าม layout แสดงข้อความธรรมดา
		  If mTermWidth < 80 Or mTermHeight < 24 Then
		    XjScreen.Clear()
		    XjTerminal.Write("Terminal too small (" + mTermWidth.ToString + "x" + mTermHeight.ToString + ")" + Chr(10) + "Minimum required: 80x24")
		    Return
		  End If

		  // [EN] Render pipeline: solve layout → clear canvas → paint tree → flush
		  // [TH] Render pipeline: คำนวณ layout → ล้าง canvas → วาด tree → ส่งออก
		  XjLayoutSolver.Solve(mRoot.LayoutNode, mTermWidth, mTermHeight)
		  mCanvas.Clear()
		  mRoot.Paint(mCanvas)
		  XjTerminal.Write(mCanvas.Render())
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RenderHelp()
		  // [EN] Render the normal UI first, then draw a centered help overlay on top.
		  //      Uses ANSI cursor positioning (ESC[row;colH) to write the box without
		  //      touching the widget tree. Any key press dismisses it (see HandleKey).
		  // [TH] Render UI ปกติก่อน แล้ววาด help overlay ตรงกลางทับด้านบน
		  //      ใช้ ANSI cursor positioning วาดกล่องโดยไม่แตะ widget tree
		  //      กด key ใดๆ เพื่อปิด (ดู HandleKey)
		  Render()

		  Var inner As Integer = 38
		  Var boxH As Integer = 15
		  Var startCol As Integer = (mTermWidth - inner - 2) \ 2 + 1
		  Var startRow As Integer = (mTermHeight - boxH) \ 2 + 1
		  If startCol < 1 Then startCol = 1
		  If startRow < 1 Then startRow = 1

		  Var esc As String = Chr(27)
		  Var CYAN As String = esc + "[36m"
		  Var BOLD As String = esc + "[1m"
		  Var dimStyle As String = esc + "[90m"
		  Var RST As String = esc + "[0m"

		  // [EN] Horizontal border: inner dashes
		  // [TH] เส้นขอบแนวนอน: ขีดกลาง inner ตัว
		  Var hbar As String = ""
		  For k As Integer = 1 To inner
		    hbar = hbar + "-"
		  Next k

		  // [EN] Build the complete overlay output string
		  // [TH] สร้าง string output ของ overlay ทั้งหมด
		  Var out As String = ""

		  // Top border
		  out = out + esc + "[" + startRow.ToString + ";" + startCol.ToString + "H"
		  out = out + CYAN + "+" + hbar + "+" + RST

		  // Title row
		  Var titleContent As String = "          Keyboard Shortcuts          "
		  Var titleRow As Integer = startRow + 1
		  out = out + esc + "[" + titleRow.ToString + ";" + startCol.ToString + "H"
		  out = out + CYAN + "|" + RST + BOLD + titleContent + RST + CYAN + "|" + RST

		  // Separator
		  Var sepRow As Integer = startRow + 2
		  out = out + esc + "[" + sepRow.ToString + ";" + startCol.ToString + "H"
		  out = out + CYAN + "+" + hbar + "+" + RST

		  // Key binding rows — each padded to exactly inner chars
		  Var bases() As String
		  bases.Add("  /         Search components")
		  bases.Add("  Up/Dn     Navigate list")
		  bases.Add("  1-6       Jump to category")
		  bases.Add("  PgUp/Dn   Scroll by page")
		  bases.Add("  Home/End  First / last item")
		  bases.Add("  Tab       Enter live demo")
		  bases.Add("  Esc       Back to list")
		  bases.Add("  ?         Toggle this help")
		  bases.Add("  q         Quit")
		  bases.Add("")

		  For i As Integer = 0 To bases.Count - 1
		    Var row As String = bases(i)
		    While row.Length < inner
		      row = row + " "
		    Wend
		    Var contentRow As Integer = startRow + 3 + i
		    out = out + esc + "[" + contentRow.ToString + ";" + startCol.ToString + "H"
		    out = out + CYAN + "|" + RST + row + CYAN + "|" + RST
		  Next i

		  // Hint row
		  Var hintRow As Integer = startRow + 3 + bases.Count
		  Var hintStr As String = "        Press any key to close"
		  While hintStr.Length < inner
		    hintStr = hintStr + " "
		  Wend
		  out = out + esc + "[" + hintRow.ToString + ";" + startCol.ToString + "H"
		  out = out + CYAN + "|" + RST + dimStyle + hintStr + RST + CYAN + "|" + RST

		  // Bottom border
		  Var bottomRow As Integer = hintRow + 1
		  out = out + esc + "[" + bottomRow.ToString + ";" + startCol.ToString + "H"
		  out = out + CYAN + "+" + hbar + "+" + RST

		  XjTerminal.Write(out)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SelectLine(lineIdx As Integer)
		  // [EN] Move selection cursor: restore old node style → highlight new node
		  //      → update status bar + preview label → adjust scroll → mark tree dirty.
		  // [TH] เลื่อน cursor การเลือก: คืนสไตล์ node เก่า → ไฮไลต์ node ใหม่
		  //      → อัปเดต status bar + preview label → ปรับ scroll → mark tree dirty

		  // [EN] Restore previous node style
		  // [TH] คืนสไตล์ node ก่อนหน้า
		  If mSelectedLine >= 0 And mSelectedLine < mFlatNodes.Count Then
		    If mFlatEntries(mSelectedLine) Is Nil Then
		      Var restoreBase As New XjStyle
		      Var restoreWithCyan As XjStyle = restoreBase.SetFG(XjANSI.FG_CYAN)
		      Var restoreStyle As XjStyle = restoreWithCyan.SetBold()
		      Call mFlatNodes(mSelectedLine).SetNodeStyle(restoreStyle)
		    Else
		      Call mFlatNodes(mSelectedLine).SetNodeStyle(Nil)
		    End If
		  End If

		  mSelectedLine = lineIdx
		  If lineIdx < 0 Or lineIdx >= mFlatNodes.Count Then Return

		  // [EN] Highlight selected node — magenta background + white text (btop style)
		  // [TH] ไฮไลต์ node ที่เลือก — พื้นหลัง magenta + ข้อความสีขาว (สไตล์ btop)
		  Var selBase As New XjStyle
		  Var selWithBG As XjStyle = selBase.SetBG(XjANSI.BG_MAGENTA)
		  Var selStyle As XjStyle = selWithBG.SetFG(XjANSI.FG_WHITE)
		  Call mFlatNodes(lineIdx).SetNodeStyle(selStyle)

		  // [EN] Update status bar, preview widgets, and active demo widget
		  // [TH] อัปเดต status bar, preview widgets และ demo widget ที่ active
		  Var entry As KSComponentEntry = mFlatEntries(lineIdx)
		  If entry Is Nil Then
		    Call mStatusDesc.SetText(" [" + mFlatNodes(lineIdx).Label + "] category")
		    Call mPreviewTitle.SetText("<- select a component")
		    Call mPreviewBody.SetText("")
		    mPropsTable.ClearRows()
		    ActivateDemoWidget("")
		  Else
		    KSPreviewBuilder.LoadInto(entry, mPreviewTitle, mPreviewBody, mPropsTable)
		    Var demoType As String = KSInteractiveLoader.DemoTypeFor(entry)
		    ActivateDemoWidget(demoType)
		    // [EN] Status bar: ShortDesc + Tab hint when a live demo is available
		    // [TH] Status bar: ShortDesc + Tab hint เมื่อมี live demo
		    If demoType <> "" And demoType <> "mockup" Then
		      Call mStatusDesc.SetText(" " + entry.ShortDesc + "   Tab: enter demo")
		    Else
		      Call mStatusDesc.SetText(" " + entry.ShortDesc)
		    End If
		  End If

		  // [EN] Scroll: mTermHeight − 11 = visible rows inside componentList
		  //      breakdown: mRoot border(2) + header(3) + searchBar(3) + statusBar(1) + componentList border(2)
		  // [TH] Scroll: mTermHeight − 11 = จำนวนแถวที่มองเห็นภายใน componentList
		  Var visibleH As Integer = mTermHeight - 11
		  If visibleH < 1 Then visibleH = 1
		  If lineIdx < mScrollOffset Then
		    mScrollOffset = lineIdx
		  ElseIf lineIdx >= mScrollOffset + visibleH Then
		    mScrollOffset = lineIdx - visibleH + 1
		  End If

		  Call mListTree.SetScrollOffset(mScrollOffset)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RenderDemoOverlay()
		  If mOverlayLines.Count = 0 Then Return
		  Var startCol As Integer = mPreviewBody.ContentX() + 1
		  Var startRow As Integer = mPreviewBody.ContentY() + 1
		  Var maxW As Integer = mPreviewBody.ContentWidth()
		  Var maxH As Integer = mPreviewBody.ContentHeight()
		  Var esc As String = Chr(27)
		  Var out As String = ""
		  Var lineCount As Integer = mOverlayLines.Count - 1
		  If lineCount > maxH - 1 Then lineCount = maxH - 1
		  For i As Integer = 0 To lineCount
		    Var line As String = mOverlayLines(i)
		    Var clearStr As String = ""
		    Var j As Integer
		    For j = 1 To maxW
		      clearStr = clearStr + " "
		    Next
		    Var rowNum As Integer = startRow + i
		    Var rowPos As String = esc + "[" + rowNum.ToString + ";" + startCol.ToString + "H"
		    out = out + rowPos + XjANSI.Reset + clearStr + rowPos + line
		  Next
		  out = out + XjANSI.Reset
		  XjTerminal.Write(out)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildPieDemo(dataset As Integer) As String()
		  Var pie As New XjPie
		  Call pie.SetWidth(30)
		  Select Case dataset
		  Case 0
		    Call pie.AddSlice("Xojo", 45.0)
		    Call pie.AddSlice("Python", 25.0)
		    Call pie.AddSlice("Go", 15.0)
		    Call pie.AddSlice("Rust", 15.0)
		  Case 1
		    Call pie.AddSlice("macOS", 55.0)
		    Call pie.AddSlice("Windows", 30.0)
		    Call pie.AddSlice("Linux", 15.0)
		  Case 2
		    Call pie.AddSlice("Layout", 4.0)
		    Call pie.AddSlice("Widgets", 6.0)
		    Call pie.AddSlice("Prompts", 9.0)
		    Call pie.AddSlice("Style", 4.0)
		    Call pie.AddSlice("I/O", 4.0)
		    Call pie.AddSlice("Utility", 4.0)
		  End Select
		  Var result() As String
		  Var title As String
		  Select Case dataset
		  Case 0
		    title = "Languages"
		  Case 1
		    title = "Platforms"
		  Case 2
		    title = "XjTTY Components"
		  End Select
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleStyleBold As XjStyle = titleStyle.SetBold
		  result.Add(titleStyleBold.Apply("XjPie: " + title))
		  result.Add("")
		  Var pieLines() As String = pie.Render()
		  For i As Integer = 0 To pieLines.Count - 1
		    result.Add(pieLines(i))
		  Next
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildStyleDemo() As String()
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjStyle Showcase"))
		  lines.Add("")
		  Var bold As XjStyle = base.SetBold
		  Var dim_ As XjStyle = base.SetDim
		  Var italic As XjStyle = base.SetItalic
		  lines.Add(bold.Apply("Bold") + "  " + dim_.Apply("Dim") + "  " + italic.Apply("Italic"))
		  Var underline As XjStyle = base.SetUnderline
		  Var strike As XjStyle = base.SetStrikethrough
		  Var inverse As XjStyle = base.SetInverse
		  lines.Add(underline.Apply("Underline") + "  " + strike.Apply("Strike") + "  " + inverse.Apply("Inverse"))
		  lines.Add("")
		  Var fgRed As XjStyle = base.SetFG(XjANSI.FG_RED)
		  Var fgGreen As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var fgBlue As XjStyle = base.SetFG(XjANSI.FG_BLUE)
		  Var fgYellow As XjStyle = base.SetFG(XjANSI.FG_YELLOW)
		  lines.Add(fgRed.Apply("Red") + " " + fgGreen.Apply("Green") + " " + fgBlue.Apply("Blue") + " " + fgYellow.Apply("Yellow"))
		  Var fgCyan As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var fgMag As XjStyle = base.SetFG(XjANSI.FG_MAGENTA)
		  Var fgWhite As XjStyle = base.SetFG(XjANSI.FG_WHITE)
		  Var fgGray As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  lines.Add(fgCyan.Apply("Cyan") + " " + fgMag.Apply("Magenta") + " " + fgWhite.Apply("White") + " " + fgGray.Apply("Gray"))
		  lines.Add("")
		  Var bgRed As XjStyle = base.SetBG(XjANSI.BG_RED)
		  Var bgRedW As XjStyle = bgRed.SetFG(XjANSI.FG_WHITE)
		  Var bgBlue As XjStyle = base.SetBG(XjANSI.BG_BLUE)
		  Var bgBlueW As XjStyle = bgBlue.SetFG(XjANSI.FG_WHITE)
		  Var bgGreen As XjStyle = base.SetBG(XjANSI.BG_GREEN)
		  Var bgGreenB As XjStyle = bgGreen.SetFG(XjANSI.FG_BLACK)
		  lines.Add(bgRedW.Apply(" On Red ") + " " + bgBlueW.Apply(" On Blue ") + " " + bgGreenB.Apply(" On Green "))
		  lines.Add("")
		  Var boldRed As XjStyle = bold.SetFG(XjANSI.FG_RED)
		  Var italicCyan As XjStyle = italic.SetFG(XjANSI.FG_CYAN)
		  lines.Add(boldRed.Apply("Bold+Red") + "  " + italicCyan.Apply("Italic+Cyan"))
		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildColorDemo() As String()
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjColor Palette"))
		  lines.Add("")
		  lines.Add("Standard: " + XjColor.Red("Red") + " " + XjColor.Green("Grn") + " " + XjColor.Blue("Blu") + " " + XjColor.Yellow("Yel"))
		  lines.Add("          " + XjColor.Cyan("Cyn") + " " + XjColor.Magenta("Mag") + " " + XjColor.White("Wht"))
		  lines.Add("")
		  lines.Add("Bright:   " + XjColor.BrightRed("Red") + " " + XjColor.BrightGreen("Grn") + " " + XjColor.BrightBlue("Blu") + " " + XjColor.BrightYellow("Yel"))
		  lines.Add("          " + XjColor.BrightCyan("Cyn") + " " + XjColor.BrightMagenta("Mag") + " " + XjColor.White("Wht"))
		  lines.Add("")
		  Var block As String = Chr(&h2588)
		  Var strip As String = "256:      "
		  Var ci As Integer
		  For ci = 0 To 15
		    strip = strip + XjColor.Color256(block + block, ci * 16)
		  Next
		  lines.Add(strip)
		  lines.Add("")
		  lines.Add("Gradient: " + XjColor.Gradient("Rainbow gradient text!", 255, 0, 0, 0, 0, 255))
		  lines.Add("")
		  lines.Add("Semantic: " + XjColor.Success("Success") + " " + XjColor.Warning("Warning") + " " + XjColor.Error_("Error") + " " + XjColor.Info("Info"))
		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildCanvasDemo() As String()
		  Var lines() As String
		  Var base As New XjStyle
		  Var titleStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var titleBold As XjStyle = titleStyle.SetBold
		  lines.Add(titleBold.Apply("XjCanvas — 2D Character Buffer"))
		  lines.Add("")
		  Var dimStyle As XjStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  Var hlStyle As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  Var whiteStyle As XjStyle = base.SetFG(XjANSI.FG_WHITE)
		  lines.Add(dimStyle.Apply("Each position is an XjCell = char + XjStyle"))
		  lines.Add("")
		  lines.Add(whiteStyle.Apply("WriteText(x, y, text, style) to paint:"))
		  Var c As New XjCanvas(20, 3)
		  Var cyanStyle As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var cyanBold As XjStyle = cyanStyle.SetBold
		  Var greenStyle As XjStyle = base.SetFG(XjANSI.FG_GREEN)
		  c.WriteText(0, 0, "Hello", cyanBold)
		  c.WriteText(6, 0, "from", greenStyle)
		  c.WriteText(11, 0, "XjCanvas", hlStyle)
		  c.WriteText(0, 1, "Width:20 Height:3", dimStyle)
		  c.WriteText(0, 2, "Render() -> ANSI", whiteStyle)
		  Var border As String = dimStyle.Apply("+--------------------+")
		  lines.Add(border)
		  Var row As Integer
		  For row = 0 To 2
		    Var rowStr As String = dimStyle.Apply("|")
		    Var col As Integer
		    For col = 0 To 19
		      Var cell As XjCell = c.GetCell(col, row)
		      If cell <> Nil Then
		        Var cs As XjStyle = cell.Style
		        If cs <> Nil And Not cs.IsEmpty Then
		          rowStr = rowStr + cs.Apply(cell.Char)
		        Else
		          rowStr = rowStr + cell.Char
		        End If
		      Else
		        rowStr = rowStr + " "
		      End If
		    Next
		    rowStr = rowStr + dimStyle.Apply("|")
		    lines.Add(rowStr)
		  Next
		  lines.Add(border)
		  lines.Add("")
		  lines.Add(dimStyle.Apply("DiffRender() sends only changed cells"))
		  Return lines
		End Function
	#tag EndMethod

	// [EN] mCanvas           — 2D character buffer sized to current terminal dimensions
	// [EN] mDemoBar          — XjProgressBar demo; activated by ActivateDemoWidget("progressbar")
	// [EN] mDemoInput        — XjTextInput demo; activated by ActivateDemoWidget("textinput")
	// [EN] mDemoKeyText      — XjText demo for XjKeyEvent; shows last key code/char
	// [EN] mDemoSpinnerWidget — XjSpinner demo; auto-advances via HandleTick
	// [EN] mDemoTableBorder  — current border visibility state for XjTable demo
	// [EN] mDemoTableHeader  — current header visibility state for XjTable demo
	// [EN] mDemoTableWidget  — XjTable demo; activated by ActivateDemoWidget("table")
	// [EN] mDemoTextWidget   — XjText alignment/wrap demo; activated by ActivateDemoWidget("text")
	// [EN] mDemoTextWrap     — current word-wrap state for XjText demo
	// [EN] mDemoTreeScroll   — scroll offset for the XjTree demo widget
	// [EN] mDemoTreeWidget   — XjTree demo; activated by ActivateDemoWidget("tree")
	// [EN] mDemoType         — active demo type key ("textinput"|"progressbar"|"spinner"|"keyevent"|"text"|"table"|"tree"|"mockup"|"")
	// [EN] mFlatEntries      — parallel to mFlatNodes; Nil = category row, else entry
	// [EN] mFlatNodes        — XjTreeNode references in visible tree order
	// [EN] mListTree         — XjTree widget inside componentList panel
	// [EN] mLoop             — 30fps event loop; owns raw mode, alternate screen, callbacks
	// [EN] mPreviewBody      — XjText in livePreview showing long description + keywords
	// [EN] mPreviewFocus     — True when Tab has moved focus into the preview demo widget
	// [EN] mPreviewTitle     — XjText in livePreview showing "Name  [Category]" header
	// [EN] mPropsTable       — XjTable in propertiesPanel; 2-column property sheet
	// [EN] mRoot             — root of the widget tree; parent of all 4 panels
	// [EN] mScrollOffset     — current XjTree scroll position (first visible line index)
	// [EN] mSearchInput      — XjTextInput in searchBar; receives keys in search mode
	// [EN] mSearchMode       — True while the user is typing in the search bar
	// [EN] mSelectedLine     — currently highlighted flat-list index (-1 = none)
	// [EN] mShowHelp         — True while help overlay is displayed; any key press dismisses it
	// [EN] mStatusDesc       — XjText in status bar; shows ShortDesc or search feedback
	// [EN] mTermWidth/Height — current terminal dimensions, updated on every resize
	// [TH] mCanvas           — บัฟเฟอร์อักขระ 2D ตรงกับขนาด terminal ปัจจุบัน
	// [TH] mDemoBar          — demo XjProgressBar; เปิดด้วย ActivateDemoWidget("progressbar")
	// [TH] mDemoInput        — demo XjTextInput; เปิดด้วย ActivateDemoWidget("textinput")
	// [TH] mDemoKeyText      — demo XjText สำหรับ XjKeyEvent; แสดง key code/char ล่าสุด
	// [TH] mDemoSpinnerWidget — demo XjSpinner; auto-advance ผ่าน HandleTick
	// [TH] mDemoTableBorder  — สถานะ border ปัจจุบันสำหรับ demo XjTable
	// [TH] mDemoTableHeader  — สถานะ header ปัจจุบันสำหรับ demo XjTable
	// [TH] mDemoTableWidget  — demo XjTable; เปิดด้วย ActivateDemoWidget("table")
	// [TH] mDemoTextWidget   — demo XjText จัดตำแหน่ง/ตัดคำ; เปิดด้วย ActivateDemoWidget("text")
	// [TH] mDemoTextWrap     — สถานะ word-wrap ปัจจุบันสำหรับ demo XjText
	// [TH] mDemoTreeScroll   — scroll offset สำหรับ demo widget XjTree
	// [TH] mDemoTreeWidget   — demo XjTree; เปิดด้วย ActivateDemoWidget("tree")
	// [TH] mDemoType         — demo type ที่ active ("textinput"|"progressbar"|"spinner"|"keyevent"|"text"|"table"|"tree"|"mockup"|"")
	// [TH] mFlatEntries      — คู่ขนานกับ mFlatNodes; Nil = แถว category, มิฉะนั้น entry
	// [TH] mFlatNodes        — อ้างอิง XjTreeNode ตามลำดับที่มองเห็นใน tree
	// [TH] mListTree         — XjTree widget ภายใน panel componentList
	// [TH] mLoop             — event loop 30fps; ควบคุม raw mode, alternate screen, callback
	// [TH] mPreviewBody      — XjText ใน livePreview แสดงคำอธิบายยาว + keywords
	// [TH] mPreviewFocus     — True เมื่อ Tab ย้าย focus เข้าสู่ preview demo widget
	// [TH] mPreviewTitle     — XjText ใน livePreview แสดง header "ชื่อ  [Category]"
	// [TH] mPropsTable       — XjTable ใน propertiesPanel ตาราง property 2 คอลัมน์
	// [TH] mRoot             — root ของ widget tree; parent ของ panel ทั้ง 4 ส่วน
	// [TH] mScrollOffset     — ตำแหน่ง scroll ปัจจุบัน XjTree (index บรรทัดแรกที่มองเห็น)
	// [TH] mSearchInput      — XjTextInput ใน searchBar; รับ key ใน search mode
	// [TH] mSearchMode       — True ขณะผู้ใช้พิมพ์ใน search bar
	// [TH] mSelectedLine     — index flat-list ที่ไฮไลต์อยู่ (-1 = ยังไม่เลือก)
	// [TH] mShowHelp         — True ขณะ help overlay แสดงอยู่; กด key ใดๆ เพื่อปิด
	// [TH] mStatusDesc       — XjText ใน status bar; แสดง ShortDesc หรือผลการค้นหา
	// [TH] mTermWidth/Height — ขนาด terminal ปัจจุบัน อัปเดตทุกครั้งที่ resize
	#tag Property, Flags = &h21
		Private mCanvas As XjCanvas
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
		Private mDemoBar As XjProgressBar
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoInput As XjTextInput
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoKeyText As XjText
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoSpinnerWidget As XjSpinner
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoTableBorder As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoTableHeader As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoTableWidget As XjTable
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoTextWidget As XjText
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoTextWrap As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoTreeScroll As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoTreeWidget As XjTree
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDemoType As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOverlayLines() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPieDataset As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLoop As XjEventLoop
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPreviewBody As XjText
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPreviewFocus As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPreviewTitle As XjText
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPropsTable As XjTable
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRoot As XjBox
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScrollOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSearchInput As XjTextInput
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSearchMode As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowHelp As Boolean
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

	// [EN] mPromptState     — 0=active (waiting for input), 1=settled (answer shown)
	// [EN] mPromptInput     — typed text buffer for ask/enum prompt demos
	// [EN] mPromptAnswer    — final answer string shown in settled state
	// [EN] mExpandExpanded  — True when expand prompt demo shows full choice list
	// [TH] mPromptState     — 0=active (รอ input), 1=settled (แสดงคำตอบแล้ว)
	// [TH] mPromptInput     — บัฟเฟอร์ข้อความที่พิมพ์สำหรับ demo ask/enum prompt
	// [TH] mPromptAnswer    — คำตอบสุดท้ายที่แสดงในสถานะ settled
	// [TH] mExpandExpanded  — True เมื่อ expand prompt demo แสดง choice list เต็ม
	#tag Property, Flags = &h21
		Private mPromptState As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPromptInput As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPromptAnswer As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mExpandExpanded As Boolean
	#tag EndProperty

	// [EN] mSelectIndex      — cursor position in select/multiselect/suggest/collect demos (0-based)
	// [EN] mSelectChecked    — checkbox states for multiselect demo (parallel to item list)
	// [EN] mCollectStep      — current step index in collect demo (0=ask, 1=confirm, 2=select)
	// [EN] mCollectAnswers   — completed answers for each collect step
	// [EN] mSuggestFiltered  — cached filtered suggestion list for suggest demo
	// [TH] mSelectIndex      — ตำแหน่ง cursor ใน demo select/multiselect/suggest/collect (0-based)
	// [TH] mSelectChecked    — สถานะ checkbox สำหรับ demo multiselect (ขนานกับรายการ item)
	// [TH] mCollectStep      — index ขั้นตอนปัจจุบันใน demo collect (0=ask, 1=confirm, 2=select)
	// [TH] mCollectAnswers   — คำตอบที่เสร็จแล้วสำหรับแต่ละขั้นตอน collect
	// [TH] mSuggestFiltered  — รายการ suggestion ที่กรองแล้วสำหรับ demo suggest
	#tag Property, Flags = &h21
		Private mSelectIndex As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelectChecked() As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCollectStep As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCollectAnswers() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSuggestFiltered() As String
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
