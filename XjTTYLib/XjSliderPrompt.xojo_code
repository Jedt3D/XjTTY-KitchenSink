#tag Class
Protected Class XjSliderPrompt
	#tag Method, Flags = &h0
		Sub Constructor(question As String, min As Integer, max As Integer, step_ As Integer, defaultValue As Integer)
		  mQuestion = question
		  mMin = min
		  mMax = max
		  mStep = step_
		  mValue = defaultValue
		  mDone = False
		  mStyle = XjPromptStyle.Default_
		  mRenderer = New XjInlineRenderer

		  // Clamp default value
		  If mValue < mMin Then mValue = mMin
		  If mValue > mMax Then mValue = mMax
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run() As Integer
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

		  Return mValue
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
		    mDone = True
		    Return
		  End If

		  // Left or Down decrease
		  If key.KeyCode = XjKeyEvent.KEY_LEFT Or key.KeyCode = XjKeyEvent.KEY_DOWN Then
		    mValue = mValue - mStep
		    If mValue < mMin Then mValue = mMin
		    Return
		  End If

		  // Right or Up increase
		  If key.KeyCode = XjKeyEvent.KEY_RIGHT Or key.KeyCode = XjKeyEvent.KEY_UP Then
		    mValue = mValue + mStep
		    If mValue > mMax Then mValue = mMax
		    Return
		  End If

		  // Home goes to min
		  If key.KeyCode = XjKeyEvent.KEY_HOME Then
		    mValue = mMin
		    Return
		  End If

		  // End goes to max
		  If key.KeyCode = XjKeyEvent.KEY_END_ Then
		    mValue = mMax
		    Return
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var lines() As String

		  // Line 1: "? Question:"
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)

		  // Build slider track
		  Var trackWidth As Integer = 30
		  Var range As Integer = mMax - mMin
		  Var filledWidth As Integer
		  If range > 0 Then
		    filledWidth = ((mValue - mMin) * trackWidth) / range
		  Else
		    filledWidth = 0
		  End If
		  If filledWidth < 0 Then filledWidth = 0
		  If filledWidth > trackWidth Then filledWidth = trackWidth

		  Var emptyWidth As Integer = trackWidth - filledWidth

		  // Build track string using block characters
		  Var filledBlock As String = Chr(&h2588)
		  Var emptyBlock As String = Chr(&h2591)

		  Var filledPart As String
		  For i As Integer = 1 To filledWidth
		    filledPart = filledPart + filledBlock
		  Next

		  Var emptyPart As String
		  For i As Integer = 1 To emptyWidth
		    emptyPart = emptyPart + emptyBlock
		  Next

		  Var styledFilled As String = mStyle.ActiveStyle.Apply(filledPart)
		  Var styledEmpty As String = mStyle.HelpStyle.Apply(emptyPart)
		  Var valueText As String = mStyle.AnswerStyle.Apply(Str(mValue))

		  lines.Add(prefix + question + " " + styledFilled + styledEmpty + " " + valueText)

		  // Line 2: hint
		  Var hint As String = mStyle.HelpStyle.Apply("(Use arrow keys, Enter to confirm)")
		  lines.Add("  " + hint)

		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildSettledLines() As String()
		  Var lines() As String

		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.Check) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)
		  Var styledValue As String = mStyle.AnswerStyle.Apply(Str(mValue))

		  lines.Add(prefix + question + " " + styledValue)

		  Return lines
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjSliderPrompt — Numeric Range Slider Prompt

		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Inline prompt for numeric value selection with visual slider track.

		Usage:
		  Var prompt As New XjSliderPrompt("Volume:", 0, 100, 5, 50)
		  Var vol As Integer = prompt.Run

		Features:
		- Visual slider track with filled/empty blocks
		- Left/Down to decrease, Right/Up to increase
		- Home/End for min/max
		- Configurable step size
		- Enter to confirm
		- Escape/Ctrl+C to accept current value
		- Styled output with XjPromptStyle
	#tag EndNote

	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMin As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMax As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStep As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValue As Integer
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
