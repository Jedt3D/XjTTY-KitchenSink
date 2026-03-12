#tag Class
Protected Class XjTreeNode
	#tag Method, Flags = &h0
		Sub Constructor(label As String)
		  mLabel = label
		  mExpanded = True
		  mStyle = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddChild(child As XjTreeNode) As XjTreeNode
		  mChildren.Add(child)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetLabel(l As String) As XjTreeNode
		  mLabel = l
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetExpanded(v As Boolean) As XjTreeNode
		  mExpanded = v
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetNodeStyle(s As XjStyle) As XjTreeNode
		  mStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Label() As String
		  Return mLabel
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsExpanded() As Boolean
		  Return mExpanded
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NodeStyle() As XjStyle
		  Return mStyle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChildCount() As Integer
		  Return mChildren.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Child(index As Integer) As XjTreeNode
		  If index < 0 Or index >= mChildren.Count Then Return Nil
		  Return mChildren(index)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsLeaf() As Boolean
		  Return mChildren.Count = 0
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjTreeNode — Tree Data Node

		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Data structure for tree hierarchy display.
		Each node has a label, optional style, and children.

		Usage:
		  Var root As New XjTreeNode("Project")
		  Var src As New XjTreeNode("src")
		  Call root.AddChild(src)
		  Call src.AddChild(New XjTreeNode("main.xojo_code"))
	#tag EndNote

	#tag Property, Flags = &h21
		Private mLabel As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mChildren() As XjTreeNode
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mExpanded As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStyle As XjStyle
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
