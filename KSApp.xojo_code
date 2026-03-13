#tag Class
// [EN] KSApp is the application entry point. It owns the widget tree, event loop,
//      canvas, and all top-level UI state. Other modules (Registry, PreviewBuilder,
//      InteractiveLoader) are stateless factories or data stores that KSApp orchestrates.
//      Phase 3: two-mode key routing — list mode (default) and search mode.
//      Phase 4: static previews — KSPreviewBuilder populates mPreviewTitle,
//               mPreviewBody, and mPropsTable on every navigation step.
//      Phase 5: interactive previews — three focus zones; Tab enters the live demo
//               widget in the preview panel; Esc returns to list navigation.
// [TH] KSApp คือจุดเริ่มต้นของแอปพลิเคชัน เป็นเจ้าของ widget tree, event loop,
//      canvas และ state ระดับบนสุดทั้งหมด
//      Phase 3: key routing สองโหมด — list mode (เริ่มต้น) และ search mode
//      Phase 4: static previews — KSPreviewBuilder ป้อนข้อมูล mPreviewTitle,
//               mPreviewBody และ mPropsTable ทุกครั้งที่ navigate
//      Phase 5: interactive previews — 3 focus zones; Tab เข้า live demo widget
//               ใน preview panel; Esc กลับสู่ list navigation
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
		  mRoot = New XjBox
		  Call mRoot.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call mRoot.SetBorder(0, New XjStyle)
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
		  Call searchBar.SetBorder(0, New XjStyle)
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
		  Call componentList.SetBorder(0, New XjStyle)
		  Call componentList.SetTitle(" Components ")
		  mainArea.AddChild(componentList)

		  mListTree = New XjTree
		  componentList.AddChild(mListTree)

		  // [EN] Preview area: fills remaining width, owns livePreview + propertiesPanel
		  // [TH] Preview area: ขยายเต็มความกว้างที่เหลือ เป็นเจ้าของ livePreview + propertiesPanel
		  Var previewArea As New XjBox
		  Call previewArea.SetDirection(XjLayoutNode.DIR_COLUMN)
		  Call previewArea.SetBorder(0, New XjStyle)
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

		  // [EN] Properties panel: 30% of preview height, min 5 rows
		  // [TH] Properties panel: 30% ของความสูง preview, ขั้นต่ำ 5 แถว
		  Var propertiesPanel As New XjBox
		  Call propertiesPanel.SetHeight(XjConstraint.Percent(30).SetMin(5))
		  Call propertiesPanel.SetBorder(0, New XjStyle)
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
		  Call keysHint.SetText("/ Search  Up/Dn Nav  q Quit")
		  Call keysHint.SetWidth(XjConstraint.Fixed(30))
		  Call keysHint.SetAlign(XjText.ALIGN_RIGHT)
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
		  Case Else
		    Return ""
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleTick(tickCount As Integer)
		  // [EN] Called ~30fps. Drives render cycle and advances animated demo widgets.
		  // [TH] ถูกเรียก ~30fps ขับเคลื่อน render cycle และ advance demo widget ที่ animate
		  Select Case mDemoType
		  Case "spinner"
		    mDemoSpinnerWidget.HandleTick(tickCount)
		  Case "progressbar"
		    mDemoBar.HandleTick(tickCount)
		  End Select
		  Render()
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

		  // [EN] Highlight selected node
		  // [TH] ไฮไลต์ node ที่เลือก
		  Var invBase As New XjStyle
		  Var invStyle As XjStyle = invBase.SetInverse()
		  Call mFlatNodes(lineIdx).SetNodeStyle(invStyle)

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


	// [EN] mCanvas           — 2D character buffer sized to current terminal dimensions
	// [EN] mDemoBar          — XjProgressBar demo; activated by ActivateDemoWidget("progressbar")
	// [EN] mDemoInput        — XjTextInput demo; activated by ActivateDemoWidget("textinput")
	// [EN] mDemoKeyText      — XjText demo for XjKeyEvent; shows last key code/char
	// [EN] mDemoSpinnerWidget — XjSpinner demo; auto-advances via HandleTick
	// [EN] mDemoType         — active demo type key ("textinput"|"progressbar"|"spinner"|"keyevent"|"mockup"|"")
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
	// [EN] mStatusDesc       — XjText in status bar; shows ShortDesc or search feedback
	// [EN] mTermWidth/Height — current terminal dimensions, updated on every resize
	// [TH] mCanvas           — บัฟเฟอร์อักขระ 2D ตรงกับขนาด terminal ปัจจุบัน
	// [TH] mDemoBar          — demo XjProgressBar; เปิดด้วย ActivateDemoWidget("progressbar")
	// [TH] mDemoInput        — demo XjTextInput; เปิดด้วย ActivateDemoWidget("textinput")
	// [TH] mDemoKeyText      — demo XjText สำหรับ XjKeyEvent; แสดง key code/char ล่าสุด
	// [TH] mDemoSpinnerWidget — demo XjSpinner; auto-advance ผ่าน HandleTick
	// [TH] mDemoType         — demo type ที่ active ("textinput"|"progressbar"|"spinner"|"keyevent"|"mockup"|"")
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
		Private mDemoType As String
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
