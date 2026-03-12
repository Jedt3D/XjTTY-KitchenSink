#tag Class
Protected Class XjStyle
	#tag Method, Flags = &h0
		Sub Constructor()
		  mFG = -1
		  mBG = -1
		  mFGR = -1
		  mFGG = -1
		  mFGB = -1
		  mBGR = -1
		  mBGG = -1
		  mBGB = -1
		  mBold = False
		  mDim = False
		  mItalic = False
		  mUnderline = False
		  mBlink = False
		  mInverse = False
		  mStrikethrough = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetFG(colorCode As Integer) As XjStyle
		  // Set foreground using 16-color code (30-37, 90-97)
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mFG = colorCode
		  s.mFGR = -1
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBG(colorCode As Integer) As XjStyle
		  // Set background using 16-color code (40-47, 100-107)
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mBG = colorCode
		  s.mBGR = -1
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetFGRGB(r As Integer, g As Integer, b As Integer) As XjStyle
		  // Set foreground using 24-bit RGB
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mFG = -1
		  s.mFGR = r
		  s.mFGG = g
		  s.mFGB = b
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBGRGB(r As Integer, g As Integer, b As Integer) As XjStyle
		  // Set background using 24-bit RGB
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mBG = -1
		  s.mBGR = r
		  s.mBGG = g
		  s.mBGB = b
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBold() As XjStyle
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mBold = True
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetDim() As XjStyle
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mDim = True
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetItalic() As XjStyle
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mItalic = True
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetUnderline() As XjStyle
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mUnderline = True
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetInverse() As XjStyle
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mInverse = True
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetStrikethrough() As XjStyle
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mStrikethrough = True
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBlink() As XjStyle
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  s.mBlink = True
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToANSI() As String
		  // Generate the ANSI escape sequence for this style
		  Var codes() As Integer

		  If mBold Then codes.Add(1)
		  If mDim Then codes.Add(2)
		  If mItalic Then codes.Add(3)
		  If mUnderline Then codes.Add(4)
		  If mBlink Then codes.Add(5)
		  If mInverse Then codes.Add(7)
		  If mStrikethrough Then codes.Add(9)

		  If mFG >= 0 Then codes.Add(mFG)
		  If mBG >= 0 Then codes.Add(mBG)

		  Var result As String

		  If codes.Count > 0 Then
		    result = XjANSI.SGRMulti(codes)
		  End If

		  // Append RGB colors (these need separate sequences)
		  If mFGR >= 0 Then
		    result = result + XjANSI.FGRGB(mFGR, mFGG, mFGB)
		  End If

		  If mBGR >= 0 Then
		    result = result + XjANSI.BGRGB(mBGR, mBGG, mBGB)
		  End If

		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Apply(text As String) As String
		  // Apply this style to text with automatic reset
		  Var ansi As String = ToANSI
		  If ansi = "" Then Return text
		  Return ansi + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Equals(other As XjStyle) As Boolean
		  If other Is Nil Then Return False
		  Return mFG = other.mFG And mBG = other.mBG And _
		    mFGR = other.mFGR And mFGG = other.mFGG And mFGB = other.mFGB And _
		    mBGR = other.mBGR And mBGG = other.mBGG And mBGB = other.mBGB And _
		    mBold = other.mBold And mDim = other.mDim And _
		    mItalic = other.mItalic And mUnderline = other.mUnderline And _
		    mBlink = other.mBlink And mInverse = other.mInverse And _
		    mStrikethrough = other.mStrikethrough
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clone() As XjStyle
		  Var s As New XjStyle
		  s.CopyFrom(Self)
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CopyFrom(other As XjStyle)
		  mFG = other.mFG
		  mBG = other.mBG
		  mFGR = other.mFGR
		  mFGG = other.mFGG
		  mFGB = other.mFGB
		  mBGR = other.mBGR
		  mBGG = other.mBGG
		  mBGB = other.mBGB
		  mBold = other.mBold
		  mDim = other.mDim
		  mItalic = other.mItalic
		  mUnderline = other.mUnderline
		  mBlink = other.mBlink
		  mInverse = other.mInverse
		  mStrikethrough = other.mStrikethrough
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsEmpty() As Boolean
		  // Returns True if no styling is set
		  Return mFG < 0 And mBG < 0 And mFGR < 0 And mBGR < 0 And _
		    Not mBold And Not mDim And Not mItalic And Not mUnderline And _
		    Not mBlink And Not mInverse And Not mStrikethrough
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Default() As XjStyle
		  // Return a style with no attributes set
		  Return New XjStyle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function MakeBold() As XjStyle
		  Var s As New XjStyle
		  Return s.SetBold
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function FGColor(code As Integer) As XjStyle
		  Var s As New XjStyle
		  Return s.SetFG(code)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function BGColor(code As Integer) As XjStyle
		  Var s As New XjStyle
		  Return s.SetBG(code)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function MakeFGRGB(r As Integer, g As Integer, b As Integer) As XjStyle
		  Var s As New XjStyle
		  Return s.SetFGRGB(r, g, b)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Success() As XjStyle
		  Var s As New XjStyle
		  Return s.SetFG(XjANSI.FG_GREEN)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Warning() As XjStyle
		  Var s As New XjStyle
		  Return s.SetFG(XjANSI.FG_YELLOW)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Danger() As XjStyle
		  Var s As New XjStyle
		  Return s.SetFG(XjANSI.FG_RED)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Info() As XjStyle
		  Var s As New XjStyle
		  Return s.SetFG(XjANSI.FG_CYAN)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Muted() As XjStyle
		  Var s As New XjStyle
		  Return s.SetFG(90)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Highlight() As XjStyle
		  Var s As New XjStyle
		  Var s2 As XjStyle = s.SetFG(XjANSI.FG_WHITE).SetBold
		  Return s2
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjStyle — Composable Text Style

		Part of XjTTY-Toolkit foundation layer.
		Immutable-style builder for text styling:

		  Var s As XjStyle = XjStyle.Bold.SetFG(XjANSI.FG_RED).SetUnderline
		  Print s.Apply("Hello!")

		Supports:
		- 16-color foreground/background
		- 24-bit RGB foreground/background
		- Bold, dim, italic, underline, blink, inverse, strikethrough
		- Chainable builder pattern (each Set* returns new instance)
		- Equality comparison and cloning
		- Used by XjCell for per-character styling
	#tag EndNote

	#tag Property, Flags = &h21
		Private mFG As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBG As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFGR As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFGG As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFGB As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBGR As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBGG As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBGB As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBold As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDim As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mItalic As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUnderline As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBlink As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInverse As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStrikethrough As Boolean
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
