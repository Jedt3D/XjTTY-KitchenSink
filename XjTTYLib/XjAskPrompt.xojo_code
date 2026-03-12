#tag Class
Protected Class XjAskPrompt
	#tag Method, Flags = &h0
		Function AddValidation(v As XjValidation) As XjAskPrompt
		  mValidators.Add(v)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var lines() As String
		  
		  // Build line 1: "? question (default) input"
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)
		  
		  Var defaultHint As String
		  If mDefault <> "" And mValue = "" Then
		    defaultHint = " " + mStyle.HelpStyle.Apply("(" + mDefault + ")")
		  End If
		  
		  // Build visible input with cursor
		  Var inputText As String
		  If mValue.Length = 0 Then
		    // Show cursor on empty input
		    inputText = mStyle.CursorStyle.Apply(" ")
		  Else
		    // Show text with cursor
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
		  
		  lines.Add(prefix + question + defaultHint + " " + inputText)
		  
		  // Line 2: error message (if any)
		  If mErrorMessage <> "" Then
		    lines.Add(mStyle.ErrorStyle.Apply(">> " + mErrorMessage))
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
		Sub Constructor(question As String, defaultValue As String = "")
		  mQuestion = question
		  mDefault = defaultValue
		  mValue = ""
		  mCursorPos = 0
		  mScrollOffset = 0
		  mModifier = XjConversion.MOD_NONE
		  mErrorMessage = ""
		  mDone = False
		  mCancelled = False
		  mStyle = XjPromptStyle.Default_
		  mRenderer = New XjInlineRenderer
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  If key Is Nil Then Return
		  
		  If key.IsEnter Then
		    // Validate
		    Var finalValue As String = mValue
		    If finalValue = "" Then finalValue = mDefault
		    
		    Var errMsg As String
		    Var valid As Boolean = True
		    For i As Integer = 0 To mValidators.Count - 1
		      If Not mValidators(i).Validate(finalValue, errMsg) Then
		        valid = False
		        Exit
		      End If
		    Next
		    
		    If valid Then
		      mErrorMessage = ""
		      mDone = True
		    Else
		      mErrorMessage = errMsg
		    End If
		    Return
		  End If
		  
		  If key.IsEscape Or (key.IsCtrl And key.Char = Chr(3)) Then
		    mCancelled = True
		    mDone = True
		    Return
		  End If
		  
		  If key.IsBackspace Then
		    If mCursorPos > 0 Then
		      mValue = mValue.Left(mCursorPos - 1) + mValue.Middle(mCursorPos)
		      mCursorPos = mCursorPos - 1
		    End If
		    mErrorMessage = ""
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_DELETE Then
		    If mCursorPos < mValue.Length Then
		      mValue = mValue.Left(mCursorPos) + mValue.Middle(mCursorPos + 1)
		    End If
		    mErrorMessage = ""
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_LEFT Then
		    If mCursorPos > 0 Then mCursorPos = mCursorPos - 1
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_RIGHT Then
		    If mCursorPos < mValue.Length Then mCursorPos = mCursorPos + 1
		    Return
		  End If
		  
		  // History navigation
		  If key.KeyCode = XjKeyEvent.KEY_UP Then
		    If mHistory <> Nil Then
		      mValue = mHistory.Previous(mValue)
		      mCursorPos = mValue.Length
		    End If
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_DOWN Then
		    If mHistory <> Nil Then
		      mValue = mHistory.Next_(mValue)
		      mCursorPos = mValue.Length
		    End If
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_HOME Then
		    mCursorPos = 0
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_END_ Then
		    mCursorPos = mValue.Length
		    Return
		  End If
		  
		  // Printable character
		  If key.IsCharKey And Not key.IsCtrl Then
		    mValue = mValue.Left(mCursorPos) + key.Char + mValue.Middle(mCursorPos)
		    mCursorPos = mCursorPos + 1
		    mErrorMessage = ""
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
		  
		  // Final answer
		  Var answer As String
		  If mCancelled Then
		    answer = mDefault
		  Else
		    answer = mValue
		    If answer = "" Then answer = mDefault
		    answer = XjConversion.ApplyModifier(answer, mModifier)
		  End If
		  
		  // Add to history if not cancelled
		  If Not mCancelled And mHistory <> Nil And answer <> "" Then
		    mHistory.Add(answer)
		  End If
		  
		  // Render settled state
		  Var settled() As String = BuildSettledLines(answer)
		  mRenderer.RenderSettled(settled)
		  mRenderer.End_
		  
		  Return answer
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetDefault(value As String) As XjAskPrompt
		  mDefault = value
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetHistory(h As XjHistory) As XjAskPrompt
		  mHistory = h
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetModifier(mod_ As Integer) As XjAskPrompt
		  mModifier = mod_
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetPromptStyle(ps As XjPromptStyle) As XjAskPrompt
		  mStyle = ps
		  Return Self
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjAskPrompt — Free-form Text Input Prompt
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Inline prompt for free-form text input with validation.
		
		Usage:
		  Var prompt As New XjAskPrompt("What is your name?")
		  Call prompt.AddValidation(XjValidation.Required)
		  Var name As String = prompt.Run
		
		Features:
		- Default value hint
		- Cursor navigation (left/right/home/end)
		- Backspace and delete editing
		- Validation with error messages
		- Input modifiers (uppercase, lowercase, etc.)
		- Escape/Ctrl+C to cancel (returns default)
		- Styled output with XjPromptStyle
	#tag EndNote


	#tag Property, Flags = &h21
		Private mCancelled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCursorPos As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDefault As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mErrorMessage As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHistory As XjHistory
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mModifier As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRenderer As XjInlineRenderer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScrollOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStyle As XjPromptStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValidators() As XjValidation
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
