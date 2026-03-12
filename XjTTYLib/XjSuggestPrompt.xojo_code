#tag Class
Protected Class XjSuggestPrompt
	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var lines() As String
		  
		  // Line 1: "? Question: input_"
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)
		  
		  // Build input with cursor
		  Var inputText As String
		  If mValue.Length = 0 Then
		    inputText = mStyle.CursorStyle.Apply(" ")
		  Else
		    Var beforeCursor As String = mValue.Left(mCursorPos)
		    Var cursorChar As String
		    If mCursorPos < mValue.Length Then
		      cursorChar = mStyle.CursorStyle.Apply(mValue.Middle(mCursorPos, 1))
		    Else
		      cursorChar = mStyle.CursorStyle.Apply(" ")
		    End If
		    Var afterCursor As String
		    If mCursorPos + 1 < mValue.Length Then
		      afterCursor = mValue.Middle(mCursorPos + 1)
		    End If
		    inputText = beforeCursor + cursorChar + afterCursor
		  End If
		  
		  lines.Add(prefix + question + " " + inputText)
		  
		  // Suggestion list (max 7 visible)
		  Var maxVisible As Integer = 7
		  If maxVisible > mFilteredSuggestions.Count Then
		    maxVisible = mFilteredSuggestions.Count
		  End If
		  
		  For i As Integer = 0 To maxVisible - 1
		    Var suggestion As String = mFilteredSuggestions(i)
		    If i = mSelectedSuggestion Then
		      lines.Add("  " + mStyle.ActiveStyle.Apply(XjSymbols.Marker + " " + suggestion))
		    Else
		      lines.Add("    " + suggestion)
		    End If
		  Next
		  
		  // Show count hint if more items
		  If mFilteredSuggestions.Count > maxVisible Then
		    Var remaining As Integer = mFilteredSuggestions.Count - maxVisible
		    lines.Add("  " + mStyle.HelpStyle.Apply("(" + Str(remaining) + " more)"))
		  End If
		  
		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildSettledLines(answer As String) As String()
		  Var lines() As String
		  
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.Check) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)
		  Var styledAnswer As String = mStyle.AnswerStyle.Apply(answer)
		  
		  lines.Add(prefix + question + " " + styledAnswer)
		  
		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(question As String, completer As XjCompleter)
		  mQuestion = question
		  mValue = ""
		  mCursorPos = 0
		  mCompleter = completer
		  mSelectedSuggestion = -1
		  mDone = False
		  mCancelled = False
		  mStyle = XjPromptStyle.Default_
		  mRenderer = New XjInlineRenderer
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  If key Is Nil Then Return
		  
		  // Enter confirms current value
		  If key.IsEnter Then
		    mDone = True
		    Return
		  End If
		  
		  // Escape or Ctrl+C cancels
		  If key.IsEscape Or (key.IsCtrl And key.Char = Chr(3)) Then
		    mCancelled = True
		    mDone = True
		    Return
		  End If
		  
		  // Tab accepts the selected suggestion
		  If key.IsTab Then
		    If mSelectedSuggestion >= 0 And mSelectedSuggestion < mFilteredSuggestions.Count Then
		      mValue = mFilteredSuggestions(mSelectedSuggestion)
		      mCursorPos = mValue.Length
		      UpdateSuggestions
		    End If
		    Return
		  End If
		  
		  // Up navigates suggestions
		  If key.KeyCode = XjKeyEvent.KEY_UP Then
		    If mFilteredSuggestions.Count > 0 Then
		      mSelectedSuggestion = mSelectedSuggestion - 1
		      If mSelectedSuggestion < 0 Then
		        mSelectedSuggestion = mFilteredSuggestions.Count - 1
		      End If
		    End If
		    Return
		  End If
		  
		  // Down navigates suggestions
		  If key.KeyCode = XjKeyEvent.KEY_DOWN Then
		    If mFilteredSuggestions.Count > 0 Then
		      mSelectedSuggestion = mSelectedSuggestion + 1
		      If mSelectedSuggestion >= mFilteredSuggestions.Count Then
		        mSelectedSuggestion = 0
		      End If
		    End If
		    Return
		  End If
		  
		  // Left
		  If key.KeyCode = XjKeyEvent.KEY_LEFT Then
		    If mCursorPos > 0 Then mCursorPos = mCursorPos - 1
		    Return
		  End If
		  
		  // Right
		  If key.KeyCode = XjKeyEvent.KEY_RIGHT Then
		    If mCursorPos < mValue.Length Then mCursorPos = mCursorPos + 1
		    Return
		  End If
		  
		  // Home
		  If key.KeyCode = XjKeyEvent.KEY_HOME Then
		    mCursorPos = 0
		    Return
		  End If
		  
		  // End
		  If key.KeyCode = XjKeyEvent.KEY_END_ Then
		    mCursorPos = mValue.Length
		    Return
		  End If
		  
		  // Backspace
		  If key.IsBackspace Then
		    If mCursorPos > 0 Then
		      mValue = mValue.Left(mCursorPos - 1) + mValue.Middle(mCursorPos)
		      mCursorPos = mCursorPos - 1
		      UpdateSuggestions
		    End If
		    Return
		  End If
		  
		  // Delete
		  If key.KeyCode = XjKeyEvent.KEY_DELETE Then
		    If mCursorPos < mValue.Length Then
		      mValue = mValue.Left(mCursorPos) + mValue.Middle(mCursorPos + 1)
		      UpdateSuggestions
		    End If
		    Return
		  End If
		  
		  // Printable character
		  If key.IsCharKey And Not key.IsCtrl Then
		    mValue = mValue.Left(mCursorPos) + key.Char + mValue.Middle(mCursorPos)
		    mCursorPos = mCursorPos + 1
		    UpdateSuggestions
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run() As String
		  XjSymbols.EnsureInit
		  mRenderer.Begin
		  
		  // Build initial suggestions
		  UpdateSuggestions
		  
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
		    answer = mValue
		  End If
		  
		  // Render settled state
		  Var settled() As String = BuildSettledLines(answer)
		  mRenderer.RenderSettled(settled)
		  mRenderer.End_
		  
		  Return answer
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateSuggestions()
		  mFilteredSuggestions = mCompleter.Complete(mValue)
		  
		  // Reset selection
		  If mFilteredSuggestions.Count > 0 Then
		    mSelectedSuggestion = 0
		  Else
		    mSelectedSuggestion = -1
		  End If
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjSuggestPrompt — Auto-completion Input Prompt
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Inline prompt with real-time suggestion dropdown from XjCompleter.
		
		Usage:
		  Var words() As String = Array("New York", "New Jersey", "Newark")
		  Var c As XjCompleter = XjCompleter.FromWords(words)
		  Var prompt As New XjSuggestPrompt("City:", c)
		  Var city As String = prompt.Run
		
		Features:
		- Real-time prefix matching as you type
		- Suggestion dropdown with arrow key navigation
		- Tab to accept selected suggestion
		- Full cursor editing (left/right/home/end/backspace/delete)
		- Enter to confirm current value
		- Escape/Ctrl+C to cancel
		- Styled output with XjPromptStyle
	#tag EndNote


	#tag Property, Flags = &h21
		Private mCancelled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCompleter As XjCompleter
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCursorPos As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFilteredSuggestions() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRenderer As XjInlineRenderer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelectedSuggestion As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStyle As XjPromptStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValue As String
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
