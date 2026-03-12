#tag Module
Protected Module XjCursor
	#tag Method, Flags = &h0
		Function GetPosition(ByRef row As Integer, ByRef col As Integer) As Boolean
		  // Query current cursor position from terminal
		  // Returns True on success
		  // NOTE: Terminal must be in raw mode for this to work
		  
		  If Not XjTerminal.IsRawMode Then Return False
		  
		  // Send cursor position request
		  XjTerminal.Write(XjANSI.CursorRequestPosition)
		  
		  // Read response: ESC [ {row} ; {col} R
		  Var response As String
		  Var startTime As Double = System.Microseconds
		  Var timeout As Double = 100000 // 100ms timeout
		  
		  // Read until 'R' is received or timeout
		  Do
		    Var b As Integer = XjTerminal.ReadByte
		    If b >= 0 Then
		      response = response + Chr(b)
		      If Chr(b) = "R" Then Exit
		    End If
		    
		    If (System.Microseconds - startTime) > timeout Then
		      Return False
		    End If
		  Loop
		  
		  // Parse response: ESC [ {row} ; {col} R
		  // Find the '[' and 'R'
		  Var bracketPos As Integer = response.IndexOf("[")
		  Var rPos As Integer = response.IndexOf("R")
		  
		  If bracketPos < 0 Or rPos < 0 Then Return False
		  
		  Var coords As String = response.Middle(bracketPos + 1, rPos - bracketPos - 1)
		  Var parts() As String = coords.Split(";")
		  
		  If parts.Count < 2 Then Return False
		  
		  row = Integer.FromString(parts(0))
		  col = Integer.FromString(parts(1))
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Hide()
		  // Hide cursor
		  XjTerminal.Write(XjANSI.CursorHide)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Home()
		  // Move to top-left corner
		  MoveTo(1, 1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveDown(n As Integer)
		  If n > 0 Then XjTerminal.Write(XjANSI.CursorDown(n))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveLeft(n As Integer)
		  If n > 0 Then XjTerminal.Write(XjANSI.CursorBackward(n))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveRelative(deltaRow As Integer, deltaCol As Integer)
		  // Move cursor relative to current position
		  If deltaRow > 0 Then MoveDown(deltaRow)
		  If deltaRow < 0 Then MoveUp(-deltaRow)
		  If deltaCol > 0 Then MoveRight(deltaCol)
		  If deltaCol < 0 Then MoveLeft(-deltaCol)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveRight(n As Integer)
		  If n > 0 Then XjTerminal.Write(XjANSI.CursorForward(n))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveTo(row As Integer, col As Integer)
		  // Move cursor to absolute position (1-based)
		  XjTerminal.Write(XjANSI.CursorPosition(row, col))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveToColumn(col As Integer)
		  XjTerminal.Write(XjANSI.CursorColumn(col))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MoveUp(n As Integer)
		  If n > 0 Then XjTerminal.Write(XjANSI.CursorUp(n))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NextLine(n As Integer)
		  If n > 0 Then XjTerminal.Write(XjANSI.CursorNextLine(n))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrevLine(n As Integer)
		  If n > 0 Then XjTerminal.Write(XjANSI.CursorPrevLine(n))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Restore()
		  // Restore previously saved cursor position
		  XjTerminal.Write(XjANSI.CursorRestore)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Save()
		  // Save current cursor position
		  XjTerminal.Write(XjANSI.CursorSave)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Show()
		  // Make cursor visible
		  XjTerminal.Write(XjANSI.CursorShow)
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjCursor — Cursor Movement and Visibility Control
		
		Part of XjTTY-Toolkit foundation layer.
		Provides cursor operations:
		
		- Absolute positioning: MoveTo(row, col)
		- Relative movement: MoveUp/Down/Left/Right
		- Column positioning: MoveToColumn
		- Line navigation: NextLine, PrevLine, Home
		- State: Save, Restore
		- Visibility: Show, Hide
		- Position query: GetPosition (requires raw mode)
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
