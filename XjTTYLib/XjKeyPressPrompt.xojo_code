#tag Class
Protected Class XjKeyPressPrompt
	#tag Method, Flags = &h21
		Private Function BuildLines() As String()
		  Var lines() As String
		  
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.QuestionMark) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)
		  
		  Var hint As String
		  If mTimeoutMs >= 0 Then
		    Var seconds As Double = mTimeoutMs / 1000.0
		    hint = " " + mStyle.HelpStyle.Apply("(timeout: " + Str(seconds, "#0.#") + "s)")
		  End If
		  
		  lines.Add(prefix + question + hint + " " + mStyle.CursorStyle.Apply(" "))
		  
		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildSettledLines() As String()
		  Var lines() As String
		  
		  Var prefix As String = mStyle.PrefixStyle.Apply(XjSymbols.Check) + " "
		  Var question As String = mStyle.QuestionStyle.Apply(mQuestion)
		  
		  Var keyName As String
		  If mResult <> Nil Then
		    keyName = mResult.KeyName
		  Else
		    keyName = "(timeout)"
		  End If
		  Var styledKey As String = mStyle.AnswerStyle.Apply(keyName)
		  
		  lines.Add(prefix + question + " " + styledKey)
		  
		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(question As String, timeoutMs As Integer = -1)
		  mQuestion = question
		  mTimeoutMs = timeoutMs
		  mResult = Nil
		  mStyle = XjPromptStyle.Default_
		  mRenderer = New XjInlineRenderer
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run() As XjKeyEvent
		  XjSymbols.EnsureInit
		  mRenderer.Begin
		  
		  // Render prompt
		  Var lines() As String = BuildLines
		  mRenderer.Render(lines)
		  
		  // Wait for key or timeout
		  Var startTime As Double = Microseconds
		  Var timeoutMicro As Double = mTimeoutMs * 1000.0
		  
		  Do
		    Var key As XjKeyEvent = mRenderer.ReadKey
		    If key <> Nil Then
		      mResult = key
		      Exit
		    End If
		    
		    // Check timeout if enabled
		    If mTimeoutMs >= 0 Then
		      Var elapsed As Double = Microseconds - startTime
		      If elapsed >= timeoutMicro Then
		        Exit
		      End If
		    End If
		  Loop
		  
		  // Render settled state
		  Var settled() As String = BuildSettledLines
		  mRenderer.RenderSettled(settled)
		  mRenderer.End_
		  
		  Return mResult
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjKeyPressPrompt — Single Key Capture Prompt
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Inline prompt that captures a single key press.
		
		Usage:
		  Var prompt As New XjKeyPressPrompt("Press any key:")
		  Var key As XjKeyEvent = prompt.Run
		
		  // With timeout (5 seconds)
		  Var prompt2 As New XjKeyPressPrompt("Press a key:", 5000)
		  Var key2 As XjKeyEvent = prompt2.Run
		  // key2 is Nil if timed out
		
		Features:
		- Captures any single key press
		- Optional timeout in milliseconds (-1 = no timeout)
		- Shows key name in settled state
		- Shows "(timeout)" if timed out
		- Styled output with XjPromptStyle
	#tag EndNote


	#tag Property, Flags = &h21
		Private mQuestion As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRenderer As XjInlineRenderer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mResult As XjKeyEvent
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStyle As XjPromptStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTimeoutMs As Integer
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
