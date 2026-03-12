#tag Class
Protected Class XjConfirmPrompt
	#tag Method, Flags = &h0
		Sub Constructor(question As String, defaultYes As Boolean = True)
		  mQuestion = question
		  mDefaultYes = defaultYes
		  mResult = defaultYes
		  mDone = False
		  mStyle = XjPromptStyle.Default_
		  mRenderer = New XjInlineRenderer
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetPromptStyle(ps As XjPromptStyle) As XjConfirmPrompt
		  mStyle = ps
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run() As Boolean
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

		  // Render settled state
		  Var settled() As String = BuildSettledLines
		  mRenderer.RenderSettled(settled)
		  mRenderer.End_

		  Return mResult
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  If key Is Nil Then Return

		  If key.IsEnter Then
		    // Accept current default
		    mResult = mDefaultYes
		    mDone = True
		    Return
		  End If

		  If key.IsEscape Or (key.IsCtrl And key.Char = Chr(3)) Then
		    mResult = mDefaultYes
		    mDone = True
		    Return
		  End If

		  If key.IsCharKey Then
		    Var ch As String = key.Char
		    If ch = "y" Or ch = "Y" Then
		      mResult = True
		      mDone = True
		      Return
		    End If
		    If ch = "n" Or ch = "N" Then
		      mResult = False
		      mDone = True
		      Return
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var lines() As String

		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)

		  // Build hint: (Y/n) or (y/N)
		  Var hint As String
		  If mDefaultYes Then
		    hint = "(Y/n)"
		  Else
		    hint = "(y/N)"
		  End If
		  Var styledHint As String = mStyle.HelpStyle.Apply(hint)

		  lines.Add(prefix + question + " " + styledHint + " " + mStyle.CursorStyle.Apply(" "))

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildSettledLines() As String()
		  Var lines() As String

		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.Check) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)

		  Var answerText As String
		  If mResult Then
		    answerText = "Yes"
		  Else
		    answerText = "No"
		  End If
		  Var styledAnswer As String = mStyle.AnswerStyle.Apply(answerText)

		  lines.Add(prefix + question + " " + styledAnswer)

		  Return lines
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjConfirmPrompt — Boolean Yes/No Prompt

		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Inline prompt for yes/no confirmation.

		Usage:
		  Var prompt As New XjConfirmPrompt("Are you sure?")
		  Var confirmed As Boolean = prompt.Run

		  Var prompt2 As New XjConfirmPrompt("Delete files?", False)
		  Var confirmed2 As Boolean = prompt2.Run

		Features:
		- Default yes or no (capitalized in hint)
		- y/Y for yes, n/N for no
		- Enter accepts default
		- Escape/Ctrl+C returns default
		- Styled output with XjPromptStyle
	#tag EndNote

	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDefaultYes As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mResult As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
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
