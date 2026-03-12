#tag Class
Protected Class XjKeyEvent
	#tag Method, Flags = &h0
		Function Char() As String
		  Return mChar
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(keyCode As Integer, char As String, ctrl As Boolean, alt As Boolean, shift As Boolean)
		  mKeyCode = keyCode
		  mChar = char
		  mCtrl = ctrl
		  mAlt = alt
		  mShift = shift
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsAlt() As Boolean
		  Return mAlt
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsArrow() As Boolean
		  Return mKeyCode >= KEY_UP And mKeyCode <= KEY_LEFT
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsBackspace() As Boolean
		  Return mKeyCode = KEY_BACKSPACE
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsCharKey() As Boolean
		  // Returns True if this is a printable character
		  Return mKeyCode = KEY_CHAR And mChar <> ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsCtrl() As Boolean
		  Return mCtrl
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsEnter() As Boolean
		  Return mKeyCode = KEY_ENTER
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsEscape() As Boolean
		  Return mKeyCode = KEY_ESCAPE
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsShift() As Boolean
		  Return mShift
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsTab() As Boolean
		  Return mKeyCode = KEY_TAB
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function KeyCode() As Integer
		  Return mKeyCode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function KeyName() As String
		  // Human-readable name for this key
		  Var prefix As String
		  If mCtrl Then prefix = prefix + "Ctrl+"
		  If mAlt Then prefix = prefix + "Alt+"
		  If mShift Then prefix = prefix + "Shift+"
		  
		  Select Case mKeyCode
		  Case KEY_CHAR
		    If mCtrl And mChar.Length = 1 Then
		      // Ctrl+letter: show the letter
		      Var code As Integer = Asc(mChar)
		      If code >= 1 And code <= 26 Then
		        Return prefix + Chr(code + 64)
		      End If
		    End If
		    Return prefix + mChar
		  Case KEY_ENTER
		    Return prefix + "Enter"
		  Case KEY_ESCAPE
		    Return prefix + "Escape"
		  Case KEY_TAB
		    Return prefix + "Tab"
		  Case KEY_BACKTAB
		    Return prefix + "BackTab"
		  Case KEY_BACKSPACE
		    Return prefix + "Backspace"
		  Case KEY_DELETE
		    Return prefix + "Delete"
		  Case KEY_UP
		    Return prefix + "Up"
		  Case KEY_DOWN
		    Return prefix + "Down"
		  Case KEY_RIGHT
		    Return prefix + "Right"
		  Case KEY_LEFT
		    Return prefix + "Left"
		  Case KEY_HOME
		    Return prefix + "Home"
		  Case KEY_END_
		    Return prefix + "End"
		  Case KEY_PAGEUP
		    Return prefix + "PageUp"
		  Case KEY_PAGEDOWN
		    Return prefix + "PageDown"
		  Case KEY_INSERT
		    Return prefix + "Insert"
		  Case KEY_F1
		    Return prefix + "F1"
		  Case KEY_F2
		    Return prefix + "F2"
		  Case KEY_F3
		    Return prefix + "F3"
		  Case KEY_F4
		    Return prefix + "F4"
		  Case KEY_F5
		    Return prefix + "F5"
		  Case KEY_F6
		    Return prefix + "F6"
		  Case KEY_F7
		    Return prefix + "F7"
		  Case KEY_F8
		    Return prefix + "F8"
		  Case KEY_F9
		    Return prefix + "F9"
		  Case KEY_F10
		    Return prefix + "F10"
		  Case KEY_F11
		    Return prefix + "F11"
		  Case KEY_F12
		    Return prefix + "F12"
		  Case Else
		    Return prefix + "Unknown(" + Str(mKeyCode) + ")"
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As String
		  Return KeyName
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjKeyEvent — Keyboard Event Representation
		
		Part of XjTTY-Toolkit foundation layer.
		Represents a single key press with:
		- Key code (KEY_* constants)
		- Character value (for printable keys)
		- Modifier state (Ctrl, Alt, Shift)
		- Human-readable name via KeyName()
	#tag EndNote


	#tag Property, Flags = &h21
		Private mAlt As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChar As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCtrl As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mKeyCode As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShift As Boolean
	#tag EndProperty


	#tag Constant, Name = KEY_BACKSPACE, Type = Double, Dynamic = False, Default = \"5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_BACKTAB, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_CHAR, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_DELETE, Type = Double, Dynamic = False, Default = \"6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_DOWN, Type = Double, Dynamic = False, Default = \"11", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_END_, Type = Double, Dynamic = False, Default = \"15", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_ENTER, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_ESCAPE, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F1, Type = Double, Dynamic = False, Default = \"20", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F10, Type = Double, Dynamic = False, Default = \"29", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F11, Type = Double, Dynamic = False, Default = \"30", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F12, Type = Double, Dynamic = False, Default = \"31", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F2, Type = Double, Dynamic = False, Default = \"21", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F3, Type = Double, Dynamic = False, Default = \"22", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F4, Type = Double, Dynamic = False, Default = \"23", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F5, Type = Double, Dynamic = False, Default = \"24", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F6, Type = Double, Dynamic = False, Default = \"25", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F7, Type = Double, Dynamic = False, Default = \"26", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F8, Type = Double, Dynamic = False, Default = \"27", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_F9, Type = Double, Dynamic = False, Default = \"28", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_HOME, Type = Double, Dynamic = False, Default = \"14", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_INSERT, Type = Double, Dynamic = False, Default = \"18", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_LEFT, Type = Double, Dynamic = False, Default = \"13", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_PAGEDOWN, Type = Double, Dynamic = False, Default = \"17", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_PAGEUP, Type = Double, Dynamic = False, Default = \"16", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_RIGHT, Type = Double, Dynamic = False, Default = \"12", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_TAB, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KEY_UP, Type = Double, Dynamic = False, Default = \"10", Scope = Public
	#tag EndConstant


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
