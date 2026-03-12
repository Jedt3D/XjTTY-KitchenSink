#tag Class
Protected Class XjBox
Inherits XjWidget
	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor
		  mContentAlign = ALIGN_LEFT
		  mContentVAlign = VALIGN_TOP
		  mFillChar = ""
		  mFillStyle = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetContentAlign(align As Integer) As XjBox
		  mContentAlign = align
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetContentVAlign(valign As Integer) As XjBox
		  mContentVAlign = valign
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetFill(char As String, style As XjStyle) As XjBox
		  mFillChar = char
		  mFillStyle = style
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintContent(canvas As XjCanvas, x As Integer, y As Integer, w As Integer, h As Integer)
		  // Fill background if set
		  If mFillChar <> "" And mFillStyle <> Nil Then
		    canvas.FillRegion(x, y, w, h, mFillChar, mFillStyle)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentAlign() As Integer
		  Return mContentAlign
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentVAlign() As Integer
		  Return mContentVAlign
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Info(title As String) As XjBox
		  Var b As New XjBox
		  Var s As New XjStyle
		  Call b.SetBorder(0, s.SetFG(XjANSI.FG_CYAN))
		  If title <> "" Then Call b.SetTitle(" " + title + " ")
		  Return b
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Warning(title As String) As XjBox
		  Var b As New XjBox
		  Var s As New XjStyle
		  Call b.SetBorder(0, s.SetFG(XjANSI.FG_YELLOW))
		  If title <> "" Then Call b.SetTitle(" " + title + " ")
		  Return b
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Success(title As String) As XjBox
		  Var b As New XjBox
		  Var s As New XjStyle
		  Call b.SetBorder(0, s.SetFG(XjANSI.FG_GREEN))
		  If title <> "" Then Call b.SetTitle(" " + title + " ")
		  Return b
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Error_(title As String) As XjBox
		  Var b As New XjBox
		  Var s As New XjStyle
		  Call b.SetBorder(0, s.SetFG(XjANSI.FG_RED))
		  If title <> "" Then Call b.SetTitle(" " + title + " ")
		  Return b
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjBox — Container Widget

		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Box container with optional border, title, fill, and alignment.

		Usage:
		  Var box As XjBox = XjBox.Info("Status")
		  Call box.SetHeight(XjConstraint.Fixed(5))
		  root.AddChild(box)

		Semantic presets: Info (cyan), Warning (yellow),
		Success (green), Error_ (red).
	#tag EndNote

	#tag Property, Flags = &h21
		Private mContentAlign As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mContentVAlign As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFillChar As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFillStyle As XjStyle
	#tag EndProperty


	#tag Constant, Name = ALIGN_LEFT, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ALIGN_CENTER, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ALIGN_RIGHT, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = VALIGN_TOP, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = VALIGN_MIDDLE, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = VALIGN_BOTTOM, Type = Double, Dynamic = False, Default = \"2", Scope = Public
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
