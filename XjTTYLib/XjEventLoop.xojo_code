#tag Class
Protected Class XjEventLoop
	#tag Method, Flags = &h0
		Sub Constructor(refreshMs As Integer = 33)
		  mRefreshMs = refreshMs
		  mIsRunning = False
		  mTickCount = 0
		  AutoRawMode = True
		  AutoAlternateScreen = False
		  AutoHideCursor = False
		  mLastWidth = 0
		  mLastHeight = 0
		  mStartTime = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ElapsedSeconds() As Double
		  If mStartTime = 0 Then Return 0
		  Return (System.Microseconds - mStartTime) / 1000000.0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsRunning() As Boolean
		  Return mIsRunning
		End Function
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h0
		Delegate Sub KeyPressHandler(key As XjKeyEvent)
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h0
		Function LastHeight() As Integer
		  Return mLastHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LastWidth() As Integer
		  Return mLastWidth
		End Function
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h0
		Delegate Sub ResizeHandler(width As Integer, height As Integer)
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h0
		Sub Run()
		  // Enter the main event loop (blocking)
		  // Automatically manages raw mode, alternate screen, cursor based on Auto* properties
		  
		  // Setup
		  If AutoRawMode Then
		    XjTerminal.EnableRawMode
		    XjTerminal.EnableNonBlockingInput
		  End If
		  
		  If AutoAlternateScreen Then
		    XjScreen.EnterFullscreen
		    XjScreen.Clear
		  ElseIf AutoHideCursor Then
		    XjCursor.Hide
		  End If
		  
		  mReader = New XjReader
		  mIsRunning = True
		  mStartTime = System.Microseconds
		  mLastWidth = XjTerminal.Width
		  mLastHeight = XjTerminal.Height
		  
		  // Main loop
		  While mIsRunning
		    
		    // 1. Poll for keyboard input
		    Var key As XjKeyEvent = mReader.ReadKey
		    If key <> Nil Then
		      If mOnKeyPress <> Nil Then mOnKeyPress.Invoke(key)
		    End If
		    
		    // 2. Check for terminal resize (polling)
		    Var w As Integer
		    Var h As Integer
		    XjTerminal.GetSize(w, h)
		    If w <> mLastWidth Or h <> mLastHeight Then
		      mLastWidth = w
		      mLastHeight = h
		      If mOnResize <> Nil Then mOnResize.Invoke(w, h)
		    End If
		    
		    // 3. Tick
		    mTickCount = mTickCount + 1
		    If mOnTick <> Nil Then mOnTick.Invoke(mTickCount)
		    
		    // 4. Yield to system
		    App.DoEvents(mRefreshMs)
		  Wend
		  
		  // Cleanup (reverse order of setup)
		  If AutoAlternateScreen Then
		    XjScreen.ExitFullscreen
		  ElseIf AutoHideCursor Then
		    XjCursor.Show
		  End If
		  
		  If AutoRawMode Then
		    XjTerminal.DisableRawMode
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetOnKeyPress(handler As XjEventLoop.KeyPressHandler)
		  mOnKeyPress = handler
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetOnResize(handler As XjEventLoop.ResizeHandler)
		  mOnResize = handler
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetOnTick(handler As XjEventLoop.TickHandler)
		  mOnTick = handler
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Stop_()
		  // Signal the event loop to stop after the current iteration
		  mIsRunning = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function TickCount() As Integer
		  Return mTickCount
		End Function
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h0
		Delegate Sub TickHandler(tickCount As Integer)
	#tag EndDelegateDeclaration


	#tag Note, Name = "About"
		XjEventLoop — Main Application Loop
		
		Part of XjTTY-Toolkit Phase 1.
		Provides a managed event loop for TUI applications:
		
		Usage:
		  Var loop As New XjEventLoop(33)  // ~30fps
		  loop.AutoAlternateScreen = True
		  loop.SetOnKeyPress(AddressOf HandleKey)
		  loop.SetOnResize(AddressOf HandleResize)
		  loop.SetOnTick(AddressOf HandleTick)
		  loop.Run  // blocks until Stop_() is called
		
		Features:
		- Automatic raw mode management
		- Optional alternate screen (fullscreen)
		- Optional cursor hiding
		- Keyboard input polling via XjReader
		- Terminal resize detection (polling)
		- Configurable refresh rate
		- Elapsed time tracking
	#tag EndNote


	#tag Property, Flags = &h0
		AutoAlternateScreen As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		AutoHideCursor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		AutoRawMode As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIsRunning As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastWidth As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOnKeyPress As XjEventLoop.KeyPressHandler
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOnResize As XjEventLoop.ResizeHandler
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOnTick As XjEventLoop.TickHandler
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mReader As XjReader
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRefreshMs As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStartTime As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTickCount As Integer
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
		#tag ViewProperty
			Name="AutoRawMode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoAlternateScreen"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AutoHideCursor"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
