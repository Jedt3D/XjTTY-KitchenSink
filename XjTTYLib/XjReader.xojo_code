#tag Class
Protected Class XjReader
	#tag Method, Flags = &h0
		Sub Constructor()
		  // Reader must be used after XjTerminal.EnableRawMode
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReadKey() As XjKeyEvent
		  // Read a single key event from stdin
		  // Returns Nil if no key available (non-blocking mode)
		  // Blocks if terminal is in blocking raw mode

		  Var b As Integer = XjTerminal.ReadByte
		  If b < 0 Then Return Nil

		  // Handle single-byte keys
		  Select Case b
		  Case 13, 10
		    // Enter (CR on macOS/Windows, LF on Linux)
		    Return New XjKeyEvent(XjKeyEvent.KEY_ENTER, "", False, False, False)

		  Case 27
		    // ESC - could be standalone or start of escape sequence
		    Return ParseEscapeSequence

		  Case 9
		    // Tab
		    Return New XjKeyEvent(XjKeyEvent.KEY_TAB, "", False, False, False)

		  Case 127, 8
		    // Backspace (127 on macOS/Linux, 8 on some terminals)
		    Return New XjKeyEvent(XjKeyEvent.KEY_BACKSPACE, "", False, False, False)

		  Case 0
		    // Ctrl+Space or Ctrl+@
		    Return New XjKeyEvent(XjKeyEvent.KEY_CHAR, Chr(0), True, False, False)

		  Case 1 To 7, 11, 12, 14 To 26
		    // Ctrl+A through Ctrl+Z (excluding Tab=9, Enter=10/13, ESC=27)
		    Return New XjKeyEvent(XjKeyEvent.KEY_CHAR, Chr(b), True, False, False)

		  Case Else
		    // Regular character (possibly multi-byte UTF-8)
		    Var char As String = ReadUTF8Char(b)
		    Return New XjKeyEvent(XjKeyEvent.KEY_CHAR, char, False, False, False)
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseEscapeSequence() As XjKeyEvent
		  // Called after receiving ESC (27)
		  // Try to read the rest of the escape sequence

		  Var b As Integer = XjTerminal.ReadByte
		  If b < 0 Then
		    // Standalone ESC (timeout, no more bytes)
		    Return New XjKeyEvent(XjKeyEvent.KEY_ESCAPE, "", False, False, False)
		  End If

		  Select Case b
		  Case 91
		    // ESC [ — CSI sequence
		    Return ParseCSISequence

		  Case 79
		    // ESC O — SS3 sequence (F1-F4 on some terminals)
		    Return ParseSS3Sequence

		  Case Else
		    // ESC + char = Alt+char
		    If b >= 32 And b < 127 Then
		      Return New XjKeyEvent(XjKeyEvent.KEY_CHAR, Chr(b), False, True, False)
		    End If
		    Return New XjKeyEvent(XjKeyEvent.KEY_ESCAPE, "", False, False, False)
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseCSISequence() As XjKeyEvent
		  // Parse CSI (ESC [) sequence
		  // Formats:
		  //   ESC [ {letter}           — simple (arrows, etc.)
		  //   ESC [ {number} ~         — function keys
		  //   ESC [ 1 ; {mod} {letter} — modified arrows/keys
		  //   ESC [ {number} ; {mod} ~ — modified function keys

		  Var params() As String
		  Var currentParam As String

		  // Read until we get a letter (final byte, 64-126)
		  Do
		    Var b As Integer = XjTerminal.ReadByte
		    If b < 0 Then
		      // Timeout — return ESC
		      Return New XjKeyEvent(XjKeyEvent.KEY_ESCAPE, "", False, False, False)
		    End If

		    If b >= 64 And b <= 126 Then
		      // Final byte — this determines the key
		      If currentParam <> "" Then params.Add(currentParam)

		      Var modifier As Integer = 0
		      If params.Count >= 2 Then
		        modifier = Val(params(1)) - 1
		      End If

		      Var ctrl As Boolean = Bitwise.BitAnd(modifier, 4) <> 0
		      Var alt As Boolean = Bitwise.BitAnd(modifier, 2) <> 0
		      Var shift As Boolean = Bitwise.BitAnd(modifier, 1) <> 0

		      Select Case Chr(b)
		      Case "A"
		        Return New XjKeyEvent(XjKeyEvent.KEY_UP, "", ctrl, alt, shift)
		      Case "B"
		        Return New XjKeyEvent(XjKeyEvent.KEY_DOWN, "", ctrl, alt, shift)
		      Case "C"
		        Return New XjKeyEvent(XjKeyEvent.KEY_RIGHT, "", ctrl, alt, shift)
		      Case "D"
		        Return New XjKeyEvent(XjKeyEvent.KEY_LEFT, "", ctrl, alt, shift)
		      Case "H"
		        Return New XjKeyEvent(XjKeyEvent.KEY_HOME, "", ctrl, alt, shift)
		      Case "F"
		        Return New XjKeyEvent(XjKeyEvent.KEY_END_, "", ctrl, alt, shift)
		      Case "Z"
		        // Shift+Tab (backtab)
		        Return New XjKeyEvent(XjKeyEvent.KEY_BACKTAB, "", ctrl, alt, True)
		      Case "~"
		        // Tilde sequences: ESC [ {number} ~
		        Var num As Integer = 0
		        If params.Count >= 1 Then num = Val(params(0))

		        Select Case num
		        Case 1
		          Return New XjKeyEvent(XjKeyEvent.KEY_HOME, "", ctrl, alt, shift)
		        Case 2
		          Return New XjKeyEvent(XjKeyEvent.KEY_INSERT, "", ctrl, alt, shift)
		        Case 3
		          Return New XjKeyEvent(XjKeyEvent.KEY_DELETE, "", ctrl, alt, shift)
		        Case 4
		          Return New XjKeyEvent(XjKeyEvent.KEY_END_, "", ctrl, alt, shift)
		        Case 5
		          Return New XjKeyEvent(XjKeyEvent.KEY_PAGEUP, "", ctrl, alt, shift)
		        Case 6
		          Return New XjKeyEvent(XjKeyEvent.KEY_PAGEDOWN, "", ctrl, alt, shift)
		        Case 11, 12, 13, 14, 15
		          Return New XjKeyEvent(XjKeyEvent.KEY_F1 + (num - 11), "", ctrl, alt, shift)
		        Case 17, 18, 19, 20, 21
		          Return New XjKeyEvent(XjKeyEvent.KEY_F6 + (num - 17), "", ctrl, alt, shift)
		        Case 23, 24
		          Return New XjKeyEvent(XjKeyEvent.KEY_F11 + (num - 23), "", ctrl, alt, shift)
		        Case Else
		          Return New XjKeyEvent(XjKeyEvent.KEY_ESCAPE, "", False, False, False)
		        End Select

		      Case Else
		        Return New XjKeyEvent(XjKeyEvent.KEY_ESCAPE, "", False, False, False)
		      End Select

		    ElseIf b = 59 Then
		      // Semicolon separator
		      params.Add(currentParam)
		      currentParam = ""
		    Else
		      // Digit or other intermediate byte
		      currentParam = currentParam + Chr(b)
		    End If
		  Loop
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseSS3Sequence() As XjKeyEvent
		  // Parse SS3 (ESC O) sequence — typically F1-F4
		  Var b As Integer = XjTerminal.ReadByte
		  If b < 0 Then
		    // Alt+O
		    Return New XjKeyEvent(XjKeyEvent.KEY_CHAR, "O", False, True, False)
		  End If

		  Select Case Chr(b)
		  Case "P"
		    Return New XjKeyEvent(XjKeyEvent.KEY_F1, "", False, False, False)
		  Case "Q"
		    Return New XjKeyEvent(XjKeyEvent.KEY_F2, "", False, False, False)
		  Case "R"
		    Return New XjKeyEvent(XjKeyEvent.KEY_F3, "", False, False, False)
		  Case "S"
		    Return New XjKeyEvent(XjKeyEvent.KEY_F4, "", False, False, False)
		  Case "H"
		    Return New XjKeyEvent(XjKeyEvent.KEY_HOME, "", False, False, False)
		  Case "F"
		    Return New XjKeyEvent(XjKeyEvent.KEY_END_, "", False, False, False)
		  Case Else
		    Return New XjKeyEvent(XjKeyEvent.KEY_CHAR, Chr(b), False, True, False)
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReadUTF8Char(firstByte As Integer) As String
		  // Read a complete UTF-8 character given the first byte

		  If firstByte < 128 Then
		    // Single byte ASCII
		    Return Chr(firstByte)
		  End If

		  // Determine number of continuation bytes needed
		  Var totalBytes As Integer = 1
		  If Bitwise.BitAnd(firstByte, &hE0) = &hC0 Then
		    totalBytes = 2
		  ElseIf Bitwise.BitAnd(firstByte, &hF0) = &hE0 Then
		    totalBytes = 3
		  ElseIf Bitwise.BitAnd(firstByte, &hF8) = &hF0 Then
		    totalBytes = 4
		  Else
		    // Invalid UTF-8 start byte
		    Return Chr(firstByte)
		  End If

		  // Read continuation bytes
		  Var mb As New MemoryBlock(totalBytes)
		  mb.UInt8Value(0) = firstByte

		  For i As Integer = 1 To totalBytes - 1
		    Var b As Integer = XjTerminal.ReadByte
		    If b < 0 Then
		      // Incomplete sequence — return what we have
		      Return Chr(firstByte)
		    End If
		    mb.UInt8Value(i) = b
		  Next

		  Return mb.StringValue(0, totalBytes).DefineEncoding(Encodings.UTF8)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReadLine(prompt As String) As String
		  // Array-based line editing — O(1) append, O(n-p) insert, single join at return
		  // Supports: typing, backspace, left/right, enter, escape, Ctrl+C

		  XjTerminal.Write(prompt)

		  Var chars() As String
		  Var cursorPos As Integer = 0

		  Do
		    Var key As XjKeyEvent = ReadKey
		    If key Is Nil Then
		      App.DoEvents(10)
		      Continue
		    End If

		    If key.IsEnter Then
		      XjTerminal.Write(Chr(13) + Chr(10))
		      Return String.FromArray(chars, "")
		    End If

		    If key.IsBackspace Then
		      If cursorPos > 0 Then
		        cursorPos = cursorPos - 1
		        chars.RemoveAt(cursorPos)
		        // Redraw: move back, write rest of line, clear trailing char, reposition
		        Var tailLen As Integer = chars.Count - cursorPos
		        XjTerminal.Write(XjANSI.CursorBackward(1))
		        If tailLen > 0 Then
		          XjTerminal.Write(TailString(chars, cursorPos) + " ")
		          XjTerminal.Write(XjANSI.CursorBackward(tailLen + 1))
		        Else
		          XjTerminal.Write(" ")
		          XjTerminal.Write(XjANSI.CursorBackward(1))
		        End If
		      End If
		      Continue
		    End If

		    If key.IsEscape Then
		      XjTerminal.Write(Chr(13) + Chr(10))
		      Return ""
		    End If

		    If key.IsCharKey And Not key.IsCtrl Then
		      // Insert character at cursor position
		      If cursorPos >= chars.Count Then
		        chars.Add(key.Char)
		      Else
		        chars.AddAt(cursorPos, key.Char)
		      End If
		      cursorPos = cursorPos + 1
		      // Write char and any text after cursor
		      Var tailLen As Integer = chars.Count - cursorPos
		      If tailLen > 0 Then
		        XjTerminal.Write(key.Char + TailString(chars, cursorPos))
		        XjTerminal.Write(XjANSI.CursorBackward(tailLen))
		      Else
		        XjTerminal.Write(key.Char)
		      End If
		    End If

		    If key.KeyCode = XjKeyEvent.KEY_LEFT And cursorPos > 0 Then
		      cursorPos = cursorPos - 1
		      XjTerminal.Write(XjANSI.CursorBackward(1))
		    End If

		    If key.KeyCode = XjKeyEvent.KEY_RIGHT And cursorPos < chars.Count Then
		      cursorPos = cursorPos + 1
		      XjTerminal.Write(XjANSI.CursorForward(1))
		    End If

		    // Ctrl+C = abort
		    If key.IsCtrl And key.Char = Chr(3) Then
		      XjTerminal.Write(Chr(13) + Chr(10))
		      Return ""
		    End If

		  Loop
		End Function
	#tag EndMethod


	#tag Method, Flags = &h21
		Private Function TailString(chars() As String, fromIndex As Integer) As String
		  // Build string from chars[fromIndex..end] via array+join
		  Var tailParts() As String
		  For j As Integer = fromIndex To chars.Count - 1
		    tailParts.Add(chars(j))
		  Next
		  Return String.FromArray(tailParts, "")
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjReader — Raw Keystroke Reader

		Part of XjTTY-Toolkit foundation layer.
		Reads and parses terminal input into XjKeyEvent objects.

		Features:
		- Parses VT100/xterm escape sequences
		- Handles arrow keys, function keys, home/end/delete/etc.
		- Detects Ctrl, Alt, Shift modifiers
		- Reads multi-byte UTF-8 characters
		- Simple ReadLine with basic editing
		- Works in both blocking and non-blocking modes

		Requires XjTerminal.EnableRawMode before use.

		Escape sequence parsing:
		- CSI sequences: ESC [ ... (arrows, function keys, etc.)
		- SS3 sequences: ESC O ... (F1-F4 on some terminals)
		- Alt+key: ESC + char
		- Modifier encoding: CSI 1;{mod} {key}
		  mod = 1+shift+2*alt+4*ctrl
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
End Class
#tag EndClass
