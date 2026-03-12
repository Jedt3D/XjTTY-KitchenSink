#tag Class
Protected Class XjWidget
	#tag Method, Flags = &h0
		Sub Constructor()
		  mLayoutNode = New XjLayoutNode
		  mVisible = True
		  mFocusable = False
		  mFocused = False
		  mDirty = True
		  mStyle = New XjStyle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LayoutNode() As XjLayoutNode
		  Return mLayoutNode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetWidth(c As XjConstraint) As XjWidget
		  Call mLayoutNode.SetWidth(c)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetHeight(c As XjConstraint) As XjWidget
		  Call mLayoutNode.SetHeight(c)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBorder(style As Integer, color As XjStyle) As XjWidget
		  Call mLayoutNode.SetBorder(style, color)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetPadding(top As Integer, right As Integer, bottom As Integer, left As Integer) As XjWidget
		  Call mLayoutNode.SetPadding(top, right, bottom, left)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMargin(top As Integer, right As Integer, bottom As Integer, left As Integer) As XjWidget
		  Call mLayoutNode.SetMargin(top, right, bottom, left)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetTitle(t As String) As XjWidget
		  Call mLayoutNode.SetTitle(t)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetName(n As String) As XjWidget
		  mName = n
		  Call mLayoutNode.SetName(n)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetStyle(s As XjStyle) As XjWidget
		  mStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetDirection(dir As Integer) As XjWidget
		  Call mLayoutNode.SetDirection(dir)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetVisible(v As Boolean) As XjWidget
		  mVisible = v
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddChild(child As XjWidget)
		  child.mParent = Self
		  mChildren.Add(child)
		  mLayoutNode.AddChild(child.mLayoutNode)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChildCount() As Integer
		  Return mChildren.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Child(index As Integer) As XjWidget
		  If index < 0 Or index >= mChildren.Count Then Return Nil
		  Return mChildren(index)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parent() As XjWidget
		  Return mParent
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Name() As String
		  Return mName
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Style() As XjStyle
		  Return mStyle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsVisible() As Boolean
		  Return mVisible
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsFocusable() As Boolean
		  Return mFocusable
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetFocusable(v As Boolean)
		  mFocusable = v
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsFocused() As Boolean
		  Return mFocused
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetFocused(v As Boolean)
		  mFocused = v
		  mDirty = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MarkDirty()
		  mDirty = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsDirty() As Boolean
		  Return mDirty
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentX() As Integer
		  Return mLayoutNode.ContentX
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentY() As Integer
		  Return mLayoutNode.ContentY
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentWidth() As Integer
		  Return mLayoutNode.ContentWidth
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContentHeight() As Integer
		  Return mLayoutNode.ContentHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Paint(canvas As XjCanvas)
		  // Template method: paint borders, content, then children
		  If Not mVisible Then Return

		  // 1. Paint this node's border/title
		  mLayoutNode.PaintSelf(canvas)

		  // 2. Paint this widget's content (subclasses override)
		  PaintContent(canvas, ContentX, ContentY, ContentWidth, ContentHeight)

		  // 3. Recurse into child widgets
		  For i As Integer = 0 To mChildren.Count - 1
		    mChildren(i).Paint(canvas)
		  Next

		  mDirty = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintContent(canvas As XjCanvas, x As Integer, y As Integer, w As Integer, h As Integer)
		  // Virtual method — subclasses override to draw their content.
		  // Base implementation does nothing.
		  #Pragma Unused canvas
		  #Pragma Unused x
		  #Pragma Unused y
		  #Pragma Unused w
		  #Pragma Unused h
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HandleKey(key As XjKeyEvent) As Boolean
		  // Virtual method — subclasses override to handle input.
		  // Returns True if the key was consumed.
		  #Pragma Unused key
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HandleTick(tickCount As Integer)
		  // Virtual method — subclasses override for animation.
		  #Pragma Unused tickCount

		  // Recurse into children
		  For i As Integer = 0 To mChildren.Count - 1
		    mChildren(i).HandleTick(tickCount)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FindByName(n As String) As XjWidget
		  If mName = n Then Return Self

		  For i As Integer = 0 To mChildren.Count - 1
		    Var found As XjWidget = mChildren(i).FindByName(n)
		    If found <> Nil Then Return found
		  Next

		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CollectFocusable(list() As XjWidget)
		  // Recursive helper to build focus chain
		  If mFocusable And mVisible Then list.Add(Self)

		  For i As Integer = 0 To mChildren.Count - 1
		    mChildren(i).CollectFocusable(list)
		  Next
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjWidget — Base Widget Class

		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Base class for all TUI widgets. Owns an XjLayoutNode
		for positioning, provides Paint/HandleKey/HandleTick
		template methods for subclasses.

		Usage:
		  // Subclass and override PaintContent:
		  Class MyWidget Inherits XjWidget
		    Sub PaintContent(canvas, x, y, w, h)
		      canvas.WriteText(x, y, "Hello", mStyle)
		    End Sub
		  End Class

		  // Build widget tree:
		  Var root As New XjBox
		  root.AddChild(myWidget)

		  // Solve layout, then paint:
		  XjLayoutSolver.Solve(root.LayoutNode, termW, termH)
		  root.Paint(canvas)
	#tag EndNote

	#tag Property, Flags = &h1
		Protected mLayoutNode As XjLayoutNode
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mChildren() As XjWidget
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mParent As XjWidget
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mName As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mVisible As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mFocusable As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mFocused As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mDirty As Boolean
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
