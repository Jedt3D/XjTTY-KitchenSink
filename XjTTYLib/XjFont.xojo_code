#tag Module
Protected Module XjFont
	#tag Method, Flags = &h0
		Function Render(text As String, style As XjStyle = Nil) As String()
		  EnsureInit

		  Var upper As String = text.Uppercase
		  Var rows() As String
		  rows.Add("")
		  rows.Add("")
		  rows.Add("")
		  rows.Add("")
		  rows.Add("")

		  // Use parallel arrays to avoid O(n^2) string concat
		  Var rp0() As String
		  Var rp1() As String
		  Var rp2() As String
		  Var rp3() As String
		  Var rp4() As String

		  For pos As Integer = 0 To upper.Length - 1
		    Var ch As String = upper.Middle(pos, 1)
		    Var glyph() As String

		    If mGlyphs.HasKey(ch) Then
		      glyph = mGlyphs.Value(ch)
		    Else
		      // Unknown character — render as space
		      glyph = mGlyphs.Value(" ")
		    End If

		    rp0.Add(glyph(0).ReplaceAll("#", mBlock) + " ")
		    rp1.Add(glyph(1).ReplaceAll("#", mBlock) + " ")
		    rp2.Add(glyph(2).ReplaceAll("#", mBlock) + " ")
		    rp3.Add(glyph(3).ReplaceAll("#", mBlock) + " ")
		    rp4.Add(glyph(4).ReplaceAll("#", mBlock) + " ")
		  Next

		  rows(0) = String.FromArray(rp0, "")
		  rows(1) = String.FromArray(rp1, "")
		  rows(2) = String.FromArray(rp2, "")
		  rows(3) = String.FromArray(rp3, "")
		  rows(4) = String.FromArray(rp4, "")

		  // Apply style if provided
		  If style <> Nil Then
		    For i As Integer = 0 To rows.Count - 1
		      rows(i) = style.Apply(rows(i))
		    Next
		  End If

		  Return rows
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureInit()
		  If mInitialized Then Return
		  mInitialized = True

		  mBlock = Chr(&hE2) + Chr(&h96) + Chr(&h88)
		  mGlyphs = New Dictionary

		  DG(" ", "     |     |     |     |     ")
		  DG("A", " ### |#   #|#####|#   #|#   #")
		  DG("B", "#### |#   #|#### |#   #|#### ")
		  DG("C", " ####|#    |#    |#    | ####")
		  DG("D", "#### |#   #|#   #|#   #|#### ")
		  DG("E", "#####|#    |#### |#    |#####")
		  DG("F", "#####|#    |#### |#    |#    ")
		  DG("G", " ####|#    |# ###|#   #| ### ")
		  DG("H", "#   #|#   #|#####|#   #|#   #")
		  DG("I", "#####|  #  |  #  |  #  |#####")
		  DG("J", "#####|    #|    #|#   #| ### ")
		  DG("K", "#   #|#  # |###  |#  # |#   #")
		  DG("L", "#    |#    |#    |#    |#####")
		  DG("M", "#   #|## ##|# # #|#   #|#   #")
		  DG("N", "#   #|##  #|# # #|#  ##|#   #")
		  DG("O", " ### |#   #|#   #|#   #| ### ")
		  DG("P", "#### |#   #|#### |#    |#    ")
		  DG("Q", " ### |#   #|# # #|#  # | ## #")
		  DG("R", "#### |#   #|#### |#  # |#   #")
		  DG("S", " ####|#    | ### |    #|#### ")
		  DG("T", "#####|  #  |  #  |  #  |  #  ")
		  DG("U", "#   #|#   #|#   #|#   #| ### ")
		  DG("V", "#   #|#   #|#   #| # # |  #  ")
		  DG("W", "#   #|#   #|# # #|## ##|#   #")
		  DG("X", "#   #| # # |  #  | # # |#   #")
		  DG("Y", "#   #| # # |  #  |  #  |  #  ")
		  DG("Z", "#####|   # |  #  | #   |#####")
		  DG("0", " ### |#   #|#   #|#   #| ### ")
		  DG("1", "  #  | ##  |  #  |  #  |#####")
		  DG("2", " ### |#   #|  ## | #   |#####")
		  DG("3", "#### |    #| ### |    #|#### ")
		  DG("4", "#  # |#  # |#####|   # |   # ")
		  DG("5", "#####|#    |#### |    #|#### ")
		  DG("6", " ### |#    |#### |#   #| ### ")
		  DG("7", "#####|   # |  #  | #   |#    ")
		  DG("8", " ### |#   #| ### |#   #| ### ")
		  DG("9", " ### |#   #| ####|    #| ### ")
		  DG("!", "  #  |  #  |  #  |     |  #  ")
		  DG(".", "     |     |     |     |  #  ")
		  DG("-", "     |     |#####|     |     ")
		  DG(":", "     |  #  |     |  #  |     ")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DG(ch As String, data As String)
		  Var rows() As String = data.Split("|")
		  mGlyphs.Value(ch) = rows
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjFont — ASCII Art Text

		Part of XjTTY-Toolkit Phase 5 (Utility Modules).
		Render large block-character text using a 5x5 pixel font.

		Usage:
		  Var lines() As String = XjFont.Render("HELLO")
		  For Each line As String In lines
		    Print(line)
		  Next

		  // With color:
		  Var s As New XjStyle
		  Call s.SetFG(XjANSI.FG_CYAN)
		  Var lines() As String = XjFont.Render("HELLO", s)
	#tag EndNote

	#tag Property, Flags = &h21
		Private mInitialized As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mGlyphs As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBlock As String
	#tag EndProperty

End Module
#tag EndModule
