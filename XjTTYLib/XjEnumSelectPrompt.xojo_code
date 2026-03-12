#tag Class
Protected Class XjEnumSelectPrompt
	#tag Method, Flags = &h0
		Sub Constructor(question As String, choices() As String)
		  mQuestion = question

		  // Copy choices array
		  For i As Integer = 0 To choices.Count - 1
		    mChoices.Add(choices(i))
		  Next

		  mValue = ""
		  mDone = False
		  mCancelled = False
		  mErrorMessage = ""
		  mStyle = XjPromptStyle.Default_
		  mRenderer = New XjInlineRenderer
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
		    If key <> Nil Then
		      HandleKey(key)
		      If Not mDone Then
		        lines = BuildLines
		        mRenderer.Render(lines)
		      End If
		    End If
		  Wend

		  // Render settled state
		  Var settled() As String = BuildSettled
		  mRenderer.RenderSettled(settled)
		  mRenderer.End_

		  If mCancelled Then Return ""

		  Var idx As Integer = Val(mValue) - 1
		  If idx >= 0 And idx < mChoices.Count Then
		    Return mChoices(idx)
		  End If
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  If key.KeyCode = XjKeyEvent.KEY_ESCAPE Then
		    mCancelled = True
		    mDone = True
		    Return
		  End If

		  If key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    // Validate the entered number
		    If mValue = "" Then
		      mErrorMessage = "Please enter a number"
		      Return
		    End If

		    Var num As Integer = Val(mValue)
		    If num < 1 Or num > mChoices.Count Then
		      mErrorMessage = "Enter a number between 1 and " + Str(mChoices.Count)
		      Return
		    End If

		    mDone = True
		    Return
		  End If

		  If key.KeyCode = XjKeyEvent.KEY_BACKSPACE Then
		    If mValue.Length > 0 Then
		      mValue = mValue.Left(mValue.Length - 1)
		      mErrorMessage = ""
		    End If
		    Return
		  End If

		  // Accept digit characters only
		  If key.IsCharKey And Not key.IsCtrl Then
		    Var c As String = key.Char
		    If c >= "0" And c <= "9" Then
		      mValue = mValue + c
		      mErrorMessage = ""
		    End If
		    Return
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var lines() As String

		  // Line 1: question
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark)
		  Var q As String = mStyle.QuestionStyle.Apply(mQuestion)
		  lines.Add(prefix + " " + q)

		  // Numbered choice list
		  For i As Integer = 0 To mChoices.Count - 1
		    Var num As String = Str(i + 1)
		    lines.Add("  " + num + ") " + mChoices(i))
		  Next

		  // Input line
		  Var inputLine As String = "  Enter number: " + mValue + "_"
		  lines.Add(inputLine)

		  // Error message if present
		  If mErrorMessage <> "" Then
		    lines.Add("  " + mStyle.ErrorStyle.Apply(mErrorMessage))
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildSettled() As String()
		  Var lines() As String

		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark)
		  Var q As String = mStyle.QuestionStyle.Apply(mQuestion)

		  If mCancelled Then
		    lines.Add(prefix + " " + q + " " + mStyle.HelpStyle.Apply("(cancelled)"))
		  Else
		    Var idx As Integer = Val(mValue) - 1
		    Var selectedText As String
		    If idx >= 0 And idx < mChoices.Count Then
		      selectedText = mChoices(idx)
		    End If
		    Var answer As String = mStyle.AnswerStyle.Apply(selectedText)
		    lines.Add(prefix + " " + q + " " + answer)
		  End If

		  Return lines
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjEnumSelectPrompt — Numbered List Prompt

		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Displays a numbered list of choices; user types a number to select.

		Usage:
		  Var choices() As String = Array("Save", "Load", "Quit")
		  Var p As New XjEnumSelectPrompt("Action:", choices)
		  Var result As String = p.Run
	#tag EndNote

	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChoices() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValue As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCancelled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mErrorMessage As String
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
