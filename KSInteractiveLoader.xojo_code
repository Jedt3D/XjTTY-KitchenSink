#tag Module
// [EN] KSInteractiveLoader — determines which live demo widget corresponds to a
//      component entry and configures it. Returns a "demo type" key that KSApp
//      uses to route keys and drive ticks to the correct pre-built widget.
//      Demo types: "textinput" | "progressbar" | "spinner" | "keyevent" | "text" | "table" | "tree"
//                | "pie" | "style" | "color" | "canvas"
//                | "confirm" | "keypress" | "expand" | "ask" | "enum"
//                | "select" | "multiselect" | "suggest" | "collect"
//                | "mockup" | ""
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
		  Case "XjPie"
		    // [EN] Batch 2: pie chart overlay demo
		    // [TH] Batch 2: demo overlay pie chart
		    Return "pie"
		  Case "XjStyle"
		    // [EN] Batch 2: style showcase overlay demo
		    // [TH] Batch 2: demo overlay แสดง style
		    Return "style"
		  Case "XjColor"
		    // [EN] Batch 2: color palette overlay demo
		    // [TH] Batch 2: demo overlay palette สี
		    Return "color"
		  Case "XjCanvas"
		    // [EN] Batch 2: canvas concept overlay demo
		    // [TH] Batch 2: demo overlay แนวคิด canvas
		    Return "canvas"
		  Case "XjConfirmPrompt"
		    // [EN] Batch 3: confirm prompt overlay mockup
		    // [TH] Batch 3: demo overlay mockup confirm prompt
		    Return "confirm"
		  Case "XjKeyPressPrompt"
		    // [EN] Batch 3: keypress prompt overlay mockup
		    // [TH] Batch 3: demo overlay mockup keypress prompt
		    Return "keypress"
		  Case "XjExpandPrompt"
		    // [EN] Batch 3: expand prompt overlay mockup
		    // [TH] Batch 3: demo overlay mockup expand prompt
		    Return "expand"
		  Case "XjAskPrompt"
		    // [EN] Batch 3: ask prompt overlay mockup
		    // [TH] Batch 3: demo overlay mockup ask prompt
		    Return "ask"
		  Case "XjEnumSelectPrompt"
		    // [EN] Batch 3: enum select prompt overlay mockup
		    // [TH] Batch 3: demo overlay mockup enum select prompt
		    Return "enum"
		  Case "XjSelectPrompt"
		    // [EN] Batch 4: select prompt overlay mockup (arrow list)
		    // [TH] Batch 4: demo overlay mockup select prompt (รายการลูกศร)
		    Return "select"
		  Case "XjMultiSelectPrompt"
		    // [EN] Batch 4: multi-select prompt overlay mockup (checkbox list)
		    // [TH] Batch 4: demo overlay mockup multi-select prompt (รายการ checkbox)
		    Return "multiselect"
		  Case "XjSuggestPrompt"
		    // [EN] Batch 4: suggest prompt overlay mockup (autocomplete)
		    // [TH] Batch 4: demo overlay mockup suggest prompt (autocomplete)
		    Return "suggest"
		  Case "XjCollectPrompt"
		    // [EN] Batch 4: collect prompt overlay mockup (multi-step wizard)
		    // [TH] Batch 4: demo overlay mockup collect prompt (wizard หลายขั้นตอน)
		    Return "collect"
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
