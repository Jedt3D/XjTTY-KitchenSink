#tag Module
Protected Module XjANSI
	#tag Method, Flags = &h0
		Function ESC() As String
		  // The escape character (0x1B = 27)
		  Return Chr(27)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CSI() As String
		  // Control Sequence Introducer: ESC [
		  Return Chr(27) + "["
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OSC() As String
		  // Operating System Command: ESC ]
		  Return Chr(27) + "]"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ST() As String
		  // String Terminator: ESC \
		  Return Chr(27) + "\"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SGR(code As Integer) As String
		  // Select Graphic Rendition: CSI {code} m
		  Return CSI + Str(code) + "m"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SGRMulti(codes() As Integer) As String
		  // Multiple SGR codes: CSI {code1};{code2};... m
		  Var parts() As String
		  For i As Integer = 0 To codes.Count - 1
		    parts.Add(Str(codes(i)))
		  Next
		  Return CSI + String.FromArray(parts, ";") + "m"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Reset() As String
		  // Reset all attributes
		  Return SGR(0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Bold() As String
		  Return SGR(1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Dim_() As String
		  Return SGR(2)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Italic() As String
		  Return SGR(3)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Underline() As String
		  Return SGR(4)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Blink() As String
		  Return SGR(5)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Inverse() As String
		  Return SGR(7)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Hidden() As String
		  Return SGR(8)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Strikethrough() As String
		  Return SGR(9)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BoldOff() As String
		  Return SGR(22)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ItalicOff() As String
		  Return SGR(23)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function UnderlineOff() As String
		  Return SGR(24)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InverseOff() As String
		  Return SGR(27)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FG(colorCode As Integer) As String
		  // Standard foreground color (30-37, 90-97)
		  Return SGR(colorCode)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BG(colorCode As Integer) As String
		  // Standard background color (40-47, 100-107)
		  Return SGR(colorCode)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FG256(index As Integer) As String
		  // 256-color foreground: CSI 38;5;{index} m
		  Return CSI + "38;5;" + Str(index) + "m"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BG256(index As Integer) As String
		  // 256-color background: CSI 48;5;{index} m
		  Return CSI + "48;5;" + Str(index) + "m"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FGRGB(r As Integer, g As Integer, b As Integer) As String
		  // 24-bit true color foreground: CSI 38;2;{r};{g};{b} m
		  Return CSI + "38;2;" + Str(r) + ";" + Str(g) + ";" + Str(b) + "m"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BGRGB(r As Integer, g As Integer, b As Integer) As String
		  // 24-bit true color background: CSI 48;2;{r};{g};{b} m
		  Return CSI + "48;2;" + Str(r) + ";" + Str(g) + ";" + Str(b) + "m"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DefaultFG() As String
		  // Reset foreground to default
		  Return SGR(39)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DefaultBG() As String
		  // Reset background to default
		  Return SGR(49)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorUp(n As Integer) As String
		  // Move cursor up n lines: CSI {n} A
		  If n <= 0 Then Return ""
		  Return CSI + Str(n) + "A"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorDown(n As Integer) As String
		  If n <= 0 Then Return ""
		  Return CSI + Str(n) + "B"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorForward(n As Integer) As String
		  If n <= 0 Then Return ""
		  Return CSI + Str(n) + "C"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorBackward(n As Integer) As String
		  If n <= 0 Then Return ""
		  Return CSI + Str(n) + "D"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorNextLine(n As Integer) As String
		  // Move cursor to beginning of line n lines down
		  If n <= 0 Then Return ""
		  Return CSI + Str(n) + "E"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorPrevLine(n As Integer) As String
		  If n <= 0 Then Return ""
		  Return CSI + Str(n) + "F"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorColumn(col As Integer) As String
		  // Move cursor to column (1-based)
		  Return CSI + Str(col) + "G"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorPosition(row As Integer, col As Integer) As String
		  // Move cursor to row, col (1-based)
		  Return CSI + Str(row) + ";" + Str(col) + "H"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorSave() As String
		  // Save cursor position (DEC private)
		  Return CSI + "s"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorRestore() As String
		  // Restore cursor position (DEC private)
		  Return CSI + "u"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorShow() As String
		  // Show cursor (DEC private mode)
		  Return CSI + "?25h"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorHide() As String
		  // Hide cursor
		  Return CSI + "?25l"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CursorRequestPosition() As String
		  // Request cursor position report: CSI 6 n
		  // Terminal responds with CSI {row};{col} R
		  Return CSI + "6n"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EraseToEndOfLine() As String
		  Return CSI + "0K"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EraseToStartOfLine() As String
		  Return CSI + "1K"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EraseLine() As String
		  Return CSI + "2K"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EraseDown() As String
		  // Erase from cursor to end of screen
		  Return CSI + "0J"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EraseUp() As String
		  // Erase from cursor to start of screen
		  Return CSI + "1J"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EraseScreen() As String
		  // Erase entire screen
		  Return CSI + "2J"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ScrollUp(n As Integer) As String
		  If n <= 0 Then Return ""
		  Return CSI + Str(n) + "S"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ScrollDown(n As Integer) As String
		  If n <= 0 Then Return ""
		  Return CSI + Str(n) + "T"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AlternateScreenEnter() As String
		  // Switch to alternate screen buffer
		  Return CSI + "?1049h"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AlternateScreenExit() As String
		  // Switch back to main screen buffer
		  Return CSI + "?1049l"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MouseTrackingEnable() As String
		  // Enable basic mouse tracking + SGR extended mode
		  Return CSI + "?1000h" + CSI + "?1006h"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MouseTrackingDisable() As String
		  Return CSI + "?1006l" + CSI + "?1000l"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AutoWrapDisable() As String
		  // Disable auto-wrap (DECAWM reset) — prevents scroll at bottom-right corner
		  Return CSI + "?7l"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AutoWrapEnable() As String
		  // Re-enable auto-wrap (DECAWM set)
		  Return CSI + "?7h"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BracketedPasteEnable() As String
		  Return CSI + "?2004h"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BracketedPasteDisable() As String
		  Return CSI + "?2004l"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetTitle(title As String) As String
		  // Set terminal window title via OSC
		  Return OSC + "0;" + title + ST
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Hyperlink(url As String, text As String) As String
		  // OSC 8 hyperlink (supported in modern terminals)
		  Return OSC + "8;;" + url + ST + text + OSC + "8;;" + ST
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StripCodes(text As String) As String
		  // Remove all ANSI escape codes from text — forward-pass, no rescanning
		  Var rx As New RegEx
		  rx.SearchPattern = Chr(27) + "\[[0-9;]*[a-zA-Z]"

		  Var parts() As String
		  Var remaining As String = text
		  Var match As RegExMatch = rx.Search(remaining)

		  While match <> Nil
		    Var matchStart As Integer = match.SubExpressionStartB(0)
		    Var matchLen As Integer = match.SubExpressionString(0).Bytes

		    // Collect text before this match
		    If matchStart > 0 Then
		      parts.Add(remaining.LeftBytes(matchStart))
		    End If

		    // Advance past the match
		    remaining = remaining.MiddleBytes(matchStart + matchLen)
		    match = rx.Search(remaining)
		  Wend

		  // No matches found — return original
		  If parts.Count = 0 And remaining = text Then Return text

		  // Add remaining text after last match
		  If remaining <> "" Then
		    parts.Add(remaining)
		  End If

		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function VisibleLength(text As String) As Integer
		  // Return the visible length of text (excluding ANSI codes)
		  Return StripCodes(text).Length
		End Function
	#tag EndMethod

	#tag Note, Name = "About"
		XjANSI — ANSI Escape Code Builder

		Part of XjTTY-Toolkit foundation layer.
		Provides all standard ANSI escape sequences as
		composable string functions.

		Categories:
		- SGR (text styling: bold, italic, colors, etc.)
		- Cursor movement and visibility
		- Screen clearing and scrolling
		- Alternate screen buffer
		- Mouse tracking
		- Terminal title and hyperlinks
		- Code stripping utilities

		All functions return strings that can be written
		to StdOut to control the terminal.
	#tag EndNote


	#tag Constant, Name = FG_BLACK, Type = Double, Dynamic = False, Default = \"30", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_RED, Type = Double, Dynamic = False, Default = \"31", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_GREEN, Type = Double, Dynamic = False, Default = \"32", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_YELLOW, Type = Double, Dynamic = False, Default = \"33", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_BLUE, Type = Double, Dynamic = False, Default = \"34", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_MAGENTA, Type = Double, Dynamic = False, Default = \"35", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_CYAN, Type = Double, Dynamic = False, Default = \"36", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_WHITE, Type = Double, Dynamic = False, Default = \"37", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_DEFAULT, Type = Double, Dynamic = False, Default = \"39", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_BRIGHT_BLACK, Type = Double, Dynamic = False, Default = \"90", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_BRIGHT_RED, Type = Double, Dynamic = False, Default = \"91", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_BRIGHT_GREEN, Type = Double, Dynamic = False, Default = \"92", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_BRIGHT_YELLOW, Type = Double, Dynamic = False, Default = \"93", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_BRIGHT_BLUE, Type = Double, Dynamic = False, Default = \"94", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_BRIGHT_MAGENTA, Type = Double, Dynamic = False, Default = \"95", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_BRIGHT_CYAN, Type = Double, Dynamic = False, Default = \"96", Scope = Public
	#tag EndConstant

	#tag Constant, Name = FG_BRIGHT_WHITE, Type = Double, Dynamic = False, Default = \"97", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BLACK, Type = Double, Dynamic = False, Default = \"40", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_RED, Type = Double, Dynamic = False, Default = \"41", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_GREEN, Type = Double, Dynamic = False, Default = \"42", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_YELLOW, Type = Double, Dynamic = False, Default = \"43", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BLUE, Type = Double, Dynamic = False, Default = \"44", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_MAGENTA, Type = Double, Dynamic = False, Default = \"45", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_CYAN, Type = Double, Dynamic = False, Default = \"46", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_WHITE, Type = Double, Dynamic = False, Default = \"47", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_DEFAULT, Type = Double, Dynamic = False, Default = \"49", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BRIGHT_BLACK, Type = Double, Dynamic = False, Default = \"100", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BRIGHT_RED, Type = Double, Dynamic = False, Default = \"101", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BRIGHT_GREEN, Type = Double, Dynamic = False, Default = \"102", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BRIGHT_YELLOW, Type = Double, Dynamic = False, Default = \"103", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BRIGHT_BLUE, Type = Double, Dynamic = False, Default = \"104", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BRIGHT_MAGENTA, Type = Double, Dynamic = False, Default = \"105", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BRIGHT_CYAN, Type = Double, Dynamic = False, Default = \"106", Scope = Public
	#tag EndConstant

	#tag Constant, Name = BG_BRIGHT_WHITE, Type = Double, Dynamic = False, Default = \"107", Scope = Public
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
End Module
#tag EndModule
