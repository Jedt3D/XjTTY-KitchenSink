#tag Module
Protected Module XjColor
	#tag Method, Flags = &h0
		Function Colorize(text As String, fgColor As Integer, bgColor As Integer, isBold As Boolean, isItalic As Boolean, isUnderline As Boolean) As String
		  // Apply color and style to text with automatic reset
		  Var parts() As String

		  If isBold Then parts.Add(XjANSI.Bold)
		  If isItalic Then parts.Add(XjANSI.Italic)
		  If isUnderline Then parts.Add(XjANSI.Underline)
		  If fgColor >= 0 Then parts.Add(XjANSI.FG(fgColor))
		  If bgColor >= 0 Then parts.Add(XjANSI.BG(bgColor))

		  parts.Add(text)
		  parts.Add(XjANSI.Reset)

		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Black(text As String) As String
		  Return Colorize(text, XjANSI.FG_BLACK, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Red(text As String) As String
		  Return Colorize(text, XjANSI.FG_RED, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Green(text As String) As String
		  Return Colorize(text, XjANSI.FG_GREEN, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Yellow(text As String) As String
		  Return Colorize(text, XjANSI.FG_YELLOW, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Blue(text As String) As String
		  Return Colorize(text, XjANSI.FG_BLUE, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Magenta(text As String) As String
		  Return Colorize(text, XjANSI.FG_MAGENTA, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Cyan(text As String) As String
		  Return Colorize(text, XjANSI.FG_CYAN, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function White(text As String) As String
		  Return Colorize(text, XjANSI.FG_WHITE, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BrightRed(text As String) As String
		  Return Colorize(text, XjANSI.FG_BRIGHT_RED, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BrightGreen(text As String) As String
		  Return Colorize(text, XjANSI.FG_BRIGHT_GREEN, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BrightYellow(text As String) As String
		  Return Colorize(text, XjANSI.FG_BRIGHT_YELLOW, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BrightBlue(text As String) As String
		  Return Colorize(text, XjANSI.FG_BRIGHT_BLUE, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BrightMagenta(text As String) As String
		  Return Colorize(text, XjANSI.FG_BRIGHT_MAGENTA, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BrightCyan(text As String) As String
		  Return Colorize(text, XjANSI.FG_BRIGHT_CYAN, -1, False, False, False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BoldText(text As String) As String
		  Return XjANSI.Bold + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ItalicText(text As String) As String
		  Return XjANSI.Italic + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UnderlineText(text As String) As String
		  Return XjANSI.Underline + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DimText(text As String) As String
		  Return XjANSI.Dim_ + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InverseText(text As String) As String
		  Return XjANSI.Inverse + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StrikethroughText(text As String) As String
		  Return XjANSI.Strikethrough + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RGB(text As String, r As Integer, g As Integer, b As Integer) As String
		  // Apply 24-bit true color foreground
		  Return XjANSI.FGRGB(r, g, b) + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RGBBG(text As String, fgR As Integer, fgG As Integer, fgB As Integer, bgR As Integer, bgG As Integer, bgB As Integer) As String
		  // Apply 24-bit true color foreground and background
		  Return XjANSI.FGRGB(fgR, fgG, fgB) + XjANSI.BGRGB(bgR, bgG, bgB) + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Color256(text As String, index As Integer) As String
		  // Apply 256-color foreground
		  Return XjANSI.FG256(index) + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnRed(text As String) As String
		  Return XjANSI.BG(XjANSI.BG_RED) + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnGreen(text As String) As String
		  Return XjANSI.BG(XjANSI.BG_GREEN) + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnBlue(text As String) As String
		  Return XjANSI.BG(XjANSI.BG_BLUE) + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnYellow(text As String) As String
		  Return XjANSI.BG(XjANSI.BG_YELLOW) + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnWhite(text As String) As String
		  Return XjANSI.BG(XjANSI.BG_WHITE) + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OnBlack(text As String) As String
		  Return XjANSI.BG(XjANSI.BG_BLACK) + text + XjANSI.Reset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Success(text As String) As String
		  Return Green(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Warning(text As String) As String
		  Return Yellow(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Error_(text As String) As String
		  Return Red(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Info(text As String) As String
		  Return Cyan(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Muted(text As String) As String
		  Return DimText(text)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Gradient(text As String, fromR As Integer, fromG As Integer, fromB As Integer, toR As Integer, toG As Integer, toB As Integer) As String
		  // Apply a horizontal gradient across text characters
		  If text.Length = 0 Then Return ""

		  Var parts() As String
		  Var length As Integer = text.Length

		  For i As Integer = 0 To length - 1
		    Var t As Double = If(length > 1, i / (length - 1), 0.0)
		    Var r As Integer = CType(fromR + (toR - fromR) * t, Integer)
		    Var g As Integer = CType(fromG + (toG - fromG) * t, Integer)
		    Var b As Integer = CType(fromB + (toB - fromB) * t, Integer)
		    parts.Add(XjANSI.FGRGB(r, g, b) + text.Middle(i, 1))
		  Next

		  parts.Add(XjANSI.Reset)
		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjColor — Terminal Color and Text Styling

		Part of XjTTY-Toolkit foundation layer.
		Provides convenient color/style functions:

		- Named colors: Red(), Green(), Blue(), etc.
		- Bright colors: BrightRed(), BrightGreen(), etc.
		- Background colors: OnRed(), OnGreen(), etc.
		- Text styles: BoldText(), ItalicText(), UnderlineText()
		- 256-color: Color256()
		- True color: RGB(), RGBBG()
		- Gradient text: Gradient()
		- Semantic colors: Success(), Warning(), Error_(), Info()
		- Custom: Colorize() with full control

		All functions automatically reset styling after the text.
	#tag EndNote


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
