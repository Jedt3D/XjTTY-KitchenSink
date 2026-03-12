#tag Class
Protected Class XjPasswordPrompt
	#tag Method, Flags = &h0
		Sub Constructor(question As String, mask As String = "")
		  mQuestion = question
		  mValue = ""
		  mCursorPos = 0
		  mDone = False
		  mCancelled = False
		  mStyle = XjPromptStyle.Default_
		  mRenderer = New XjInlineRenderer

		  // Set mask character
		  If mask <> "" Then
		    mMask = mask
		  Else
		    XjSymbols.EnsureInit
		    mMask = XjSymbols.Bullet
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMask(mask As String) As XjPasswordPrompt
		  mMask = mask
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetPromptStyle(ps As XjPromptStyle) As XjPasswordPrompt
		  mStyle = ps
		  Return Self
		End Function
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
		    answer = ""
		  Else
		    answer = mValue
		  End If

		  // Render settled state
		  Var settled() As String = BuildSettledLines
		  mRenderer.RenderSettled(settled)
		  mRenderer.End_

		  Return answer
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  If key Is Nil Then Return

		  If key.IsEnter Then
		    mDone = True
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
		    Return
		  End If

		  If key.KeyCode = XjKeyEvent.KEY_DELETE Then
		    If mCursorPos < mValue.Length Then
		      mValue = mValue.Left(mCursorPos) + mValue.Middle(mCursorPos + 1)
		    End If
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
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MaskString(length As Integer) As String
		  // Build a string of mask characters
		  Var parts() As String
		  For i As Integer = 1 To length
		    parts.Add(mMask)
		  Next
		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var lines() As String

		  // Build line 1: "? question: masked-input"
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)

		  // Build masked input with cursor
		  Var inputText As String
		  If mValue.Length = 0 Then
		    // Show cursor on empty input
		    inputText = mStyle.CursorStyle.Apply(" ")
		  Else
		    // Show mask chars with cursor
		    Var beforeCursor As String = MaskString(mCursorPos)
		    Var cursorChar As String
		    If mCursorPos < mValue.Length Then
		      cursorChar = mStyle.CursorStyle.Apply(mMask)
		    Else
		      cursorChar = mStyle.CursorStyle.Apply(" ")
		    End If
		    Var afterCursor As String
		    If mCursorPos + 1 < mValue.Length Then
		      afterCursor = MaskString(mValue.Length - mCursorPos - 1)
		    End If
		    inputText = beforeCursor + cursorChar + afterCursor
		  End If

		  lines.Add(prefix + question + " " + inputText)

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildSettledLines() As String()
		  Var lines() As String

		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.Check) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)

		  // Show masked answer in cyan
		  Var maskedAnswer As String
		  If mCancelled Then
		    maskedAnswer = ""
		  Else
		    maskedAnswer = MaskString(mValue.Length)
		  End If
		  Var styledAnswer As String = mStyle.AnswerStyle.Apply(maskedAnswer)

		  lines.Add(prefix + question + " " + styledAnswer)

		  Return lines
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjPasswordPrompt — Masked Input Prompt

		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Inline prompt for password/secret input with masked display.

		Usage:
		  Var prompt As New XjPasswordPrompt("Enter password:")
		  Var pw As String = prompt.Run

		  // Custom mask character
		  Var prompt2 As New XjPasswordPrompt("Secret:", "*")
		  Var secret As String = prompt2.Run

		Features:
		- Displays mask characters instead of actual text
		- Cursor navigation (left/right/home/end)
		- Backspace and delete editing
		- Escape/Ctrl+C to cancel (returns empty string)
		- Default mask is Unicode bullet character
		- Styled output with XjPromptStyle
	#tag EndNote

	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValue As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCursorPos As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMask As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCancelled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStyle As XjPromptStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRenderer As XjInlineRenderer
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
