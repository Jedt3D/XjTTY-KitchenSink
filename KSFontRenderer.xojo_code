#tag Module
// [EN] KSFontRenderer — Local block-art text renderer that bypasses XjFont.Render()
//      to avoid macOS Tahoe xzone malloc crash from XjFont's dictionary initialization.
//      Glyph lookup is split across 4 small methods to keep method bodies under Tahoe threshold.
// [TH] KSFontRenderer — ตัว render block-art ในตัวที่ข้าม XjFont.Render()
//      เพื่อหลีกเลี่ยง Tahoe xzone malloc crash จากการสร้าง Dictionary ของ XjFont
//      แยก glyph lookup เป็น 4 method เล็กเพื่อให้ method body อยู่ใต้ขีดจำกัด Tahoe
Protected Module KSFontRenderer
	#tag Method, Flags = &h21
		Private Function GlyphAJ(ch As String) As String
		  // [EN] Glyph patterns A-J. Each is 5 rows separated by |, using # for filled pixels.
		  // [TH] Pattern glyph A-J แต่ละตัว 5 แถวคั่นด้วย | ใช้ # แทนจุดที่เติม
		  Select Case ch
		  Case "A"
		    Return " ### |#   #|#####|#   #|#   #"
		  Case "B"
		    Return "#### |#   #|#### |#   #|#### "
		  Case "C"
		    Return " ####|#    |#    |#    | ####"
		  Case "D"
		    Return "#### |#   #|#   #|#   #|#### "
		  Case "E"
		    Return "#####|#    |#### |#    |#####"
		  Case "F"
		    Return "#####|#    |#### |#    |#    "
		  Case "G"
		    Return " ####|#    |# ###|#   #| ### "
		  Case "H"
		    Return "#   #|#   #|#####|#   #|#   #"
		  Case "I"
		    Return "#####|  #  |  #  |  #  |#####"
		  Case "J"
		    Return "#####|    #|    #|#   #| ### "
		  Case Else
		    Return ""
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GlyphKT(ch As String) As String
		  // [EN] Glyph patterns K-T.
		  // [TH] Pattern glyph K-T
		  Select Case ch
		  Case "K"
		    Return "#   #|#  # |###  |#  # |#   #"
		  Case "L"
		    Return "#    |#    |#    |#    |#####"
		  Case "M"
		    Return "#   #|## ##|# # #|#   #|#   #"
		  Case "N"
		    Return "#   #|##  #|# # #|#  ##|#   #"
		  Case "O"
		    Return " ### |#   #|#   #|#   #| ### "
		  Case "P"
		    Return "#### |#   #|#### |#    |#    "
		  Case "Q"
		    Return " ### |#   #|# # #|#  # | ## #"
		  Case "R"
		    Return "#### |#   #|#### |#  # |#   #"
		  Case "S"
		    Return " ####|#    | ### |    #|#### "
		  Case "T"
		    Return "#####|  #  |  #  |  #  |  #  "
		  Case Else
		    Return ""
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GlyphUZ(ch As String) As String
		  // [EN] Glyph patterns U-Z + space.
		  // [TH] Pattern glyph U-Z + เว้นวรรค
		  Select Case ch
		  Case "U"
		    Return "#   #|#   #|#   #|#   #| ### "
		  Case "V"
		    Return "#   #|#   #|#   #| # # |  #  "
		  Case "W"
		    Return "#   #|#   #|# # #|## ##|#   #"
		  Case "X"
		    Return "#   #| # # |  #  | # # |#   #"
		  Case "Y"
		    Return "#   #| # # |  #  |  #  |  #  "
		  Case "Z"
		    Return "#####|   # |  #  | #   |#####"
		  Case " "
		    Return "     |     |     |     |     "
		  Case Else
		    Return ""
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GlyphNum(ch As String) As String
		  // [EN] Glyph patterns 0-9 and punctuation.
		  // [TH] Pattern glyph 0-9 และเครื่องหมายวรรคตอน
		  Select Case ch
		  Case "0"
		    Return " ### |#   #|#   #|#   #| ### "
		  Case "1"
		    Return "  #  | ##  |  #  |  #  |#####"
		  Case "2"
		    Return " ### |#   #|  ## | #   |#####"
		  Case "3"
		    Return "#### |    #| ### |    #|#### "
		  Case "4"
		    Return "#  # |#  # |#####|   # |   # "
		  Case "5"
		    Return "#####|#    |#### |    #|#### "
		  Case "6"
		    Return " ### |#    |#### |#   #| ### "
		  Case "7"
		    Return "#####|   # |  #  | #   |#    "
		  Case "8"
		    Return " ### |#   #| ### |#   #| ### "
		  Case "9"
		    Return " ### |#   #| ####|    #| ### "
		  Case "!"
		    Return "  #  |  #  |  #  |     |  #  "
		  Case "."
		    Return "     |     |     |     |  #  "
		  Case "-"
		    Return "     |     |#####|     |     "
		  Case ":"
		    Return "     |  #  |     |  #  |     "
		  Case Else
		    Return "     |     |     |     |     "
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetGlyph(ch As String) As String
		  // [EN] Dispatch to the correct small glyph method based on character.
		  // [TH] ส่งต่อไปยัง method glyph ที่ถูกต้องตามตัวอักษร
		  Var u As String = ch.Uppercase
		  Var result As String
		  result = GlyphAJ(u)
		  If result <> "" Then Return result
		  result = GlyphKT(u)
		  If result <> "" Then Return result
		  result = GlyphUZ(u)
		  If result <> "" Then Return result
		  Return GlyphNum(u)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RenderText(text As String) As String()
		  // [EN] Render block-art text locally. Returns 5 rows of block characters.
		  //      Max 8 chars to fit overlay width. Replaces # with full-block Unicode.
		  // [TH] Render block-art ในตัว คืน 5 แถว block character
		  //      จำกัด 8 ตัวอักษร แทนที่ # ด้วย full-block Unicode
		  Var b As String = Chr(&h2588)
		  Var rows() As String
		  rows.Add("")
		  rows.Add("")
		  rows.Add("")
		  rows.Add("")
		  rows.Add("")
		  Var maxLen As Integer = text.Length
		  If maxLen > 8 Then maxLen = 8
		  For pos As Integer = 0 To maxLen - 1
		    Var ch As String = text.Middle(pos, 1)
		    Var glyph As String = GetGlyph(ch)
		    Var parts() As String = glyph.Split("|")
		    For row As Integer = 0 To 4
		      Var rendered As String = parts(row).ReplaceAll("#", b)
		      rows(row) = rows(row) + rendered + " "
		    Next row
		  Next pos
		  Return rows
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BuildOverlay(input As String) As String()
		  // [EN] Build the font demo overlay lines. Title, rendered block art, input display.
		  // [TH] สร้าง overlay lines ของ demo font: ชื่อ, block art, แสดง input
		  Var lines() As String
		  Var base As New XjStyle
		  Var cyanFG As XjStyle = base.SetFG(XjANSI.FG_CYAN)
		  Var cyanBold As XjStyle = cyanFG.SetBold()
		  Var dimBase As New XjStyle
		  Var dimFG As XjStyle = dimBase.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  lines.Add(cyanBold.Apply("XjFont — Block-Art Text"))
		  lines.Add("")
		  Var rendered() As String = RenderText(input)
		  For i As Integer = 0 To rendered.LastIndex
		    lines.Add(cyanFG.Apply(rendered(i)))
		  Next i
		  lines.Add("")
		  Var cursorBar As String = Chr(&h2588)
		  lines.Add(dimFG.Apply("Text: ") + input + cursorBar)
		  lines.Add(dimFG.Apply("Type A-Z, 0-9 (max 8). Bksp del."))
		  Return lines
		End Function
	#tag EndMethod


	#tag ViewBehavior
	#tag EndViewBehavior
End Module
#tag EndModule
