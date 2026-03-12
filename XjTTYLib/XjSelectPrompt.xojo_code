#tag Class
Protected Class XjSelectPrompt
	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var lines() As String
		  
		  // Line 1: question with optional filter
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark)
		  Var q As String = mStyle.QuestionStyle.Apply(mQuestion)
		  Var line1 As String = prefix + " " + q
		  If mFilterEnabled And mFilterText <> "" Then
		    line1 = line1 + " " + mStyle.FilterStyle.Apply(mFilterText)
		  End If
		  lines.Add(line1)
		  
		  // Choice lines (paginated)
		  If mFilteredIndices.Count = 0 Then
		    lines.Add("  " + mStyle.DisabledStyle.Apply("(no matches)"))
		  Else
		    Var endIdx As Integer = mPageOffset + mPerPage - 1
		    If endIdx >= mFilteredIndices.Count Then
		      endIdx = mFilteredIndices.Count - 1
		    End If
		    
		    For i As Integer = mPageOffset To endIdx
		      Var actualIdx As Integer = mFilteredIndices(i)
		      Var choiceText As String = mChoices(actualIdx)
		      
		      If mDisabled(actualIdx) Then
		        lines.Add("    " + mStyle.DisabledStyle.Apply(choiceText + " (disabled)"))
		      ElseIf i = mSelectedIndex Then
		        lines.Add("  " + mStyle.ActiveStyle.Apply(XjSymbols.Marker + " " + choiceText))
		      Else
		        lines.Add("    " + choiceText)
		      End If
		    Next
		    
		    // Hint if more items exist
		    If mFilteredIndices.Count > mPerPage Then
		      lines.Add("  " + mStyle.HelpStyle.Apply("(Use arrow keys to reveal more)"))
		    End If
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
		    Var answer As String = mStyle.AnswerStyle.Apply(mChoices(mSelectedIndex))
		    lines.Add(prefix + " " + q + " " + answer)
		  End If
		  
		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(question As String, choices() As String)
		  mQuestion = question
		  
		  // Copy choices array and pre-compute lowercase
		  For i As Integer = 0 To choices.Count - 1
		    mChoices.Add(choices(i))
		    mChoicesLower.Add(choices(i).Lowercase)
		  Next
		  
		  // Initialize disabled array (all enabled)
		  For i As Integer = 0 To mChoices.Count - 1
		    mDisabled.Add(False)
		  Next
		  
		  mSelectedIndex = 0
		  mPerPage = 7
		  mPageOffset = 0
		  mFilterEnabled = True
		  mFilterText = ""
		  mDone = False
		  mCancelled = False
		  mStyle = XjPromptStyle.Default_
		  mRenderer = New XjInlineRenderer
		  
		  // Build initial filter (all items)
		  RebuildFilter
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DisableChoice(index As Integer) As XjSelectPrompt
		  If index >= 0 And index < mDisabled.Count Then
		    mDisabled(index) = True
		  End If
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureVisible()
		  // Make sure selected index is within the visible page
		  If mSelectedIndex < mPageOffset Then
		    mPageOffset = mSelectedIndex
		  ElseIf mSelectedIndex >= mPageOffset + mPerPage Then
		    mPageOffset = mSelectedIndex - mPerPage + 1
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HandleKey(key As XjKeyEvent)
		  If key.KeyCode = XjKeyEvent.KEY_ESCAPE Then
		    mCancelled = True
		    mDone = True
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_ENTER Then
		    // Select current item if we have filtered results
		    If mFilteredIndices.Count > 0 Then
		      Var actualIndex As Integer = mFilteredIndices(mSelectedIndex)
		      If Not mDisabled(actualIndex) Then
		        mSelectedIndex = actualIndex
		        mDone = True
		      End If
		    End If
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_UP Then
		    // Move up, skipping disabled items
		    If mFilteredIndices.Count = 0 Then Return
		    Var startPos As Integer = mSelectedIndex
		    Do
		      mSelectedIndex = mSelectedIndex - 1
		      If mSelectedIndex < 0 Then
		        mSelectedIndex = mFilteredIndices.Count - 1
		      End If
		      // Check if this item is enabled or we wrapped around
		      Var actualIdx As Integer = mFilteredIndices(mSelectedIndex)
		      If Not mDisabled(actualIdx) Then Exit
		      If mSelectedIndex = startPos Then Exit
		    Loop
		    EnsureVisible
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_DOWN Then
		    // Move down, skipping disabled items
		    If mFilteredIndices.Count = 0 Then Return
		    Var startPos As Integer = mSelectedIndex
		    Do
		      mSelectedIndex = mSelectedIndex + 1
		      If mSelectedIndex >= mFilteredIndices.Count Then
		        mSelectedIndex = 0
		      End If
		      Var actualIdx As Integer = mFilteredIndices(mSelectedIndex)
		      If Not mDisabled(actualIdx) Then Exit
		      If mSelectedIndex = startPos Then Exit
		    Loop
		    EnsureVisible
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_PAGEUP Then
		    mPageOffset = mPageOffset - mPerPage
		    If mPageOffset < 0 Then mPageOffset = 0
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_PAGEDOWN Then
		    mPageOffset = mPageOffset + mPerPage
		    Var maxOffset As Integer = mFilteredIndices.Count - mPerPage
		    If maxOffset < 0 Then maxOffset = 0
		    If mPageOffset > maxOffset Then mPageOffset = maxOffset
		    Return
		  End If
		  
		  If key.KeyCode = XjKeyEvent.KEY_BACKSPACE Then
		    If mFilterEnabled And mFilterText.Length > 0 Then
		      mFilterText = mFilterText.Left(mFilterText.Length - 1)
		      RebuildFilter
		    End If
		    Return
		  End If
		  
		  // Printable character for filtering
		  If mFilterEnabled And key.IsCharKey And Not key.IsCtrl Then
		    mFilterText = mFilterText + key.Char
		    RebuildFilter
		    Return
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RebuildFilter()
		  mFilteredIndices.RemoveAll
		  
		  Var filterLower As String = mFilterText.Lowercase
		  
		  For i As Integer = 0 To mChoices.Count - 1
		    If mFilterText = "" Then
		      mFilteredIndices.Add(i)
		    Else
		      If mChoicesLower(i).IndexOf(filterLower) >= 0 Then
		        mFilteredIndices.Add(i)
		      End If
		    End If
		  Next
		  
		  // Reset selection to first enabled item
		  mSelectedIndex = 0
		  mPageOffset = 0
		  
		  // Skip to first enabled item
		  If mFilteredIndices.Count > 0 Then
		    While mSelectedIndex < mFilteredIndices.Count
		      If Not mDisabled(mFilteredIndices(mSelectedIndex)) Then Exit
		      mSelectedIndex = mSelectedIndex + 1
		    Wend
		    If mSelectedIndex >= mFilteredIndices.Count Then
		      mSelectedIndex = 0
		    End If
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
		  Return mChoices(mSelectedIndex)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetFilter(enabled As Boolean) As XjSelectPrompt
		  mFilterEnabled = enabled
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetPerPage(n As Integer) As XjSelectPrompt
		  mPerPage = n
		  Return Self
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjSelectPrompt — Single-Choice Menu Prompt
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Arrow-key navigation, filtering, pagination, disabled items.
		
		Usage:
		  Var choices() As String = Array("Red", "Green", "Blue")
		  Var p As New XjSelectPrompt("Pick a color:", choices)
		  Var result As String = p.Run
	#tag EndNote


	#tag Property, Flags = &h21
		Private mCancelled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChoices() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChoicesLower() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDisabled() As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFilteredIndices() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFilterEnabled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFilterText As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPageOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPerPage As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRenderer As XjInlineRenderer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelectedIndex As Integer
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
