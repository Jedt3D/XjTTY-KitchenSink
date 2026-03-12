#tag Class
Protected Class XjInlineRenderer
	#tag Method, Flags = &h0
		Sub Constructor()
		  mRenderedLines = 0
		  mWasRawMode = False
		  mTermWidth = 80
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Begin()
		  // Save raw mode state and enable if needed
		  mWasRawMode = XjTerminal.IsRawMode
		  If Not mWasRawMode Then
		    XjTerminal.EnableRawMode
		  End If
		  XjTerminal.EnableNonBlockingInput

		  mReader = New XjReader
		  mTermWidth = XjTerminal.Width
		  mRenderedLines = 0

		  // Hide cursor during rendering
		  XjTerminal.Write(XjANSI.CursorHide)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub End_()
		  // Show cursor
		  XjTerminal.Write(XjANSI.CursorShow)

		  // Restore raw mode if we changed it
		  If Not mWasRawMode Then
		    XjTerminal.DisableRawMode
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Render(lines() As String)
		  // Move cursor back to start of prompt
		  // After writing N lines, cursor is ON line N (not below it)
		  // so we only need to go up N-1 lines to reach line 1
		  If mRenderedLines > 1 Then
		    XjTerminal.Write(XjANSI.CursorUp(mRenderedLines - 1) + Chr(13))
		  ElseIf mRenderedLines = 1 Then
		    XjTerminal.Write(Chr(13))
		  End If

		  // Write each line
		  For i As Integer = 0 To lines.Count - 1
		    XjTerminal.Write(XjANSI.EraseLine + lines(i))
		    If i < lines.Count - 1 Then
		      XjTerminal.Write(Chr(13) + Chr(10))
		    End If
		  Next

		  // If we previously rendered more lines, erase the extras
		  If lines.Count < mRenderedLines Then
		    For i As Integer = lines.Count To mRenderedLines - 1
		      XjTerminal.Write(Chr(13) + Chr(10) + XjANSI.EraseLine)
		    Next
		    // Move back up to end of content
		    Var extraLines As Integer = mRenderedLines - lines.Count
		    If extraLines > 0 Then
		      XjTerminal.Write(XjANSI.CursorUp(extraLines))
		    End If
		  End If

		  mRenderedLines = lines.Count
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RenderSettled(lines() As String)
		  // Render the final settled state and move past it
		  If mRenderedLines > 1 Then
		    XjTerminal.Write(XjANSI.CursorUp(mRenderedLines - 1) + Chr(13))
		  ElseIf mRenderedLines = 1 Then
		    XjTerminal.Write(Chr(13))
		  End If

		  For i As Integer = 0 To lines.Count - 1
		    XjTerminal.Write(XjANSI.EraseLine + lines(i))
		    XjTerminal.Write(Chr(13) + Chr(10))
		  Next

		  // Erase any leftover lines from before
		  If lines.Count < mRenderedLines Then
		    For i As Integer = lines.Count To mRenderedLines - 1
		      XjTerminal.Write(XjANSI.EraseLine + Chr(13) + Chr(10))
		    Next
		  End If

		  // Reset rendered count (we've moved past)
		  mRenderedLines = 0

		  // Show cursor for settled state
		  XjTerminal.Write(XjANSI.CursorShow)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReadKey() As XjKeyEvent
		  // Block until a key arrives, yielding with DoEvents
		  Do
		    Var key As XjKeyEvent = mReader.ReadKey
		    If key <> Nil Then Return key
		    App.DoEvents(10)
		  Loop
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TermWidth() As Integer
		  Return mTermWidth
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RefreshTermWidth()
		  mTermWidth = XjTerminal.Width
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjInlineRenderer — Inline Prompt Rendering Engine

		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Manages the cursor-up/erase-line dance for inline prompts.
		All prompt classes delegate terminal output through this.

		Usage:
		  Var r As New XjInlineRenderer
		  r.Begin
		  r.Render(activeLines)   // can call repeatedly
		  r.RenderSettled(finalLines)
		  r.End_
	#tag EndNote

	#tag Property, Flags = &h21
		Private mRenderedLines As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mReader As XjReader
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWasRawMode As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTermWidth As Integer
	#tag EndProperty


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
