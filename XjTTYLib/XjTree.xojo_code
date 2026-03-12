#tag Class
Protected Class XjTree
Inherits XjWidget
	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor
		  mScrollOffset = 0
		  mNeedsRebuild = True

		  Var base As New XjStyle
		  mNodeStyle = base.SetFG(XjANSI.FG_WHITE)
		  mBranchStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddRoot(node As XjTreeNode)
		  mRootNodes.Add(node)
		  mNeedsRebuild = True
		  mDirty = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetData(roots() As XjTreeNode)
		  mRootNodes.RemoveAll
		  For i As Integer = 0 To roots.Count - 1
		    mRootNodes.Add(roots(i))
		  Next
		  mNeedsRebuild = True
		  mDirty = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetNodeStyle(s As XjStyle) As XjTree
		  mNodeStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBranchStyle(s As XjStyle) As XjTree
		  mBranchStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetScrollOffset(offset As Integer) As XjTree
		  mScrollOffset = offset
		  mDirty = True
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Rebuild()
		  // Rebuild the flat line list from the tree
		  mLineTexts.RemoveAll
		  mLinePrefixes.RemoveAll
		  mLineNodes.RemoveAll

		  For i As Integer = 0 To mRootNodes.Count - 1
		    RenderNode(mRootNodes(i), "", i = mRootNodes.Count - 1)
		  Next

		  mNeedsRebuild = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RenderNode(node As XjTreeNode, prefix As String, isLast As Boolean)
		  // Box-drawing characters
		  Var branch As String
		  Var continuation As String

		  If prefix = "" Then
		    // Root level — no branch prefix
		    branch = ""
		    continuation = ""
		  ElseIf isLast Then
		    branch = prefix + Chr(&h2514) + Chr(&h2500) + " "
		    continuation = prefix + "   "
		  Else
		    branch = prefix + Chr(&h251C) + Chr(&h2500) + " "
		    continuation = prefix + Chr(&h2502) + "  "
		  End If

		  mLinePrefixes.Add(branch)
		  mLineTexts.Add(node.Label)
		  mLineNodes.Add(node)

		  If node.IsExpanded Then
		    For i As Integer = 0 To node.ChildCount - 1
		      RenderNode(node.Child(i), continuation, i = node.ChildCount - 1)
		    Next
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LineCount() As Integer
		  Return mLineTexts.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintContent(canvas As XjCanvas, x As Integer, y As Integer, w As Integer, h As Integer)
		  If w <= 0 Or h <= 0 Then Return

		  // Only rebuild when data has changed
		  If mNeedsRebuild Then
		    Rebuild
		  End If

		  Var row As Integer = 0
		  For i As Integer = mScrollOffset To mLineTexts.Count - 1
		    If row >= h Then Exit

		    Var prefix As String = mLinePrefixes(i)
		    Var text As String = mLineTexts(i)
		    Var node As XjTreeNode = mLineNodes(i)

		    // Draw prefix (branch characters)
		    If prefix <> "" Then
		      Var pLen As Integer = prefix.Length
		      If pLen > w Then pLen = w
		      canvas.WriteText(x, y + row, prefix.Left(pLen), mBranchStyle)
		    End If

		    // Draw node label
		    Var textX As Integer = x + prefix.Length
		    Var maxLen As Integer = w - prefix.Length
		    If maxLen > 0 Then
		      Var nodeStyle As XjStyle = node.NodeStyle
		      If nodeStyle Is Nil Then nodeStyle = mNodeStyle
		      canvas.WriteText(textX, y + row, text.Left(maxLen), nodeStyle)
		    End If

		    row = row + 1
		  Next
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjTree — Tree Display Widget

		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Displays hierarchical data as a tree with box-drawing
		branch characters.

		Usage:
		  Var tree As New XjTree
		  Var root As New XjTreeNode("Project")
		  Call root.AddChild(New XjTreeNode("src"))
		  Call root.AddChild(New XjTreeNode("tests"))
		  tree.AddRoot(root)
	#tag EndNote

	#tag Property, Flags = &h21
		Private mRootNodes() As XjTreeNode
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineTexts() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLinePrefixes() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineNodes() As XjTreeNode
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScrollOffset As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNodeStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBranchStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNeedsRebuild As Boolean
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
