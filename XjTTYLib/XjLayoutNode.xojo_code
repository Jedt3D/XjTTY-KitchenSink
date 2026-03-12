#tag Class
Protected Class XjLayoutNode
	#tag Method, Flags = &h0
		Sub AddChild(child As XjLayoutNode)
		  child.mParent = Self
		  mChildren.Add(child)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BorderColor() As XjStyle
		  Return mBorderColor
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BorderStyleValue() As Integer
		  Return mBorderStyle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Child(index As Integer) As XjLayoutNode
		  If index < 0 Or index >= mChildren.Count Then Return Nil
		  Return mChildren(index)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChildCount() As Integer
		  Return mChildren.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ComputedHeight() As Integer
		  Return mComputedHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ComputedWidth() As Integer
		  Return mComputedWidth
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ComputedX() As Integer
		  Return mComputedX
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ComputedY() As Integer
		  Return mComputedY
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  mDirection = DIR_COLUMN
		  mWidthConstraint = XjConstraint.Auto
		  mHeightConstraint = XjConstraint.Auto
		  mPaddingTop = 0
		  mPaddingBottom = 0
		  mPaddingLeft = 0
		  mPaddingRight = 0
		  mMarginTop = 0
		  mMarginBottom = 0
		  mMarginLeft = 0
		  mMarginRight = 0
		  mBorderStyle = -1
		  mBorderColor = Nil
		  mName = ""
		  mTitle = ""
		  mComputedX = 0
		  mComputedY = 0
		  mComputedWidth = 0
		  mComputedHeight = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentHeight() As Integer
		  Var bdr As Integer = 0
		  If mBorderStyle >= 0 Then bdr = 2
		  Var h As Integer = mComputedHeight - mMarginTop - mMarginBottom - bdr - mPaddingTop - mPaddingBottom
		  If h < 0 Then h = 0
		  Return h
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentWidth() As Integer
		  Var bdr As Integer = 0
		  If mBorderStyle >= 0 Then bdr = 2
		  Var w As Integer = mComputedWidth - mMarginLeft - mMarginRight - bdr - mPaddingLeft - mPaddingRight
		  If w < 0 Then w = 0
		  Return w
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentX() As Integer
		  // Inner content X = computed position + margin + border + padding
		  Var bdr As Integer = 0
		  If mBorderStyle >= 0 Then bdr = 1
		  Return mComputedX + mMarginLeft + bdr + mPaddingLeft
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentY() As Integer
		  Var bdr As Integer = 0
		  If mBorderStyle >= 0 Then bdr = 1
		  Return mComputedY + mMarginTop + bdr + mPaddingTop
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Direction() As Integer
		  Return mDirection
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindByName(n As String) As XjLayoutNode
		  If mName = n Then Return Self
		  
		  For i As Integer = 0 To mChildren.Count - 1
		    Var found As XjLayoutNode = mChildren(i).FindByName(n)
		    If found <> Nil Then Return found
		  Next
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HeightConstraint() As XjConstraint
		  Return mHeightConstraint
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MarginBottom() As Integer
		  Return mMarginBottom
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MarginLeft() As Integer
		  Return mMarginLeft
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MarginRight() As Integer
		  Return mMarginRight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MarginTop() As Integer
		  Return mMarginTop
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Name() As String
		  Return mName
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PaddingBottom() As Integer
		  Return mPaddingBottom
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PaddingLeft() As Integer
		  Return mPaddingLeft
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PaddingRight() As Integer
		  Return mPaddingRight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PaddingTop() As Integer
		  Return mPaddingTop
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintSelf(canvas As XjCanvas)
		  // Draw this node's border and title only (no child recursion).
		  // Used by XjWidget to avoid double-painting when widgets control recursion.
		  
		  If mBorderStyle >= 0 Then
		    Var bx As Integer = mComputedX + mMarginLeft
		    Var by As Integer = mComputedY + mMarginTop
		    Var bw As Integer = mComputedWidth - mMarginLeft - mMarginRight
		    Var bh As Integer = mComputedHeight - mMarginTop - mMarginBottom
		    
		    If bw >= 2 And bh >= 2 Then
		      Var bColor As XjStyle = mBorderColor
		      If bColor Is Nil Then
		        bColor = New XjStyle
		      End If
		      canvas.DrawBox(bx, by, bw, bh, bColor, mBorderStyle)
		      
		      // Draw title on top border if set
		      If mTitle <> "" Then
		        Var titleX As Integer = bx + (bw - mTitle.Length) / 2
		        If titleX < bx + 1 Then titleX = bx + 1
		        Var baseTitleStyle As New XjStyle
		        Var titleStyle As XjStyle = baseTitleStyle.SetFG(XjANSI.FG_BRIGHT_YELLOW).SetBold
		        canvas.WriteText(titleX, by, mTitle, titleStyle)
		      End If
		    End If
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintTo(canvas As XjCanvas)
		  // Draw this node's border/title, then recurse children
		  PaintSelf(canvas)
		  
		  For i As Integer = 0 To mChildren.Count - 1
		    mChildren(i).PaintTo(canvas)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parent() As XjLayoutNode
		  Return mParent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBorder(style As Integer, color As XjStyle) As XjLayoutNode
		  mBorderStyle = style
		  mBorderColor = color
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetComputed(x As Integer, y As Integer, w As Integer, h As Integer)
		  mComputedX = x
		  mComputedY = y
		  mComputedWidth = w
		  mComputedHeight = h
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetDirection(dir As Integer) As XjLayoutNode
		  mDirection = dir
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetHeight(c As XjConstraint) As XjLayoutNode
		  mHeightConstraint = c
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMargin(top As Integer, right As Integer, bottom As Integer, left As Integer) As XjLayoutNode
		  mMarginTop = top
		  mMarginRight = right
		  mMarginBottom = bottom
		  mMarginLeft = left
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetName(n As String) As XjLayoutNode
		  mName = n
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetPadding(top As Integer, right As Integer, bottom As Integer, left As Integer) As XjLayoutNode
		  mPaddingTop = top
		  mPaddingRight = right
		  mPaddingBottom = bottom
		  mPaddingLeft = left
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetTitle(t As String) As XjLayoutNode
		  mTitle = t
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetWidth(c As XjConstraint) As XjLayoutNode
		  mWidthConstraint = c
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Title() As String
		  Return mTitle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WidthConstraint() As XjConstraint
		  Return mWidthConstraint
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjLayoutNode — Layout Tree Node
		
		Part of XjTTY-Toolkit Phase 2 (Layout Engine).
		Flexbox-like layout node for building terminal UI layouts.
		
		Usage:
		  Var root As New XjLayoutNode
		  Call root.SetDirection(XjLayoutNode.DIR_COLUMN).SetName("root")
		
		  Var header As New XjLayoutNode
		  Call header.SetHeight(XjConstraint.Fixed(3)).SetName("header")
		  root.AddChild(header)
		
		  Var content As New XjLayoutNode
		  Call content.SetName("content")
		  root.AddChild(content)
		
		  XjLayoutSolver.Solve(root, termWidth, termHeight)
		  root.PaintTo(canvas)
		
		  // Use ContentX/Y/W/H to draw text inside panels
		  canvas.WriteText(header.ContentX, header.ContentY, "Title", style)
		
		Features:
		- Row/column direction
		- Fixed, percentage, and auto sizing via XjConstraint
		- Padding and margin
		- Optional border with title
		- Recursive tree structure
		- Computed absolute coordinates after solving
	#tag EndNote


	#tag Property, Flags = &h21
		Private mBorderColor As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBorderStyle As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChildren() As XjLayoutNode
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mComputedHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mComputedWidth As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mComputedX As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mComputedY As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDirection As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHeightConstraint As XjConstraint
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMarginBottom As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMarginLeft As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMarginRight As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMarginTop As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPaddingBottom As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPaddingLeft As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPaddingRight As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPaddingTop As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mParent As XjLayoutNode
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTitle As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWidthConstraint As XjConstraint
	#tag EndProperty


	#tag Constant, Name = DIR_COLUMN, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = DIR_ROW, Type = Double, Dynamic = False, Default = \"0", Scope = Public
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
