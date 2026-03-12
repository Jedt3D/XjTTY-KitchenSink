#tag Module
Protected Module XjTerminal
	#tag Method, Flags = &h0
		Function ColorDepth() As Integer
		  // Returns the color depth: 1 (mono), 4 (16 colors), 8 (256), 24 (true color)
		  
		  If Not SupportsColor Then Return 1
		  
		  // Check COLORTERM for true color
		  Var colorTerm As String = System.EnvironmentVariable("COLORTERM")
		  If colorTerm = "truecolor" Or colorTerm = "24bit" Then Return 24
		  
		  // Check TERM for 256 color
		  Var term As String = System.EnvironmentVariable("TERM")
		  If term.IndexOf("256color") >= 0 Then Return 8
		  
		  #If TargetWindows Then
		    // Windows Terminal supports true color
		    Var wtSession As String = System.EnvironmentVariable("WT_SESSION")
		    If wtSession <> "" Then Return 24
		    Return 4
		  #Else
		    Return 4
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DisableMouseTracking()
		  Write(XjANSI.MouseTrackingDisable)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DisableRawMode()
		  // Restore original terminal mode
		  
		  If Not mIsRawMode Then Return
		  
		  #If TargetMacOS Then
		    If mOrigTermios <> Nil Then
		      Soft Declare Function tcsetattr Lib "libSystem.B.dylib" (fd As Int32, optional_actions As Int32, termios_p As Ptr) As Int32
		      Call tcsetattr(0, 0, mOrigTermios)
		    End If
		    
		  #ElseIf TargetLinux Then
		    If mOrigTermios <> Nil Then
		      Soft Declare Function tcsetattr Lib "libc.so.6" (fd As Int32, optional_actions As Int32, termios_p As Ptr) As Int32
		      Call tcsetattr(0, 0, mOrigTermios)
		    End If
		    
		  #ElseIf TargetWindows Then
		    Soft Declare Function SetConsoleMode Lib "Kernel32" (hConsoleHandle As Ptr, dwMode As UInt32) As Boolean
		    
		    If mWinInputHandle <> Nil Then
		      Call SetConsoleMode(mWinInputHandle, mWinOrigInputMode)
		    End If
		    If mWinOutputHandle <> Nil Then
		      Call SetConsoleMode(mWinOutputHandle, mWinOrigOutputMode)
		    End If
		  #EndIf
		  
		  mIsRawMode = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnableMouseTracking()
		  Write(XjANSI.MouseTrackingEnable)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnableNonBlockingInput()
		  // Set stdin to non-blocking (VMIN=0, VTIME=1 for 100ms timeout)
		  // Call this after EnableRawMode for polling-style input
		  
		  #If TargetMacOS Then
		    Soft Declare Function tcgetattr Lib "libSystem.B.dylib" (fd As Int32, termios_p As Ptr) As Int32
		    Soft Declare Function tcsetattr Lib "libSystem.B.dylib" (fd As Int32, optional_actions As Int32, termios_p As Ptr) As Int32
		    
		    Var t As New MemoryBlock(72)
		    Call tcgetattr(0, t)
		    
		    // c_cc at offset 32: VMIN (index 16) = 0, VTIME (index 17) = 1
		    t.UInt8Value(32 + 16) = 0
		    t.UInt8Value(32 + 17) = 1
		    
		    Call tcsetattr(0, 0, t)
		    
		  #ElseIf TargetLinux Then
		    Soft Declare Function tcgetattr Lib "libc.so.6" (fd As Int32, termios_p As Ptr) As Int32
		    Soft Declare Function tcsetattr Lib "libc.so.6" (fd As Int32, optional_actions As Int32, termios_p As Ptr) As Int32
		    
		    Var t As New MemoryBlock(60)
		    Call tcgetattr(0, t)
		    
		    // c_cc at offset 17: VTIME (index 5) = 1, VMIN (index 6) = 0
		    t.UInt8Value(17 + 5) = 1
		    t.UInt8Value(17 + 6) = 0
		    
		    Call tcsetattr(0, 0, t)
		    
		  #ElseIf TargetWindows Then
		    // Windows doesn't need this — ReadFile will block/not block based on console mode
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnableRawMode()
		  // Enable raw terminal mode (unbuffered, no echo)
		  // Saves the original terminal state for later restoration
		  
		  If mIsRawMode Then Return
		  
		  #If TargetMacOS Then
		    // macOS termios: 72 bytes
		    // tcflag_t = UInt64 (unsigned long on 64-bit)
		    // NCCS = 20
		    mOrigTermios = New MemoryBlock(72)
		    
		    Soft Declare Function tcgetattr Lib "libSystem.B.dylib" (fd As Int32, termios_p As Ptr) As Int32
		    Soft Declare Function tcsetattr Lib "libSystem.B.dylib" (fd As Int32, optional_actions As Int32, termios_p As Ptr) As Int32
		    
		    If tcgetattr(0, mOrigTermios) <> 0 Then Return
		    
		    Var raw As New MemoryBlock(72)
		    raw.StringValue(0, 72) = mOrigTermios.StringValue(0, 72)
		    
		    // c_iflag at offset 0 (UInt64): clear BRKINT, ICRNL, INPCK, ISTRIP, IXON
		    Var iflag As UInt64 = raw.UInt64Value(0)
		    iflag = iflag And Not CType(&h00000332, UInt64)
		    raw.UInt64Value(0) = iflag
		    
		    // c_oflag at offset 8 (UInt64): clear OPOST
		    Var oflag As UInt64 = raw.UInt64Value(8)
		    oflag = oflag And Not CType(&h00000001, UInt64)
		    raw.UInt64Value(8) = oflag
		    
		    // c_cflag at offset 16 (UInt64): set CS8
		    Var cflag As UInt64 = raw.UInt64Value(16)
		    cflag = cflag Or CType(&h00000300, UInt64)
		    raw.UInt64Value(16) = cflag
		    
		    // c_lflag at offset 24 (UInt64): clear ECHO, ICANON, IEXTEN, ISIG
		    Var lflag As UInt64 = raw.UInt64Value(24)
		    lflag = lflag And Not CType(&h00000588, UInt64)
		    raw.UInt64Value(24) = lflag
		    
		    // c_cc at offset 32: VMIN=1 (index 16), VTIME=0 (index 17)
		    raw.UInt8Value(32 + 16) = 0
		    raw.UInt8Value(32 + 17) = 1
		    
		    // TCSANOW = 0
		    Call tcsetattr(0, 0, raw)
		    mIsRawMode = True
		    
		  #ElseIf TargetLinux Then
		    // Linux termios: 60 bytes
		    // tcflag_t = UInt32 (unsigned int)
		    // Has c_line field, NCCS = 32
		    mOrigTermios = New MemoryBlock(60)
		    
		    Soft Declare Function tcgetattr Lib "libc.so.6" (fd As Int32, termios_p As Ptr) As Int32
		    Soft Declare Function tcsetattr Lib "libc.so.6" (fd As Int32, optional_actions As Int32, termios_p As Ptr) As Int32
		    
		    If tcgetattr(0, mOrigTermios) <> 0 Then Return
		    
		    Var raw As New MemoryBlock(60)
		    raw.StringValue(0, 60) = mOrigTermios.StringValue(0, 60)
		    
		    // c_iflag at offset 0 (UInt32): clear BRKINT, ICRNL, INPCK, ISTRIP, IXON
		    Var iflag As UInt32 = raw.UInt32Value(0)
		    iflag = iflag And Not CType(&h00000532, UInt32)
		    raw.UInt32Value(0) = iflag
		    
		    // c_oflag at offset 4 (UInt32): clear OPOST
		    Var oflag As UInt32 = raw.UInt32Value(4)
		    oflag = oflag And Not CType(&h00000001, UInt32)
		    raw.UInt32Value(4) = oflag
		    
		    // c_cflag at offset 8 (UInt32): set CS8
		    Var cflag As UInt32 = raw.UInt32Value(8)
		    cflag = cflag Or CType(&h00000030, UInt32)
		    raw.UInt32Value(8) = cflag
		    
		    // c_lflag at offset 12 (UInt32): clear ECHO, ICANON, IEXTEN, ISIG
		    Var lflag As UInt32 = raw.UInt32Value(12)
		    lflag = lflag And Not CType(&h0000800B, UInt32)
		    raw.UInt32Value(12) = lflag
		    
		    // c_cc at offset 17: VMIN=1 (index 6), VTIME=0 (index 5)
		    raw.UInt8Value(17 + 5) = 1
		    raw.UInt8Value(17 + 6) = 0
		    
		    // TCSANOW = 0
		    Call tcsetattr(0, 0, raw)
		    mIsRawMode = True
		    
		  #ElseIf TargetWindows Then
		    Soft Declare Function GetStdHandle Lib "Kernel32" (nStdHandle As Int32) As Ptr
		    Soft Declare Function GetConsoleMode Lib "Kernel32" (hConsoleHandle As Ptr, ByRef lpMode As UInt32) As Boolean
		    Soft Declare Function SetConsoleMode Lib "Kernel32" (hConsoleHandle As Ptr, dwMode As UInt32) As Boolean
		    
		    // STD_INPUT_HANDLE = -10
		    mWinInputHandle = GetStdHandle(-10)
		    
		    // Save original mode
		    Var origMode As UInt32
		    Call GetConsoleMode(mWinInputHandle, origMode)
		    mWinOrigInputMode = origMode
		    
		    // Clear ENABLE_LINE_INPUT (&h2), ENABLE_ECHO_INPUT (&h4), ENABLE_PROCESSED_INPUT (&h1)
		    // Add ENABLE_VIRTUAL_TERMINAL_INPUT (&h200)
		    Var newMode As UInt32 = origMode
		    newMode = newMode And Not CType(&h7, UInt32)
		    newMode = newMode Or CType(&h200, UInt32)
		    Call SetConsoleMode(mWinInputHandle, newMode)
		    
		    // Enable VT processing on output handle
		    // STD_OUTPUT_HANDLE = -11
		    mWinOutputHandle = GetStdHandle(-11)
		    Var origOutMode As UInt32
		    Call GetConsoleMode(mWinOutputHandle, origOutMode)
		    mWinOrigOutputMode = origOutMode
		    
		    // Add ENABLE_VIRTUAL_TERMINAL_PROCESSING (&h4)
		    Call SetConsoleMode(mWinOutputHandle, origOutMode Or CType(&h4, UInt32))
		    
		    mIsRawMode = True
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnableVTProcessingWindows()
		  // Enable ANSI/VT processing on Windows output
		  // Called automatically by EnableRawMode, but can be used standalone
		  #If TargetWindows Then
		    Soft Declare Function GetStdHandle Lib "Kernel32" (nStdHandle As Int32) As Ptr
		    Soft Declare Function GetConsoleMode Lib "Kernel32" (hConsoleHandle As Ptr, ByRef lpMode As UInt32) As Boolean
		    Soft Declare Function SetConsoleMode Lib "Kernel32" (hConsoleHandle As Ptr, dwMode As UInt32) As Boolean
		    
		    Var hOut As Ptr = GetStdHandle(-11)
		    Var mode As UInt32
		    Call GetConsoleMode(hOut, mode)
		    Call SetConsoleMode(hOut, mode Or CType(&h4, UInt32))
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnterAlternateScreen()
		  // Switch to alternate screen buffer (fullscreen TUI mode)
		  Write(XjANSI.AlternateScreenEnter)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExitAlternateScreen()
		  // Return to main screen buffer
		  Write(XjANSI.AlternateScreenExit)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GetSize(ByRef width As Integer, ByRef height As Integer)
		  // Get terminal dimensions
		  
		  #If TargetMacOS Then
		    // TIOCGWINSZ = 0x40087468 on macOS
		    // winsize struct: 4 x UInt16 = 8 bytes
		    Var ws As New MemoryBlock(8)
		    
		    Soft Declare Function ioctl Lib "libSystem.B.dylib" (fd As Int32, request As UInt64, ws As Ptr) As Int32
		    
		    If ioctl(1, &h40087468, ws) = 0 Then
		      height = ws.UInt16Value(0)
		      width = ws.UInt16Value(2)
		    Else
		      width = 80
		      height = 24
		    End If
		    
		  #ElseIf TargetLinux Then
		    // TIOCGWINSZ = 0x5413 on Linux
		    Var ws As New MemoryBlock(8)
		    
		    Soft Declare Function ioctl Lib "libc.so.6" (fd As Int32, request As UInt64, ws As Ptr) As Int32
		    
		    If ioctl(1, &h5413, ws) = 0 Then
		      height = ws.UInt16Value(0)
		      width = ws.UInt16Value(2)
		    Else
		      width = 80
		      height = 24
		    End If
		    
		  #ElseIf TargetWindows Then
		    // CONSOLE_SCREEN_BUFFER_INFO struct (22 bytes)
		    // Offsets: dwSize(0,4), dwCursorPosition(4,4), wAttributes(8,2),
		    //          srWindow(10,8: Left,Top,Right,Bottom each Int16),
		    //          dwMaximumWindowSize(18,4)
		    Var info As New MemoryBlock(22)
		    
		    Soft Declare Function GetStdHandle Lib "Kernel32" (nStdHandle As Int32) As Ptr
		    Soft Declare Function GetConsoleScreenBufferInfo Lib "Kernel32" (hConsoleOutput As Ptr, lpConsoleScreenBufferInfo As Ptr) As Boolean
		    
		    Var hOut As Ptr = GetStdHandle(-11)
		    If GetConsoleScreenBufferInfo(hOut, info) Then
		      // srWindow: Left(10), Top(12), Right(14), Bottom(16)
		      Var left_ As Int16 = info.Int16Value(10)
		      Var top_ As Int16 = info.Int16Value(12)
		      Var right_ As Int16 = info.Int16Value(14)
		      Var bottom_ As Int16 = info.Int16Value(16)
		      width = right_ - left_ + 1
		      height = bottom_ - top_ + 1
		    Else
		      width = 80
		      height = 24
		    End If
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Height() As Integer
		  // Return terminal height in rows
		  Var w As Integer
		  Var h As Integer
		  Call GetSize(w, h)
		  Return h
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsRawMode() As Boolean
		  Return mIsRawMode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReadByte() As Integer
		  // Read a single byte from stdin. Returns -1 if no data available.
		  // Must be in raw mode for non-blocking behavior.
		  
		  #If TargetMacOS Then
		    Var buf As New MemoryBlock(1)
		    Soft Declare Function read_ Lib "libSystem.B.dylib" Alias "read" (fd As Int32, buf As Ptr, count As UInt64) As Int64
		    Var n As Int64 = read_(0, buf, 1)
		    If n > 0 Then
		      Return buf.UInt8Value(0)
		    Else
		      Return -1
		    End If
		    
		  #ElseIf TargetLinux Then
		    Var buf As New MemoryBlock(1)
		    Soft Declare Function read_ Lib "libc.so.6" Alias "read" (fd As Int32, buf As Ptr, count As UInt64) As Int64
		    Var n As Int64 = read_(0, buf, 1)
		    If n > 0 Then
		      Return buf.UInt8Value(0)
		    Else
		      Return -1
		    End If
		    
		  #ElseIf TargetWindows Then
		    // On Windows, use ReadFile on stdin handle
		    Soft Declare Function GetStdHandle Lib "Kernel32" (nStdHandle As Int32) As Ptr
		    Soft Declare Function ReadFile Lib "Kernel32" (hFile As Ptr, lpBuffer As Ptr, nNumberOfBytesToRead As UInt32, ByRef lpNumberOfBytesRead As UInt32, lpOverlapped As Ptr) As Boolean
		    
		    Var hIn As Ptr = GetStdHandle(-10)
		    Var buf As New MemoryBlock(1)
		    Var bytesRead As UInt32
		    
		    If ReadFile(hIn, buf, 1, bytesRead, Nil) And bytesRead > 0 Then
		      Return buf.UInt8Value(0)
		    Else
		      Return -1
		    End If
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SupportsColor() As Boolean
		  // Check if terminal supports color output
		  
		  // Check NO_COLOR environment variable (https://no-color.org)
		  If System.EnvironmentVariable("NO_COLOR") <> "" Then Return False
		  
		  // Check TERM environment variable
		  Var term As String = System.EnvironmentVariable("TERM")
		  If term = "dumb" Then Return False
		  
		  #If TargetWindows Then
		    // Windows Terminal and modern consoles support color
		    Var wtSession As String = System.EnvironmentVariable("WT_SESSION")
		    If wtSession <> "" Then Return True
		    
		    // Check if VT processing is available
		    Return True
		  #Else
		    // Most Unix terminals support color
		    If term <> "" Then Return True
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Width() As Integer
		  // Return terminal width in columns
		  Var w As Integer
		  Var h As Integer
		  Call GetSize(w, h)
		  Return w
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Write(text As String)
		  // Write text to stdout and flush
		  StdOut.Write(text)
		  StdOut.Flush
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjTerminal — Terminal Abstraction Layer
		
		Part of XjTTY-Toolkit foundation layer.
		Provides cross-platform terminal control:
		
		- Raw mode (unbuffered, no echo) via termios / Win32
		- Terminal size detection via ioctl / Win32
		- Color capability detection
		- Raw byte reading from stdin
		- Alternate screen buffer management
		- Mouse tracking control
		
		Platform support:
		- macOS: libSystem.B.dylib (termios, ioctl)
		- Linux: libc.so.6 (termios, ioctl)
		- Windows: Kernel32 (Console API)
	#tag EndNote


	#tag Property, Flags = &h21
		Private mIsRawMode As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOrigTermios As MemoryBlock
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWinInputHandle As Ptr
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWinOrigInputMode As UInt32
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWinOrigOutputMode As UInt32
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWinOutputHandle As Ptr
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
End Module
#tag EndModule
