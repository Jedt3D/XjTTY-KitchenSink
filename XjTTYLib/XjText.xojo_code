#tag Class
Protected Class XjText
Inherits XjWidget
	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor
		  mText = ""
		  mAlign = ALIGN_LEFT
		  mWrap = True
		  mScrollOffset = 0
		  mCachedWidth = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetText(t As String) As XjText
		  mText = t
		  mDirty = True
		  mCachedWidth = -1
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Text() As String
		  Return mText
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetAlign(align As Integer) As XjText
		  mAlign = align
		  mDirty = True
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetWrap(w As Boolean) As XjText
		  mWrap = w
		  mDirty = True
		  mCachedWidth = -1
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetScrollOffset(offset As Integer) As XjText
		  mScrollOffset = offset
		  mDirty = True
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LineCount() As Integer
		  RebuildLines(ContentWidth)
		  Return mLines.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintContent(canvas As XjCanvas, x As Integer, y As Integer, w As Integer, h As Integer)
		  If w <= 0 Or h <= 0 Then Return

		  RebuildLines(w)

		  Var row As Integer = 0
		  For i As Integer = mScrollOffset To mLines.Count - 1
		    If row >= h Then Exit

		    Var line As String = mLines(i)

		    // Truncate to width
		    If line.Length > w Then
		      line = line.Left(w)
		    End If

		    // Calculate x position based on alignment
		    Var lx As Integer = x
		    Select Case mAlign
		    Case ALIGN_CENTER
		      lx = x + (w - line.Length) / 2
		    Case ALIGN_RIGHT
		      lx = x + w - line.Length
		    End Select

		    If lx < x Then lx = x

		    canvas.WriteText(lx, y + row, line, mStyle)
		    row = row + 1
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RebuildLines(availWidth As Integer)
		  // Rebuild cached lines if needed
		  If availWidth = mCachedWidth And Not mDirty Then Return
		  mCachedWidth = availWidth

		  // Clear old lines
		  mLines.RemoveAll

		  If mText = "" Then Return

		  // Split by newlines first
		  Var paragraphs() As String = mText.Split(EndOfLine)

		  For p As Integer = 0 To paragraphs.Count - 1
		    Var para As String = paragraphs(p)

		    If Not mWrap Or availWidth <= 0 Then
		      mLines.Add(para)
		    Else
		      // Word wrap this paragraph
		      WrapParagraph(para, availWidth)
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WrapParagraph(text As String, maxWidth As Integer)
		  If text = "" Then
		    mLines.Add("")
		    Return
		  End If

		  Var words() As String = text.Split(" ")
		  Var lineWords() As String
		  Var lineLen As Integer = 0

		  For i As Integer = 0 To words.Count - 1
		    Var word As String = words(i)

		    If lineLen = 0 Then
		      lineWords.Add(word)
		      lineLen = word.Length
		    ElseIf lineLen + 1 + word.Length <= maxWidth Then
		      lineWords.Add(word)
		      lineLen = lineLen + 1 + word.Length
		    Else
		      mLines.Add(String.FromArray(lineWords, " "))
		      lineWords.RemoveAll
		      lineWords.Add(word)
		      lineLen = word.Length
		    End If
		  Next

		  If lineWords.Count > 0 Then
		    mLines.Add(String.FromArray(lineWords, " "))
		  End If
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjText — Text Display Widget

		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Displays text with optional word wrapping, alignment,
		and scrolling.

		Usage:
		  Var t As New XjText
		  Call t.SetText("Hello, world!")
		  Call t.SetAlign(XjText.ALIGN_CENTER)
		  Call t.SetWrap(True)
	#tag EndNote

	#tag Property, Flags = &h21
		Private mText As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mAlign As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWrap As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScrollOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLines() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCachedWidth As Integer
	#tag EndProperty


	#tag Constant, Name = ALIGN_LEFT, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ALIGN_CENTER, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ALIGN_RIGHT, Type = Double, Dynamic = False, Default = \"2", Scope = Public
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
