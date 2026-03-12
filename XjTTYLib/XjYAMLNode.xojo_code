#tag Class
Protected Class XjYAMLNode
	#tag Method, Flags = &h0
		Sub AddChild(node As XjYAMLNode)
		  mChildren.Add(node)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BoolValue(k As String, defaultVal As Boolean = False) As Boolean
		  Var c As XjYAMLNode = Child(k)
		  If c <> Nil Then
		    Var v As String = c.Value.Lowercase
		    Return v = "true" Or v = "yes" Or v = "1"
		  End If
		  Return defaultVal
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Child(k As String) As XjYAMLNode
		  For i As Integer = 0 To mChildren.Count - 1
		    If mChildren(i).Key = k Then Return mChildren(i)
		  Next
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChildAt(index As Integer) As XjYAMLNode
		  If index >= 0 And index < mChildren.Count Then
		    Return mChildren(index)
		  End If
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChildCount() As Integer
		  Return mChildren.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChildrenWithKey(k As String) As XjYAMLNode()
		  // Return all children matching a key (for list items with same key)
		  Var result() As XjYAMLNode
		  For i As Integer = 0 To mChildren.Count - 1
		    If mChildren(i).Key = k Then result.Add(mChildren(i))
		  Next
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(key As String = "", value As String = "")
		  mKey = key
		  mValue = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Dump(indent As Integer = 0) As String
		  Var padParts() As String
		  For i As Integer = 1 To indent
		    padParts.Add("  ")
		  Next
		  Var pad As String = String.FromArray(padParts, "")
		  
		  Var parts() As String
		  
		  If mKey <> "" And mValue <> "" Then
		    parts.Add(pad + mKey + ": " + mValue + Chr(10))
		  ElseIf mKey <> "" Then
		    parts.Add(pad + mKey + ":" + Chr(10))
		  ElseIf mValue <> "" Then
		    parts.Add(pad + "- " + mValue + Chr(10))
		  End If
		  
		  For i As Integer = 0 To mChildren.Count - 1
		    parts.Add(mChildren(i).Dump(indent + 1))
		  Next
		  
		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasKey(k As String) As Boolean
		  For i As Integer = 0 To mChildren.Count - 1
		    If mChildren(i).Key = k Then Return True
		  Next
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IntValue(k As String, defaultVal As Integer = 0) As Integer
		  Var c As XjYAMLNode = Child(k)
		  If c <> Nil And c.Value <> "" Then Return Val(c.Value)
		  Return defaultVal
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Key() As String
		  Return mKey
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue(k As String, defaultVal As String = "") As String
		  Var c As XjYAMLNode = Child(k)
		  If c <> Nil And c.Value <> "" Then Return c.Value
		  Return defaultVal
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value() As String
		  Return mValue
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjYAMLNode — YAML Parse Tree Node
		
		Part of XjTTY-Toolkit Phase 6 (YAML UI Definition).
		Represents a node in a parsed YAML document tree.
		Supports key-value pairs, nested mappings, and sequences.
	#tag EndNote


	#tag Property, Flags = &h21
		Private mChildren() As XjYAMLNode
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mKey As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValue As String
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
