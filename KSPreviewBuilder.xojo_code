#tag Module
// [EN] KSPreviewBuilder — stateless factory that populates the three preview widgets
//      whenever the user selects a component in the list. Phase 4 delivers static
//      text-based previews; Phase 5 will extend this with live interactive widgets.
// [TH] KSPreviewBuilder — factory ไม่มี state ที่ป้อนข้อมูลใน widget preview ทั้งสาม
//      เมื่อผู้ใช้เลือก component ใน list Phase 4 ให้ preview แบบ text คงที่
//      Phase 5 จะขยายด้วย widget แบบ interactive
Protected Module KSPreviewBuilder
	#tag Method, Flags = &h0
		Sub LoadInto(entry As KSComponentEntry, titleText As XjText, bodyText As XjText, propsTable As XjTable)
		  // [EN] Populate all three preview widgets from a single KSComponentEntry.
		  //      titleText  — one-line header: Name + [Category] badge
		  //      bodyText   — word-wrapped long description, keywords, interactive note
		  //      propsTable — 2-column property sheet (Property | Value)
		  // [TH] ป้อนข้อมูล widget preview ทั้งสามจาก KSComponentEntry เดียว
		  //      titleText  — header หนึ่งบรรทัด: ชื่อ + badge [Category]
		  //      bodyText   — คำอธิบายยาวตัดคำ, keywords, หมายเหตุ interactive
		  //      propsTable — ตาราง property 2 คอลัมน์ (Property | Value)

		  // [EN] Title line: "ComponentName  [Category]"
		  // [TH] บรรทัด title: "ชื่อ Component  [Category]"
		  Call titleText.SetText(entry.Name + "  [" + entry.Category + "]")

		  // [EN] Body: long description, keyword list, optional interactive notice
		  // [TH] Body: คำอธิบายยาว, รายการ keyword, หมายเหตุ interactive (ถ้ามี)
		  Var body As String = entry.LongDesc
		  body = body + Chr(10) + Chr(10)
		  body = body + "Keywords: " + entry.Keywords
		  If entry.IsInteractive Then
		    body = body + Chr(10) + Chr(10)
		    body = body + "[ Interactive ] Press Tab to enter the live demo panel."
		  Else
		    // [EN] Batch 5: red "Non-Interactive" label for non-demo components
		    // [TH] Batch 5: ป้ายกำกับ "Non-Interactive" สีแดง สำหรับ component ที่ไม่มี demo
		    body = body + Chr(10) + Chr(10)
		    Var redBase As New XjStyle
		    Var redBg As XjStyle = redBase.SetBG(XjANSI.BG_RED)
		    Var redLabel As XjStyle = redBg.SetFG(XjANSI.FG_WHITE)
		    body = body + redLabel.Apply(" Non-Interactive Component ")
		  End If
		  Call bodyText.SetText(body)

		  // [EN] Properties table: clear old rows, add fresh data rows
		  // [TH] ตาราง properties: ล้างแถวเก่า เพิ่มแถวข้อมูลใหม่
		  propsTable.ClearRows()

		  Var r1() As String
		  r1.Add("Name")
		  r1.Add(entry.Name)
		  propsTable.AddRow(r1)

		  Var r2() As String
		  r2.Add("Category")
		  r2.Add(entry.Category)
		  propsTable.AddRow(r2)

		  Var r3() As String
		  r3.Add("Interactive")
		  If entry.IsInteractive Then
		    r3.Add("Yes (Tab for demo)")
		  Else
		    r3.Add("No")
		  End If
		  propsTable.AddRow(r3)

		  Var r4() As String
		  r4.Add("Keywords")
		  // [EN] Truncate keywords to fit the table cell width
		  // [TH] ตัด keywords ให้พอดีกับความกว้างของ cell ในตาราง
		  Var kw As String = entry.Keywords
		  If kw.Length > 40 Then kw = kw.Left(39) + Chr(&h2026)
		  r4.Add(kw)
		  propsTable.AddRow(r4)

		  // [EN] Batch 5: add live property rows for infrastructure components
		  // [TH] Batch 5: เพิ่มแถว property แบบ live สำหรับ component โครงสร้างพื้นฐาน
		  AddLiveRows(entry, propsTable)
		End Sub
	#tag EndMethod


	#tag Method, Flags = &h21
		Private Sub AddLiveRows(entry As KSComponentEntry, propsTable As XjTable)
		  // [EN] Batch 5: append extra property rows for infrastructure components.
		  //      XjTerminal  — live terminal Width x Height
		  //      XjEventLoop — configured tick rate and approx FPS
		  //      XjReader    — key decoding note
		  //      Layout      — self-referential usage note
		  // [TH] Batch 5: เพิ่มแถว property พิเศษสำหรับ component โครงสร้างพื้นฐาน
		  //      XjTerminal  — ขนาด terminal Width x Height แบบ live
		  //      XjEventLoop — tick rate และ FPS โดยประมาณ
		  //      XjReader    — หมายเหตุ key decoding
		  //      Layout      — หมายเหตุการใช้งานแบบ self-referential
		  Select Case entry.Name
		  Case "XjTerminal"
		    AddTerminalRows(propsTable)
		  Case "XjEventLoop"
		    AddEventLoopRows(propsTable)
		  Case "XjReader"
		    AddReaderRows(propsTable)
		  Case "XjBox"
		    AddBoxRows(propsTable)
		  Case "XjLayoutSolver"
		    AddSolverRows(propsTable)
		  Case "XjConstraint"
		    AddConstraintRows(propsTable)
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddTerminalRows(propsTable As XjTable)
		  // [EN] Show terminal API info (static text — avoid calling XjTerminal.Width/Height
		  //      directly as POSIX ioctl triggers Tahoe xzone malloc crash)
		  // [TH] แสดงข้อมูล API ของ terminal (ข้อความคงที่ — หลีกเลี่ยงเรียก XjTerminal.Width/Height
		  //      โดยตรงเพราะ POSIX ioctl ทำให้เกิด Tahoe xzone malloc crash)
		  Var rAPI() As String
		  rAPI.Add("Provides")
		  rAPI.Add("Width(), Height(), Write()")
		  propsTable.AddRow(rAPI)

		  Var rMode() As String
		  rMode.Add("Raw Mode")
		  rMode.Add("Enabled (by XjEventLoop)")
		  propsTable.AddRow(rMode)

		  Var rResize() As String
		  rResize.Add("Resize")
		  rResize.Add("SIGWINCH -> GetSize()")
		  propsTable.AddRow(rResize)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddEventLoopRows(propsTable As XjTable)
		  // [EN] Show event loop configuration
		  // [TH] แสดงการตั้งค่า event loop
		  Var rTick() As String
		  rTick.Add("Tick Rate")
		  rTick.Add("33ms (~30 fps)")
		  propsTable.AddRow(rTick)

		  Var rScreen() As String
		  rScreen.Add("Alt Screen")
		  rScreen.Add("Enabled")
		  propsTable.AddRow(rScreen)

		  Var rCursor() As String
		  rCursor.Add("Cursor")
		  rCursor.Add("Hidden")
		  propsTable.AddRow(rCursor)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddReaderRows(propsTable As XjTable)
		  // [EN] Show key decoding info
		  // [TH] แสดงข้อมูล key decoding
		  Var rDecode() As String
		  rDecode.Add("Decodes")
		  rDecode.Add("Arrow, Fn, UTF-8, Ctrl")
		  propsTable.AddRow(rDecode)

		  Var rNote() As String
		  rNote.Add("Status")
		  rNote.Add("Parsing your keys now")
		  propsTable.AddRow(rNote)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddBoxRows(propsTable As XjTable)
		  // [EN] Self-referential usage note for XjBox
		  // [TH] หมายเหตุการใช้งานแบบ self-referential สำหรับ XjBox
		  Var rDir() As String
		  rDir.Add("Root Dir")
		  rDir.Add("DIR_COLUMN (vertical)")
		  propsTable.AddRow(rDir)

		  Var rMain() As String
		  rMain.Add("Main Dir")
		  rMain.Add("DIR_ROW (side by side)")
		  propsTable.AddRow(rMain)

		  Var rPanels() As String
		  rPanels.Add("Panels")
		  rPanels.Add("4 (hdr/search/main/bar)")
		  propsTable.AddRow(rPanels)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddSolverRows(propsTable As XjTable)
		  // [EN] Solver run info
		  // [TH] ข้อมูลการทำงาน solver
		  Var rRate() As String
		  rRate.Add("Solve Rate")
		  rRate.Add("~30x per second")
		  propsTable.AddRow(rRate)

		  Var rDir() As String
		  rDir.Add("Traversal")
		  rDir.Add("Top-down, depth-first")
		  propsTable.AddRow(rDir)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddConstraintRows(propsTable As XjTable)
		  // [EN] Show constraint types used in this app
		  // [TH] แสดงประเภท constraint ที่ใช้ในแอปนี้
		  Var rHeader() As String
		  rHeader.Add("Header")
		  rHeader.Add("Fixed(3)")
		  propsTable.AddRow(rHeader)

		  Var rSearch() As String
		  rSearch.Add("Search Bar")
		  rSearch.Add("Fixed(3)")
		  propsTable.AddRow(rSearch)

		  Var rStatus() As String
		  rStatus.Add("Status Bar")
		  rStatus.Add("Fixed(1)")
		  propsTable.AddRow(rStatus)

		  Var rList() As String
		  rList.Add("Comp List")
		  rList.Add("Percent(25)")
		  propsTable.AddRow(rList)

		  Var rPreview() As String
		  rPreview.Add("Preview")
		  rPreview.Add("Auto (fills rest)")
		  propsTable.AddRow(rPreview)
		End Sub
	#tag EndMethod


	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule
