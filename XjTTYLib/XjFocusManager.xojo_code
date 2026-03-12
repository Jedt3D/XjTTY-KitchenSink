#tag Class
Protected Class XjFocusManager
	#tag Method, Flags = &h0
		Sub BuildChain(root As XjWidget)
		  // Walk the widget tree and collect focusable widgets
		  While mFocusChain.Count > 0
		    mFocusChain.RemoveAt(0)
		  Wend
		  
		  root.CollectFocusable(mFocusChain)
		  
		  // If there are focusable widgets and none focused, focus the first
		  If mFocusChain.Count > 0 And mFocusIndex < 0 Then
		    mFocusIndex = 0
		    mFocusChain(0).SetFocused(True)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  mFocusIndex = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FocusCount() As Integer
		  Return mFocusChain.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FocusedWidget() As XjWidget
		  If mFocusIndex >= 0 And mFocusIndex < mFocusChain.Count Then
		    Return mFocusChain(mFocusIndex)
		  End If
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FocusNext()
		  If mFocusChain.Count = 0 Then Return
		  
		  // Unfocus current
		  If mFocusIndex >= 0 And mFocusIndex < mFocusChain.Count Then
		    mFocusChain(mFocusIndex).SetFocused(False)
		  End If
		  
		  // Advance
		  mFocusIndex = mFocusIndex + 1
		  If mFocusIndex >= mFocusChain.Count Then
		    mFocusIndex = 0
		  End If
		  
		  mFocusChain(mFocusIndex).SetFocused(True)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FocusPrev()
		  If mFocusChain.Count = 0 Then Return
		  
		  // Unfocus current
		  If mFocusIndex >= 0 And mFocusIndex < mFocusChain.Count Then
		    mFocusChain(mFocusIndex).SetFocused(False)
		  End If
		  
		  // Go back
		  mFocusIndex = mFocusIndex - 1
		  If mFocusIndex < 0 Then
		    mFocusIndex = mFocusChain.Count - 1
		  End If
		  
		  mFocusChain(mFocusIndex).SetFocused(True)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HandleKey(key As XjKeyEvent) As Boolean
		  // Tab / Shift+Tab cycle focus
		  If key.KeyCode = XjKeyEvent.KEY_TAB Then
		    If key.IsShift Then
		      FocusPrev
		    Else
		      FocusNext
		    End If
		    Return True
		  End If
		  
		  // BackTab (Shift+Tab on some terminals)
		  If key.KeyCode = XjKeyEvent.KEY_BACKTAB Then
		    FocusPrev
		    Return True
		  End If
		  
		  // Route to focused widget
		  If mFocusIndex >= 0 And mFocusIndex < mFocusChain.Count Then
		    Return mFocusChain(mFocusIndex).HandleKey(key)
		  End If
		  
		  Return False
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjFocusManager — Focus Cycling
		
		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Manages Tab/Shift-Tab focus cycling across focusable
		widgets in a widget tree. Routes key events to the
		currently focused widget.
		
		Usage:
		  Var fm As New XjFocusManager
		  fm.BuildChain(rootWidget)
		  // In key handler:
		  If fm.HandleKey(key) Then Return
	#tag EndNote


	#tag Property, Flags = &h21
		Private mFocusChain() As XjWidget
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFocusIndex As Integer
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
