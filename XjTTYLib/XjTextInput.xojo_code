#tag Class
Protected Class XjTextInput
Inherits XjWidget
	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor
		  mFocusable = True
		  mValue = ""
		  mCursorPos = 0
		  mScrollOffset = 0
		  mPlaceholder = ""
		  mMaxLength = -1
		  mMask = ""
		  mLabel = ""

		  Var base As New XjStyle
		  mPlaceholderStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  mCursorStyle = base.SetInverse
		  mLabelStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE).SetBold
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetValue(v As String) As XjTextInput
		  mValue = v
		  If mCursorPos > mValue.Length Then mCursorPos = mValue.Length
		  mDirty = True
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value() As String
		  Return mValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetPlaceholder(p As String) As XjTextInput
		  mPlaceholder = p
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMask(m As String) As XjTextInput
		  mMask = m
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMaxLength(n As Integer) As XjTextInput
		  mMaxLength = n
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetLabel(l As String, style As XjStyle) As XjTextInput
		  mLabel = l
		  mLabelStyle = style
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetPlaceholderStyle(s As XjStyle) As XjTextInput
		  mPlaceholderStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetCursorStyle(s As XjStyle) As XjTextInput
		  mCursorStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HandleKey(key As XjKeyEvent) As Boolean
		  If Not mFocused Then Return False

		  Select Case key.KeyCode

		  Case XjKeyEvent.KEY_CHAR
		    If key.IsCtrl Then
		      // Ctrl+A = home
		      If key.Char = Chr(1) Then
		        mCursorPos = 0
		        mDirty = True
		        Return True
		      End If
		      // Ctrl+E = end
		      If key.Char = Chr(5) Then
		        mCursorPos = mValue.Length
		        mDirty = True
		        Return True
		      End If
		      // Ctrl+K = delete to end
		      If key.Char = Chr(11) Then
		        mValue = mValue.Left(mCursorPos)
		        mDirty = True
		        Return True
		      End If
		      // Ctrl+U = delete to start
		      If key.Char = Chr(21) Then
		        mValue = mValue.Middle(mCursorPos)
		        mCursorPos = 0
		        mDirty = True
		        Return True
		      End If
		      Return False
		    End If

		    // Insert printable character
		    If key.Char <> "" Then
		      If mMaxLength >= 0 And mValue.Length >= mMaxLength Then Return True
		      mValue = mValue.Left(mCursorPos) + key.Char + mValue.Middle(mCursorPos)
		      mCursorPos = mCursorPos + 1
		      mDirty = True
		      Return True
		    End If

		  Case XjKeyEvent.KEY_BACKSPACE
		    If mCursorPos > 0 Then
		      mValue = mValue.Left(mCursorPos - 1) + mValue.Middle(mCursorPos)
		      mCursorPos = mCursorPos - 1
		      mDirty = True
		    End If
		    Return True

		  Case XjKeyEvent.KEY_DELETE
		    If mCursorPos < mValue.Length Then
		      mValue = mValue.Left(mCursorPos) + mValue.Middle(mCursorPos + 1)
		      mDirty = True
		    End If
		    Return True

		  Case XjKeyEvent.KEY_LEFT
		    If mCursorPos > 0 Then
		      mCursorPos = mCursorPos - 1
		      mDirty = True
		    End If
		    Return True

		  Case XjKeyEvent.KEY_RIGHT
		    If mCursorPos < mValue.Length Then
		      mCursorPos = mCursorPos + 1
		      mDirty = True
		    End If
		    Return True

		  Case XjKeyEvent.KEY_HOME
		    mCursorPos = 0
		    mDirty = True
		    Return True

		  Case XjKeyEvent.KEY_END_
		    mCursorPos = mValue.Length
		    mDirty = True
		    Return True

		  End Select

		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintContent(canvas As XjCanvas, x As Integer, y As Integer, w As Integer, h As Integer)
		  #Pragma Unused h

		  Var drawX As Integer = x
		  Var drawW As Integer = w

		  // Draw label
		  If mLabel <> "" Then
		    canvas.WriteText(drawX, y, mLabel, mLabelStyle)
		    drawX = drawX + mLabel.Length
		    drawW = drawW - mLabel.Length
		    If drawW <= 0 Then Return
		  End If

		  // Build display text
		  Var displayText As String
		  If mMask <> "" Then
		    // Masked input (password)
		    Var maskParts() As String
		    For i As Integer = 0 To mValue.Length - 1
		      maskParts.Add(mMask)
		    Next
		    displayText = String.FromArray(maskParts, "")
		  Else
		    displayText = mValue
		  End If

		  // Show placeholder if empty and not focused
		  If mValue = "" And Not mFocused Then
		    canvas.WriteText(drawX, y, mPlaceholder.Left(drawW), mPlaceholderStyle)
		    Return
		  End If

		  // Calculate scroll offset so cursor is visible
		  If mCursorPos < mScrollOffset Then
		    mScrollOffset = mCursorPos
		  End If
		  If mCursorPos >= mScrollOffset + drawW Then
		    mScrollOffset = mCursorPos - drawW + 1
		  End If

		  // Draw visible portion of text
		  Var visible As String = displayText.Middle(mScrollOffset, drawW)
		  canvas.WriteText(drawX, y, visible, mStyle)

		  // Draw cursor if focused
		  If mFocused Then
		    Var cursorScreenPos As Integer = drawX + mCursorPos - mScrollOffset
		    If cursorScreenPos >= drawX And cursorScreenPos < drawX + drawW Then
		      Var cursorChar As String
		      If mCursorPos < displayText.Length Then
		        cursorChar = displayText.Middle(mCursorPos, 1)
		      Else
		        cursorChar = " "
		      End If
		      canvas.SetCell(cursorScreenPos, y, cursorChar, mCursorStyle)
		    End If
		  End If
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjTextInput — Single-Line Text Input Widget

		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Interactive text input with cursor, scrolling, placeholder,
		mask (for passwords), and label.

		Usage:
		  Var input As New XjTextInput
		  Call input.SetPlaceholder("Type here...")
		  Call input.SetLabel("Name: ", labelStyle)
		  Call input.SetBorder(0, borderStyle)
	#tag EndNote

	#tag Property, Flags = &h21
		Private mValue As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCursorPos As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScrollOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPlaceholder As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPlaceholderStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCursorStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMaxLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMask As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLabel As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLabelStyle As XjStyle
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
