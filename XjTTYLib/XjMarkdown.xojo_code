#tag Module
Protected Module XjMarkdown
	#tag Method, Flags = &h0
		Sub Render(text As String)
		  Var lines() As String = text.Split(Chr(10))
		  Var inCodeBlock As Boolean = False

		  For i As Integer = 0 To lines.Count - 1
		    Var line As String = lines(i)

		    // Code block toggle
		    If line.Trim.Left(3) = "```" Then
		      inCodeBlock = Not inCodeBlock
		      If inCodeBlock Then
		        Var s As New XjStyle
		        Print(s.SetFG(90).Apply("  " + Chr(&hE2) + Chr(&h94) + Chr(&h80) + Chr(&hE2) + Chr(&h94) + Chr(&h80) + Chr(&hE2) + Chr(&h94) + Chr(&h80)))
		      Else
		        Var s As New XjStyle
		        Print(s.SetFG(90).Apply("  " + Chr(&hE2) + Chr(&h94) + Chr(&h80) + Chr(&hE2) + Chr(&h94) + Chr(&h80) + Chr(&hE2) + Chr(&h94) + Chr(&h80)))
		      End If
		      Continue
		    End If

		    If inCodeBlock Then
		      Var s As New XjStyle
		      Print(s.SetFG(XjANSI.FG_YELLOW).Apply("    " + line))
		      Continue
		    End If

		    // Horizontal rule
		    If line.Trim = "---" Or line.Trim = "===" Or line.Trim = "***" Then
		      Var s As New XjStyle
		      Var ruleChar As String = Chr(&hE2) + Chr(&h94) + Chr(&h80)
		      Var ruleParts() As String
		      Var w As Integer = 40
		      For c As Integer = 1 To w
		        ruleParts.Add(ruleChar)
		      Next
		      Print(s.SetFG(90).Apply(String.FromArray(ruleParts, "")))
		      Continue
		    End If

		    // Headers
		    If line.Left(4) = "### " Then
		      Var s As New XjStyle
		      Print(s.SetFG(XjANSI.FG_CYAN).Apply("   " + line.Middle(4)))
		      Continue
		    ElseIf line.Left(3) = "## " Then
		      Var s As New XjStyle
		      Var s2 As XjStyle = s.SetFG(XjANSI.FG_CYAN).SetBold
		      Print(s2.Apply("  " + line.Middle(3)))
		      Continue
		    ElseIf line.Left(2) = "# " Then
		      Var s As New XjStyle
		      Var s2 As XjStyle = s.SetFG(XjANSI.FG_CYAN).SetBold
		      Print(s2.Apply(line.Middle(2).Uppercase))
		      Continue
		    End If

		    // Unordered list
		    Var trimmed As String = line.TrimLeft
		    If trimmed.Left(2) = "- " Or trimmed.Left(2) = "* " Then
		      Var indent As Integer = line.Length - trimmed.Length
		      Var prefParts() As String
		      For c As Integer = 1 To indent
		        prefParts.Add(" ")
		      Next
		      Var prefix As String = String.FromArray(prefParts, "")
		      Var bullet As String = Chr(&hE2) + Chr(&h80) + Chr(&hA2)
		      Var content As String = trimmed.Middle(2)
		      content = FormatInline(content)
		      Print(prefix + "  " + bullet + " " + content)
		      Continue
		    End If

		    // Ordered list
		    If trimmed.Length >= 3 Then
		      Var firstChar As String = trimmed.Left(1)
		      If firstChar >= "1" And firstChar <= "9" Then
		        Var dotPos As Integer = trimmed.IndexOf(". ")
		        If dotPos >= 1 And dotPos <= 3 Then
		          Var indent As Integer = line.Length - trimmed.Length
		          Var prefParts2() As String
		          For c As Integer = 1 To indent
		            prefParts2.Add(" ")
		          Next
		          Var prefix As String = String.FromArray(prefParts2, "")
		          Var num As String = trimmed.Left(dotPos)
		          Var content As String = trimmed.Middle(dotPos + 2)
		          content = FormatInline(content)
		          Print(prefix + "  " + num + ". " + content)
		          Continue
		        End If
		      End If
		    End If

		    // Regular paragraph
		    If line.Trim = "" Then
		      Print("")
		    Else
		      Print(FormatInline(line))
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FormatInline(line As String) As String
		  // Single-pass scanner: O(n) instead of O(m^2)
		  Var lineLen As Integer = line.Length
		  If lineLen = 0 Then Return line

		  // Pre-create styles once
		  Var base As New XjStyle
		  Var sBold As XjStyle = base.SetBold
		  Var sItal As XjStyle = base.SetItalic
		  Var sCode As XjStyle = base.SetInverse

		  Var parts() As String
		  Var i As Integer = 0

		  While i < lineLen
		    // Check for bold: **text**
		    If i + 1 < lineLen And line.Middle(i, 2) = "**" Then
		      Var endPos As Integer = line.IndexOf(i + 2, "**")
		      If endPos >= 0 Then
		        parts.Add(sBold.Apply(line.Middle(i + 2, endPos - i - 2)))
		        i = endPos + 2
		        Continue
		      End If
		    End If

		    // Check for inline code: `text`
		    If line.Middle(i, 1) = "`" Then
		      Var endPos As Integer = line.IndexOf(i + 1, "`")
		      If endPos >= 0 Then
		        parts.Add(sCode.Apply(" " + line.Middle(i + 1, endPos - i - 1) + " "))
		        i = endPos + 1
		        Continue
		      End If
		    End If

		    // Check for italic: *text* (single asterisk)
		    If line.Middle(i, 1) = "*" Then
		      Var endPos As Integer = line.IndexOf(i + 1, "*")
		      If endPos >= 0 Then
		        parts.Add(sItal.Apply(line.Middle(i + 1, endPos - i - 1)))
		        i = endPos + 1
		        Continue
		      End If
		    End If

		    // Regular text — find next marker position
		    Var nextStar As Integer = line.IndexOf(i, "*")
		    Var nextTick As Integer = line.IndexOf(i, "`")
		    Var nextMarker As Integer = lineLen
		    If nextStar >= 0 And nextStar < nextMarker Then nextMarker = nextStar
		    If nextTick >= 0 And nextTick < nextMarker Then nextMarker = nextTick

		    If nextMarker > i Then
		      parts.Add(line.Middle(i, nextMarker - i))
		      i = nextMarker
		    Else
		      parts.Add(line.Middle(i))
		      i = lineLen
		    End If
		  Wend

		  If parts.Count = 0 Then Return line
		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjMarkdown — Terminal Markdown Renderer

		Part of XjTTY-Toolkit Phase 5 (Utility Modules).
		Render basic markdown with ANSI styling.

		Supported:
		  # Header 1, ## Header 2, ### Header 3
		  **bold**, *italic*, `code`
		  - Unordered lists
		  1. Ordered lists
		  ``` Code blocks ```
		  --- Horizontal rules

		Usage:
		  XjMarkdown.Render(markdownText)
	#tag EndNote

End Module
#tag EndModule
