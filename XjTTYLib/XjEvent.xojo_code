#tag Class
Protected Class XjEvent
	#tag Method, Flags = &h0
		Sub Constructor(eventType As Integer)
		  mEventType = eventType
		  mTimestamp = System.Microseconds
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function CreateCustomEvent(name As String, data As Variant) As XjEvent
		  Var e As New XjEvent(EVENT_CUSTOM)
		  e.mCustomName = name
		  e.mCustomData = data
		  Return e
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function CreateKeyEvent(key As XjKeyEvent) As XjEvent
		  Var e As New XjEvent(EVENT_KEY)
		  e.mKey = key
		  Return e
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function CreateMouseEvent(button As Integer, x As Integer, y As Integer, action As Integer) As XjEvent
		  Var e As New XjEvent(EVENT_MOUSE)
		  e.mMouseButton = button
		  e.mMouseX = x
		  e.mMouseY = y
		  e.mMouseAction = action
		  Return e
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function CreateResizeEvent(w As Integer, h As Integer) As XjEvent
		  Var e As New XjEvent(EVENT_RESIZE)
		  e.mResizeWidth = w
		  e.mResizeHeight = h
		  Return e
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function CreateTickEvent() As XjEvent
		  Return New XjEvent(EVENT_TICK)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CustomData() As Variant
		  Return mCustomData
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CustomName() As String
		  Return mCustomName
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EventType() As Integer
		  Return mEventType
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsKeyEvent() As Boolean
		  Return mEventType = EVENT_KEY
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsMouseEvent() As Boolean
		  Return mEventType = EVENT_MOUSE
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsResizeEvent() As Boolean
		  Return mEventType = EVENT_RESIZE
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsTickEvent() As Boolean
		  Return mEventType = EVENT_TICK
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Key() As XjKeyEvent
		  Return mKey
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MouseAction() As Integer
		  Return mMouseAction
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MouseButton() As Integer
		  Return mMouseButton
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MouseX() As Integer
		  Return mMouseX
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MouseY() As Integer
		  Return mMouseY
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ResizeHeight() As Integer
		  Return mResizeHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ResizeWidth() As Integer
		  Return mResizeWidth
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Timestamp() As Double
		  Return mTimestamp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As String
		  Select Case mEventType
		  Case EVENT_KEY
		    If mKey <> Nil Then
		      Return "Key: " + mKey.KeyName
		    End If
		    Return "Key: (none)"
		  Case EVENT_MOUSE
		    Return "Mouse: btn=" + Str(mMouseButton) + " at " + Str(mMouseX) + "," + Str(mMouseY)
		  Case EVENT_RESIZE
		    Return "Resize: " + Str(mResizeWidth) + "x" + Str(mResizeHeight)
		  Case EVENT_TICK
		    Return "Tick"
		  Case EVENT_CUSTOM
		    Return "Custom: " + mCustomName
		  Case Else
		    Return "Unknown event"
		  End Select
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjEvent — Universal Event Wrapper
		
		Part of XjTTY-Toolkit Phase 1.
		Discriminated union for all event types:
		- EVENT_KEY: keyboard input (wraps XjKeyEvent)
		- EVENT_MOUSE: mouse clicks/movement
		- EVENT_RESIZE: terminal size change
		- EVENT_TICK: periodic timer tick
		- EVENT_CUSTOM: user-defined events
		
		Use factory methods to create:
		  XjEvent.CreateKeyEvent(key)
		  XjEvent.CreateResizeEvent(w, h)
		  XjEvent.CreateMouseEvent(btn, x, y, action)
	#tag EndNote


	#tag Property, Flags = &h21
		Private mCustomData As Variant
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCustomName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEventType As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mKey As XjKeyEvent
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMouseAction As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMouseButton As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMouseX As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMouseY As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mResizeHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mResizeWidth As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTimestamp As Double
	#tag EndProperty


	#tag Constant, Name = EVENT_CUSTOM, Type = Double, Dynamic = False, Default = \"5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = EVENT_KEY, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = EVENT_MOUSE, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = EVENT_RESIZE, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = EVENT_TICK, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MOUSE_MOVE, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MOUSE_PRESS, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MOUSE_RELEASE, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MOUSE_SCROLL_DOWN, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MOUSE_SCROLL_UP, Type = Double, Dynamic = False, Default = \"3", Scope = Public
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
