#tag Class
Protected Class XjMultiLinePrompt
	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var output() As String
		  
		  // Header line: "? Question: (Ctrl+D to finish)"
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)
		  Var hint As String = mStyle.HelpStyle.Apply("(Ctrl+D to finish)")
		  
		  output.Add(prefix + question + " " + hint)
		  
		  // Each line with "> " prefix and cursor indicator
		  Var linePrefix As String = mStyle.ActiveStyle.Apply("> ")
		  For row As Integer = 0 To mLines.Count - 1
		    Var lineText As String = mLines(row)
		    
		    If row = mCursorRow Then
		      // Show cursor on this line
		      Var beforeCursor As String = lineText.Left(mCursorCol)
		      Var cursorChar As String
		      If mCursorCol < lineText.Length Then
		        cursorChar = mStyle.CursorStyle.Apply(lineText.Middle(mCursorCol, 1))
		      Else
		        cursorChar = mStyle.CursorStyle.Apply(" ")
		      End If
		      Var afterCursor As String
		      If mCursorCol + 1 < lineText.Length Then
		        afterCursor = lineText.Middle(mCursorCol + 1)
		      End If
		      output.Add(linePrefix + beforeCursor + cursorChar + afterCursor)
		    Else
		      output.Add(linePrefix + lineText)
		    End If
		  Next
		  
		  Return output
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildSettledLines() As String()
		  Var output() As String
		  
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.Check) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)
		  
		  Var lineCount As Integer = mLines.Count
		  Var summary As String = mStyle.AnswerStyle.Apply("(" + Str(lineCount) + " lines)")
		  
		  output.Add(prefix + question + " " + summary)
		  
		  Return output
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(question As String)
		  mQuestion = question
		  mCursorRow = 0
		  mCursorCol = 0
		  mDone = False
		  mCancelled = False
		  mStyle = XjPromptStyle.Default_
		  mRenderer = New XjInlineRenderer
		  
		  // Start with one empty line
		  mLines.Add("")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  If key Is Nil Then Return
		  
		  // Ctrl+D finishes input
		  If key.IsCtrl And key.Char = Chr(4) Then
		    mDone = True
		    Return
		  End If
		  
		  // Escape or Ctrl+C cancels
		  If key.IsEscape Or (key.IsCtrl And key.Char = Chr(3)) Then
		    mCancelled = True
		    mDone = True
		    Return
		  End If
		  
		  // Enter inserts a new line
		  If key.IsEnter Then
		    Var currentLine As String = mLines(mCursorRow)
		    Var beforeCursor As String = currentLine.Left(mCursorCol)
		    Var afterCursor As String = currentLine.Middle(mCursorCol)
		    
		    mLines(mCursorRow) = beforeCursor
		    
		    // Insert new line after current
		    If mCursorRow + 1 >= mLines.Count Then
		      mLines.Add(afterCursor)
		    Else
		      mLines.AddAt(mCursorRow + 1, afterCursor)
		    End If
		    
		    mCursorRow = mCursorRow + 1
		    mCursorCol = 0
		    Return
		  End If
		  
		  // Backspace
		  If key.IsBackspace Then
		    If mCursorCol > 0 Then
		      Var line As String = mLines(mCursorRow)
		      mLines(mCursorRow) = line.Left(mCursorCol - 1) + line.Middle(mCursorCol)
		      mCursorCol = mCursorCol - 1
		    ElseIf mCursorRow > 0 Then
		      // Merge with previous line
		      Var prevLine As String = mLines(mCursorRow - 1)
		      Var currentLine As String = mLines(mCursorRow)
		      mCursorCol = prevLine.Length
		      mLines(mCursorRow - 1) = prevLine + currentLine
		      mLines.RemoveAt(mCursorRow)
		      mCursorRow = mCursorRow - 1
		    End If
		    Return
		  End If
		  
		  // Delete
		  If key.KeyCode = XjKeyEvent.KEY_DELETE Then
		    Var line As String = mLines(mCursorRow)
		    If mCursorCol < line.Length Then
		      mLines(mCursorRow) = line.Left(mCursorCol) + line.Middle(mCursorCol + 1)
		    ElseIf mCursorRow < mLines.Count - 1 Then
		      // Merge next line into current
		      mLines(mCursorRow) = line + mLines(mCursorRow + 1)
		      mLines.RemoveAt(mCursorRow + 1)
		    End If
		    Return
		  End If
		  
		  // Arrow keys
		  If key.KeyCode = XjKeyEvent.KEY_LEFT Then
		    If mCursorCol > 0 Then
		      mCursorCol = mCursorCol - 1
		    ElseIf mCursorRow > 0 Then
		      mCursorRow = mCursorRow - 1
		      mCursorCol = mLines(mCursorRow).Length
		    End If
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_RIGHT Then
		    Var lineLen As Integer = mLines(mCursorRow).Length
		    If mCursorCol < lineLen Then
		      mCursorCol = mCursorCol + 1
		    ElseIf mCursorRow < mLines.Count - 1 Then
		      mCursorRow = mCursorRow + 1
		      mCursorCol = 0
		    End If
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_UP Then
		    If mCursorRow > 0 Then
		      mCursorRow = mCursorRow - 1
		      If mCursorCol > mLines(mCursorRow).Length Then
		        mCursorCol = mLines(mCursorRow).Length
		      End If
		    End If
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_DOWN Then
		    If mCursorRow < mLines.Count - 1 Then
		      mCursorRow = mCursorRow + 1
		      If mCursorCol > mLines(mCursorRow).Length Then
		        mCursorCol = mLines(mCursorRow).Length
		      End If
		    End If
		    Return
		  End If
		  
		  // Home
		  If key.KeyCode = XjKeyEvent.KEY_HOME Then
		    mCursorCol = 0
		    Return
		  End If
		  
		  // End
		  If key.KeyCode = XjKeyEvent.KEY_END_ Then
		    mCursorCol = mLines(mCursorRow).Length
		    Return
		  End If
		  
		  // Printable character
		  If key.IsCharKey And Not key.IsCtrl Then
		    Var line As String = mLines(mCursorRow)
		    mLines(mCursorRow) = line.Left(mCursorCol) + key.Char + line.Middle(mCursorCol)
		    mCursorCol = mCursorCol + 1
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run() As String
		  XjSymbols.EnsureInit
		  mRenderer.Begin
		  
		  // Initial render
		  Var lines() As String = BuildLines
		  mRenderer.Render(lines)
		  
		  While Not mDone
		    Var key As XjKeyEvent = mRenderer.ReadKey
		    HandleKey(key)
		    
		    If Not mDone Then
		      lines = BuildLines
		      mRenderer.Render(lines)
		    End If
		  Wend
		  
		  // Build result
		  Var answer As String
		  If mCancelled Then
		    answer = ""
		  Else
		    answer = String.FromArray(mLines, EndOfLine)
		  End If
		  
		  // Render settled state
		  Var settled() As String = BuildSettledLines
		  mRenderer.RenderSettled(settled)
		  mRenderer.End_
		  
		  Return answer
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjMultiLinePrompt — Multi-line Text Input Prompt
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Inline prompt for multi-line text input with Ctrl+D to finish.
		
		Usage:
		  Var prompt As New XjMultiLinePrompt("Enter description:")
		  Var text As String = prompt.Run
		
		Features:
		- Multiple lines with Enter to add new lines
		- Ctrl+D to finish input
		- Arrow key navigation between lines
		- Backspace/Delete editing with line merging
		- Home/End within current line
		- Escape/Ctrl+C to cancel
		- Styled output with XjPromptStyle
	#tag EndNote


	#tag Property, Flags = &h21
		Private mCancelled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCursorCol As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCursorRow As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLines() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRenderer As XjInlineRenderer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStyle As XjPromptStyle
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
