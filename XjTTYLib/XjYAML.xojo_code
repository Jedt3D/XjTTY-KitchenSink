#tag Module
Protected Module XjYAML
	#tag Method, Flags = &h21
		Private Function CountIndent(line As String) As Integer
		  Var count As Integer = 0
		  For i As Integer = 0 To line.Length - 1
		    If line.Middle(i, 1) = " " Then
		      count = count + 1
		    Else
		      Exit
		    End If
		  Next
		  Return count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parse(text As String) As XjYAMLNode
		  Var root As New XjYAMLNode("root")
		  
		  Var lines() As String = text.Split(Chr(10))
		  Var idx As Integer = 0
		  
		  Var children() As XjYAMLNode = ParseBlock(lines, idx, 0)
		  For i As Integer = 0 To children.Count - 1
		    root.AddChild(children(i))
		  Next
		  
		  Return root
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseBlock(lines() As String, ByRef idx As Integer, minIndent As Integer) As XjYAMLNode()
		  Var nodes() As XjYAMLNode
		  
		  While idx < lines.Count
		    Var line As String = lines(idx)
		    Var indent As Integer = CountIndent(line)
		    
		    // Skip empty lines and comments (use indent to avoid redundant TrimLeft)
		    Var content As String = line.Middle(indent)
		    If content = "" Or content.Left(1) = "#" Then
		      idx = idx + 1
		      Continue
		    End If
		    
		    // If less indented than minimum, we're done with this block
		    If indent < minIndent Then
		      Exit
		    End If
		    
		    // Handle list item
		    If content.Left(2) = "- " Then
		      content = content.Middle(2)
		      Var colonPos As Integer = content.IndexOf(":")
		      
		      If colonPos >= 0 Then
		        Var key As String = content.Left(colonPos).Trim
		        Var val As String = content.Middle(colonPos + 1).Trim
		        // Strip quotes from value
		        val = StripQuotes(val)
		        
		        Var node As New XjYAMLNode(key, val)
		        idx = idx + 1
		        
		        If val = "" Then
		          // Has children — indented from the content after "- "
		          Var children() As XjYAMLNode = ParseBlock(lines, idx, indent + 4)
		          For i As Integer = 0 To children.Count - 1
		            node.AddChild(children(i))
		          Next
		        End If
		        
		        nodes.Add(node)
		      Else
		        // Bare list item value
		        Var node As New XjYAMLNode("", content.Trim)
		        idx = idx + 1
		        nodes.Add(node)
		      End If
		      
		    Else
		      // Regular key: value
		      Var colonPos As Integer = content.IndexOf(":")
		      
		      If colonPos >= 0 Then
		        Var key As String = content.Left(colonPos).Trim
		        Var val As String = content.Middle(colonPos + 1).Trim
		        val = StripQuotes(val)
		        
		        Var node As New XjYAMLNode(key, val)
		        idx = idx + 1
		        
		        If val = "" Then
		          // Has children at indent + 2
		          Var children() As XjYAMLNode = ParseBlock(lines, idx, indent + 2)
		          For i As Integer = 0 To children.Count - 1
		            node.AddChild(children(i))
		          Next
		        End If
		        
		        nodes.Add(node)
		      Else
		        // Skip unparseable line
		        idx = idx + 1
		      End If
		    End If
		  Wend
		  
		  Return nodes
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function StripQuotes(s As String) As String
		  If s.Length >= 2 Then
		    Var first As String = s.Left(1)
		    Var last As String = s.Right(1)
		    If (first = Chr(34) And last = Chr(34)) Or (first = "'" And last = "'") Then
		      Return s.Middle(1, s.Length - 2)
		    End If
		  End If
		  Return s
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjYAML — Simple YAML Parser
		
		Part of XjTTY-Toolkit Phase 6 (YAML UI Definition).
		Parses a subset of YAML into an XjYAMLNode tree.
		
		Supports:
		  - Key: value pairs
		  - Nested mappings (indentation-based)
		  - Sequences (- prefix)
		  - Comments (# prefix)
		  - Quoted string values
		
		Usage:
		  Var root As XjYAMLNode = XjYAML.Parse(yamlText)
		  Var name As String = root.Child("box").StringValue("name")
	#tag EndNote


End Module
#tag EndModule
