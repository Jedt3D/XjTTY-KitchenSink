#tag Class
// [EN] KSComponentEntry — metadata record for one component in the Kitchen Sink registry.
//      All fields are public; the registry is the only writer. Consumers read-only.
// [TH] KSComponentEntry — ข้อมูล metadata สำหรับ component หนึ่งรายการใน Kitchen Sink registry
//      ทุก field เป็น public; มีเพียง registry เท่านั้นที่เขียนข้อมูล ผู้ใช้งานอ่านอย่างเดียว
Protected Class KSComponentEntry
	#tag Method, Flags = &h0
		Sub Constructor(aName As String, aCategory As String, aShortDesc As String, aLongDesc As String, aKeywords As String, aIsInteractive As Boolean)
		  // [EN] Populate every field in one call — used exclusively by KSComponentRegistry.Init.
		  // [TH] กำหนดทุก field ในการเรียกครั้งเดียว — ใช้เฉพาะใน KSComponentRegistry.Init
		  Name = aName
		  Category = aCategory
		  ShortDesc = aShortDesc
		  LongDesc = aLongDesc
		  Keywords = aKeywords
		  IsInteractive = aIsInteractive
		End Sub
	#tag EndMethod


	// [EN] Category  — one of: Layout | Widgets | Prompts | Style | I/O | Utility
	// [TH] Category  — หนึ่งใน: Layout | Widgets | Prompts | Style | I/O | Utility
	#tag Property, Flags = &h0
		Category As String
	#tag EndProperty

	// [EN] IsInteractive — True if the component accepts live key input (Phase 5 routing).
	// [TH] IsInteractive — True ถ้า component รับ key input แบบ live (Phase 5 routing)
	#tag Property, Flags = &h0
		IsInteractive As Boolean
	#tag EndProperty

	// [EN] Keywords — space-separated search terms (Phase 3 XjCompleter).
	// [TH] Keywords — คำค้นหาคั่นด้วยช่องว่าง (Phase 3 XjCompleter)
	#tag Property, Flags = &h0
		Keywords As String
	#tag EndProperty

	// [EN] LongDesc — multi-sentence description shown in Properties panel (Phase 4).
	// [TH] LongDesc — คำอธิบายหลายประโยค แสดงใน Properties panel (Phase 4)
	#tag Property, Flags = &h0
		LongDesc As String
	#tag EndProperty

	// [EN] Name — canonical Xojo class/module name, e.g. "XjBox".
	// [TH] Name — ชื่อ class/module ใน Xojo เช่น "XjBox"
	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	// [EN] ShortDesc — one-line summary shown in the status bar on selection.
	// [TH] ShortDesc — สรุปหนึ่งบรรทัด แสดงใน status bar เมื่อเลือก
	#tag Property, Flags = &h0
		ShortDesc As String
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
