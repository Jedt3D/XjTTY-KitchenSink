#tag Module
Protected Module XjScreen
	#tag Method, Flags = &h0
		Sub Clear()
		  // Clear entire screen and move cursor to top-left
		  XjTerminal.Write(XjANSI.EraseScreen + XjANSI.CursorPosition(1, 1))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearLine()
		  // Clear the entire current line
		  XjTerminal.Write(XjANSI.EraseLine)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearToEnd()
		  // Clear from cursor to end of line
		  XjTerminal.Write(XjANSI.EraseToEndOfLine)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearToStart()
		  // Clear from cursor to start of line
		  XjTerminal.Write(XjANSI.EraseToStartOfLine)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearBelow()
		  // Clear from cursor to end of screen
		  XjTerminal.Write(XjANSI.EraseDown)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearAbove()
		  // Clear from cursor to start of screen
		  XjTerminal.Write(XjANSI.EraseUp)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearLines(count As Integer)
		  // Clear a number of lines starting from current cursor position (moving up)
		  Var parts() As String
		  For i As Integer = 0 To count - 1
		    parts.Add(XjANSI.EraseLine)
		    If i < count - 1 Then
		      parts.Add(XjANSI.CursorUp(1))
		    End If
		  Next
		  XjTerminal.Write(String.FromArray(parts, ""))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ScrollUp(n As Integer)
		  // Scroll content up by n lines (new blank lines at bottom)
		  If n > 0 Then XjTerminal.Write(XjANSI.ScrollUp(n))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ScrollDown(n As Integer)
		  // Scroll content down by n lines (new blank lines at top)
		  If n > 0 Then XjTerminal.Write(XjANSI.ScrollDown(n))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Width() As Integer
		  Return XjTerminal.Width
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Height() As Integer
		  Return XjTerminal.Height
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetTitle(title As String)
		  // Set terminal window title
		  XjTerminal.Write(XjANSI.SetTitle(title))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnterFullscreen()
		  // Enter fullscreen mode: alternate screen + hide cursor + clear
		  XjTerminal.EnterAlternateScreen
		  XjCursor.Hide
		  Clear
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExitFullscreen()
		  // Exit fullscreen mode: show cursor + restore main screen
		  XjCursor.Show
		  XjTerminal.ExitAlternateScreen
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteAt(row As Integer, col As Integer, text As String)
		  // Write text at a specific position without moving cursor permanently
		  XjCursor.Save
		  XjCursor.MoveTo(row, col)
		  XjTerminal.Write(text)
		  XjCursor.Restore
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawHorizontalLine(row As Integer, col As Integer, length As Integer, char As String)
		  // Draw a horizontal line of repeated characters
		  If char = "" Then char = "-"
		  Var ch As String = char.Left(1)
		  Var lineParts() As String
		  For i As Integer = 1 To length
		    lineParts.Add(ch)
		  Next
		  Var line As String = String.FromArray(lineParts, "")
		  XjCursor.Save
		  XjCursor.MoveTo(row, col)
		  XjTerminal.Write(line)
		  XjCursor.Restore
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawVerticalLine(row As Integer, col As Integer, length As Integer, char As String)
		  // Draw a vertical line of repeated characters
		  If char = "" Then char = "|"
		  Var ch As String = char.Left(1)
		  Var parts() As String
		  XjCursor.Save
		  For i As Integer = 0 To length - 1
		    parts.Add(XjANSI.CursorPosition(row + i, col) + ch)
		  Next
		  XjTerminal.Write(String.FromArray(parts, ""))
		  XjCursor.Restore
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FillRect(row As Integer, col As Integer, width As Integer, height As Integer, char As String)
		  // Fill a rectangular area with a character
		  If char = "" Then char = " "
		  Var ch As String = char.Left(1)
		  Var lineParts() As String
		  For i As Integer = 1 To width
		    lineParts.Add(ch)
		  Next
		  Var line As String = String.FromArray(lineParts, "")
		  Var parts() As String
		  XjCursor.Save
		  For r As Integer = 0 To height - 1
		    parts.Add(XjANSI.CursorPosition(row + r, col) + line)
		  Next
		  XjTerminal.Write(String.FromArray(parts, ""))
		  XjCursor.Restore
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjScreen — Screen Management

		Part of XjTTY-Toolkit foundation layer.
		Provides screen-level operations:

		- Clearing: Clear, ClearLine, ClearToEnd, ClearAbove/Below
		- Scrolling: ScrollUp, ScrollDown
		- Dimensions: Width, Height
		- Fullscreen: EnterFullscreen, ExitFullscreen
		- Drawing: WriteAt, DrawHorizontalLine, DrawVerticalLine, FillRect
		- Title: SetTitle
	#tag EndNote


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
