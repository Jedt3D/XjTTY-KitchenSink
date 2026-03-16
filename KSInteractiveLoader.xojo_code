#tag Module
// [EN] KSInteractiveLoader — determines which live demo widget corresponds to a
//      component entry and configures it. Returns a "demo type" key that KSApp
//      uses to route keys and drive ticks to the correct pre-built widget.
//      Demo types: "textinput" | "progressbar" | "spinner" | "keyevent" | "text" | "table" | "tree" | "mockup" | ""
// [TH] KSInteractiveLoader — กำหนด demo widget ที่ใช้สำหรับ component entry
//      และกำหนดค่าเริ่มต้น คืนค่า "demo type" เพื่อให้ KSApp ส่ง key และ tick
//      ไปยัง widget ที่สร้างไว้ล่วงหน้าอย่างถูกต้อง
Protected Module KSInteractiveLoader
	#tag Method, Flags = &h0
		Function DemoTypeFor(entry As KSComponentEntry) As String
		  // [EN] Map a component entry to its demo type.
		  //      Interactive toolkit widgets get a live demo.
		  //      Prompt classes are blocking/modal — they get a styled mockup.
		  //      Non-interactive entries return "".
		  // [TH] แมป entry ไปยัง demo type
		  //      widget ที่ interactive ได้ live demo จริง
		  //      Prompt class เป็น blocking/modal — แสดง mockup แทน
		  //      entry ที่ไม่ interactive คืนค่า ""
		  Select Case entry.Name
		  Case "XjTextInput"
		    Return "textinput"
		  Case "XjProgressBar"
		    Return "progressbar"
		  Case "XjSpinner"
		    Return "spinner"
		  Case "XjKeyEvent"
		    Return "keyevent"
		  Case "XjText"
		    // [EN] Batch 1: text alignment/wrap demo using pre-built XjText widget
		    // [TH] Batch 1: demo จัดตำแหน่ง/ตัดคำ ใช้ XjText ที่สร้างไว้ล่วงหน้า
		    Return "text"
		  Case "XjTable"
		    // [EN] Batch 1: table border/header toggle demo using pre-built XjTable
		    // [TH] Batch 1: demo สลับ border/header ใช้ XjTable ที่สร้างไว้ล่วงหน้า
		    Return "table"
		  Case "XjTree"
		    // [EN] Batch 1: tree navigation demo using pre-built XjTree
		    // [TH] Batch 1: demo navigation tree ใช้ XjTree ที่สร้างไว้ล่วงหน้า
		    Return "tree"
		  Case Else
		    // [EN] Prompts and all other IsInteractive entries: show a mockup
		    // [TH] Prompt และ entry IsInteractive อื่นๆ: แสดง mockup
		    If entry.IsInteractive Then Return "mockup"
		    Return ""
		  End Select
		End Function
	#tag EndMethod


	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule
