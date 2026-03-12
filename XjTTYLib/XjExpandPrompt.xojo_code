#tag Class
Protected Class XjExpandPrompt
	#tag Method, Flags = &h0
		Sub Constructor(question As String, choices() As String, keys() As String)
		  mQuestion = question

		  // Copy choices and keys arrays
		  For i As Integer = 0 To choices.Count - 1
		    mChoices.Add(choices(i))
		  Next

		  For i As Integer = 0 To keys.Count - 1
		    mKeys.Add(keys(i))
		  Next

		  mExpanded = False
		  mDone = False
		  mCancelled = False
		  mResult = ""
		  mInputChar = ""
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
		  Return mResult
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  If key.KeyCode = XjKeyEvent.KEY_ESCAPE Then
		    mCancelled = True
		    mDone = True
		    Return
		  End If

		  If key.IsCharKey And Not key.IsCtrl Then
		    Var c As String = key.Char.Lowercase

		    // Check if 'h' was pressed to expand
		    If c = "h" And Not mExpanded Then
		      mExpanded = True
		      mInputChar = ""
		      Return
		    End If

		    // Check if the character matches any key
		    For i As Integer = 0 To mKeys.Count - 1
		      If mKeys(i).Lowercase = c Then
		        mResult = mChoices(i)
		        mInputChar = c
		        mDone = True
		        Return
		      End If
		    Next

		    // No match — show the typed char briefly
		    mInputChar = key.Char
		    Return
		  End If

		  If key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    // If a valid key was already typed, accept it
		    If mInputChar <> "" Then
		      Var c As String = mInputChar.Lowercase
		      For i As Integer = 0 To mKeys.Count - 1
		        If mKeys(i).Lowercase = c Then
		          mResult = mChoices(i)
		          mDone = True
		          Return
		        End If
		      Next
		    End If
		    Return
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var lines() As String

		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark)
		  Var q As String = mStyle.QuestionStyle.Apply(mQuestion)

		  If Not mExpanded Then
		    // Collapsed: show hint and key list
		    Var keyList As String = BuildKeyList
		    Var hint As String = mStyle.HelpStyle.Apply("(enter h for help)")
		    Var line1 As String = prefix + " " + q + " " + hint + " " + keyList + " "
		    If mInputChar <> "" Then
		      line1 = line1 + mInputChar
		    End If
		    lines.Add(line1)
		  Else
		    // Expanded: show question then all choices
		    lines.Add(prefix + " " + q)

		    For i As Integer = 0 To mKeys.Count - 1
		      lines.Add("  " + mKeys(i) + ") " + mChoices(i))
		    Next

		    // Add help entry
		    lines.Add("  h) Help")

		    // Input line
		    Var choiceLine As String = "  Choice: "
		    If mInputChar <> "" Then
		      choiceLine = choiceLine + mInputChar
		    End If
		    lines.Add(choiceLine)
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
		    Var answer As String = mStyle.AnswerStyle.Apply(mResult)
		    lines.Add(prefix + " " + q + " " + answer)
		  End If

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildKeyList() As String
		  // Build "[y/n/h]" style key list
		  Var parts() As String
		  For i As Integer = 0 To mKeys.Count - 1
		    parts.Add(mKeys(i))
		  Next
		  parts.Add("h")
		  Return "[" + String.FromArray(parts, "/") + "]"
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjExpandPrompt — Compact Key-Based Menu Prompt

		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Shows a compact key hint until 'h' is pressed to expand.
		Each choice has a single-character shortcut key.

		Usage:
		  Var choices() As String = Array("Yes", "No")
		  Var keys() As String = Array("y", "n")
		  Var p As New XjExpandPrompt("Overwrite?", choices, keys)
		  Var result As String = p.Run
	#tag EndNote

	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChoices() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mKeys() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mExpanded As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCancelled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mResult As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInputChar As String
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
