#tag Class
Protected Class XjSpinner
Inherits XjWidget
	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor
		  mFrameIndex = 0
		  mMessage = ""
		  mInterval = 1
		  mTickAccumulator = 0
		  mDone = False
		  mSuccessMark = Chr(&h2714)
		  mErrorMark = Chr(&h2718)
		  mFinalMessage = ""
		  
		  // Default "line" spinner
		  mFrames.Add("|")
		  mFrames.Add("/")
		  mFrames.Add("-")
		  mFrames.Add("\")
		  
		  Var base As New XjStyle
		  mSpinnerStyle = base.SetFG(XjANSI.FG_CYAN).SetBold
		  mMessageStyle = base.SetFG(XjANSI.FG_WHITE)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Error_(message As String)
		  mDone = True
		  mFinalMessage = message
		  // Use a negative trick to flag error state
		  mFrameIndex = -1
		  mDirty = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HandleTick(tickCount As Integer)
		  If Not mDone Then
		    mTickAccumulator = mTickAccumulator + 1
		    If mTickAccumulator >= mInterval Then
		      mTickAccumulator = 0
		      mFrameIndex = mFrameIndex + 1
		      If mFrameIndex >= mFrames.Count Then
		        mFrameIndex = 0
		      End If
		      mDirty = True
		    End If
		  End If
		  
		  Super.HandleTick(tickCount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsRunning() As Boolean
		  Return Not mDone
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintContent(canvas As XjCanvas, x As Integer, y As Integer, w As Integer, h As Integer)
		  #Pragma Unused h
		  
		  If w <= 0 Then Return
		  
		  If mDone Then
		    // Show completion mark + final message
		    Var mark As String
		    Var markStyle As XjStyle
		    If mFrameIndex < 0 Then
		      // Error
		      mark = mErrorMark
		      Var base As New XjStyle
		      markStyle = base.SetFG(XjANSI.FG_RED)
		    Else
		      // Success
		      mark = mSuccessMark
		      Var base As New XjStyle
		      markStyle = base.SetFG(XjANSI.FG_GREEN)
		    End If
		    canvas.WriteText(x, y, mark, markStyle)
		    If mFinalMessage <> "" Then
		      canvas.WriteText(x + mark.Length + 1, y, mFinalMessage.Left(w - mark.Length - 1), mMessageStyle)
		    End If
		    Return
		  End If
		  
		  // Draw spinner frame + message
		  If mFrames.Count = 0 Then Return
		  
		  Var frame As String = mFrames(mFrameIndex)
		  canvas.WriteText(x, y, frame, mSpinnerStyle)
		  
		  If mMessage <> "" Then
		    Var msgX As Integer = x + frame.Length + 1
		    Var maxLen As Integer = w - frame.Length - 1
		    If maxLen > 0 Then
		      canvas.WriteText(msgX, y, mMessage.Left(maxLen), mMessageStyle)
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetErrorMark(m As String) As XjSpinner
		  mErrorMark = m
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetFormat(formatName As String) As XjSpinner
		  // Clear existing frames
		  While mFrames.Count > 0
		    mFrames.RemoveAt(0)
		  Wend
		  
		  Select Case formatName
		  Case "dots"
		    mFrames.Add(Chr(&h28F7))
		    mFrames.Add(Chr(&h28EF))
		    mFrames.Add(Chr(&h28DF))
		    mFrames.Add(Chr(&h287F))
		    mFrames.Add(Chr(&h28BF))
		    mFrames.Add(Chr(&h28FB))
		    mFrames.Add(Chr(&h28FD))
		    mFrames.Add(Chr(&h28FE))
		    
		  Case "dots2"
		    mFrames.Add(Chr(&h28FE))
		    mFrames.Add(Chr(&h28FD))
		    mFrames.Add(Chr(&h28FB))
		    mFrames.Add(Chr(&h28BF))
		    mFrames.Add(Chr(&h287F))
		    mFrames.Add(Chr(&h28DF))
		    mFrames.Add(Chr(&h28EF))
		    mFrames.Add(Chr(&h28F7))
		    
		  Case "dots3"
		    mFrames.Add(".")
		    mFrames.Add("..")
		    mFrames.Add("...")
		    mFrames.Add("")
		    
		  Case "line"
		    mFrames.Add("|")
		    mFrames.Add("/")
		    mFrames.Add("-")
		    mFrames.Add("\")
		    
		  Case "arc"
		    mFrames.Add(Chr(&h25DC))
		    mFrames.Add(Chr(&h25DD))
		    mFrames.Add(Chr(&h25DE))
		    mFrames.Add(Chr(&h25DF))
		    
		  Case "star"
		    mFrames.Add(Chr(&h2736))
		    mFrames.Add(Chr(&h2738))
		    mFrames.Add(Chr(&h2734))
		    mFrames.Add(Chr(&h2733))
		    
		  Case "bounce"
		    mFrames.Add(Chr(&h2801))
		    mFrames.Add(Chr(&h2802))
		    mFrames.Add(Chr(&h2804))
		    mFrames.Add(Chr(&h2840))
		    mFrames.Add(Chr(&h2880))
		    mFrames.Add(Chr(&h2820))
		    mFrames.Add(Chr(&h2810))
		    mFrames.Add(Chr(&h2808))
		    
		  Case "arrow"
		    mFrames.Add(Chr(&h2190))
		    mFrames.Add(Chr(&h2196))
		    mFrames.Add(Chr(&h2191))
		    mFrames.Add(Chr(&h2197))
		    mFrames.Add(Chr(&h2192))
		    mFrames.Add(Chr(&h2198))
		    mFrames.Add(Chr(&h2193))
		    mFrames.Add(Chr(&h2199))
		    
		  Case "clock"
		    mFrames.Add(Chr(&h1F55B))
		    mFrames.Add(Chr(&h1F550))
		    mFrames.Add(Chr(&h1F551))
		    mFrames.Add(Chr(&h1F552))
		    mFrames.Add(Chr(&h1F553))
		    mFrames.Add(Chr(&h1F554))
		    mFrames.Add(Chr(&h1F555))
		    mFrames.Add(Chr(&h1F556))
		    mFrames.Add(Chr(&h1F557))
		    mFrames.Add(Chr(&h1F558))
		    mFrames.Add(Chr(&h1F559))
		    mFrames.Add(Chr(&h1F55A))
		    
		  Case "moon"
		    mFrames.Add(Chr(&h1F311))
		    mFrames.Add(Chr(&h1F312))
		    mFrames.Add(Chr(&h1F313))
		    mFrames.Add(Chr(&h1F314))
		    mFrames.Add(Chr(&h1F315))
		    mFrames.Add(Chr(&h1F316))
		    mFrames.Add(Chr(&h1F317))
		    mFrames.Add(Chr(&h1F318))
		    
		  Case "bar"
		    mFrames.Add("[    ]")
		    mFrames.Add("[=   ]")
		    mFrames.Add("[==  ]")
		    mFrames.Add("[=== ]")
		    mFrames.Add("[ ===]")
		    mFrames.Add("[  ==]")
		    mFrames.Add("[   =]")
		    mFrames.Add("[    ]")
		    
		  Case "blocks"
		    mFrames.Add(Chr(&h2581))
		    mFrames.Add(Chr(&h2582))
		    mFrames.Add(Chr(&h2583))
		    mFrames.Add(Chr(&h2584))
		    mFrames.Add(Chr(&h2585))
		    mFrames.Add(Chr(&h2586))
		    mFrames.Add(Chr(&h2587))
		    mFrames.Add(Chr(&h2588))
		    mFrames.Add(Chr(&h2587))
		    mFrames.Add(Chr(&h2586))
		    mFrames.Add(Chr(&h2585))
		    mFrames.Add(Chr(&h2584))
		    mFrames.Add(Chr(&h2583))
		    mFrames.Add(Chr(&h2582))
		    
		  Case Else
		    // Default to line
		    mFrames.Add("|")
		    mFrames.Add("/")
		    mFrames.Add("-")
		    mFrames.Add("\")
		    
		  End Select
		  
		  mFrameIndex = 0
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetFrames(frames() As String) As XjSpinner
		  While mFrames.Count > 0
		    mFrames.RemoveAt(0)
		  Wend
		  For i As Integer = 0 To frames.Count - 1
		    mFrames.Add(frames(i))
		  Next
		  mFrameIndex = 0
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetInterval(ticks As Integer) As XjSpinner
		  mInterval = ticks
		  If mInterval < 1 Then mInterval = 1
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMessage(m As String) As XjSpinner
		  mMessage = m
		  mDirty = True
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMessageStyle(s As XjStyle) As XjSpinner
		  mMessageStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetSpinnerStyle(s As XjStyle) As XjSpinner
		  mSpinnerStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetSuccessMark(m As String) As XjSpinner
		  mSuccessMark = m
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Success(message As String)
		  mDone = True
		  mFinalMessage = message
		  mDirty = True
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjSpinner — Animated Spinner Widget
		
		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Animated spinner with 12+ built-in formats, custom frames,
		success/error completion marks.
		
		Built-in formats: dots, dots2, dots3, line, arc, star,
		bounce, arrow, clock, moon, bar, blocks.
		
		Usage:
		  Var sp As New XjSpinner
		  Call sp.SetFormat("dots")
		  Call sp.SetMessage("Loading...")
		  // Later:
		  sp.Success("Done!")
	#tag EndNote


	#tag Property, Flags = &h21
		Private mDone As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mErrorMark As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFinalMessage As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFrameIndex As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFrames() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInterval As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMessage As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMessageStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSpinnerStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSuccessMark As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTickAccumulator As Integer
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
