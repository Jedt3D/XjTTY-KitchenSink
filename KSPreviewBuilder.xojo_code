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
		    body = body + "[ Interactive ] Phase 5 will wire live keyboard input to this component."
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
		    r3.Add("Yes (Phase 5)")
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
		End Sub
	#tag EndMethod


	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule
