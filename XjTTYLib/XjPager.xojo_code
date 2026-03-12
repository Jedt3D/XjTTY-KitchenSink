#tag Class
Protected Class XjPager
	#tag Method, Flags = &h0
		Sub Constructor()
		  mPageSize = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Page(content As String)
		  Var lines() As String = content.Split(Chr(10))
		  Var pageSize As Integer = mPageSize
		  If pageSize <= 0 Then
		    pageSize = XjTerminal.Height - 1
		  End If
		  
		  // If content fits on screen, just print it
		  If lines.Count <= pageSize Then
		    For i As Integer = 0 To lines.Count - 1
		      Print(lines(i))
		    Next
		    Return
		  End If
		  
		  // Enter raw mode for key reading
		  Var wasRaw As Boolean = XjTerminal.IsRawMode
		  If Not wasRaw Then XjTerminal.EnableRawMode
		  XjTerminal.EnableNonBlockingInput
		  
		  Var reader As New XjReader
		  Var lineIndex As Integer = 0
		  
		  While lineIndex < lines.Count
		    // Print one page
		    Var endLine As Integer = lineIndex + pageSize - 1
		    If endLine >= lines.Count Then endLine = lines.Count - 1
		    
		    For i As Integer = lineIndex To endLine
		      XjTerminal.Write(lines(i) + Chr(13) + Chr(10))
		    Next
		    
		    lineIndex = endLine + 1
		    
		    If lineIndex < lines.Count Then
		      // Show prompt
		      Var s As New XjStyle
		      Var pct As Integer = (lineIndex * 100) / lines.Count
		      Var inv As XjStyle = s.SetInverse
		      XjTerminal.Write(inv.Apply("-- More (" + Str(pct) + "%) -- SPACE=next q=quit --"))
		      
		      // Wait for key
		      Var done As Boolean = False
		      While Not done
		        Var key As XjKeyEvent = reader.ReadKey
		        If key <> Nil Then
		          If key.Char = " " Or key.IsEnter Then
		            done = True
		          ElseIf key.Char = "q" Or key.IsEscape Then
		            lineIndex = lines.Count
		            done = True
		          ElseIf key.KeyCode = XjKeyEvent.KEY_DOWN Then
		            // Scroll one line
		            done = True
		            lineIndex = lineIndex - pageSize + 1
		            If lineIndex < endLine + 1 Then lineIndex = endLine + 1
		          End If
		        Else
		          App.DoEvents(10)
		        End If
		      Wend
		      
		      // Erase prompt line
		      XjTerminal.Write(Chr(13) + XjANSI.EraseLine)
		    End If
		  Wend
		  
		  If Not wasRaw Then XjTerminal.DisableRawMode
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetPageSize(lines As Integer) As XjPager
		  mPageSize = lines
		  Return Self
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjPager — Content Pager
		
		Part of XjTTY-Toolkit Phase 5 (Utility Modules).
		Page long content through a built-in terminal pager.
		
		Usage:
		  Var pager As New XjPager
		  pager.Page(longContent)
		
		  // Custom page size:
		  Var pager As New XjPager
		  Call pager.SetPageSize(20)
		  pager.Page(longContent)
		
		Controls:
		  SPACE / Enter = next page
		  Down arrow = scroll one line
		  q / Escape = quit
	#tag EndNote


	#tag Property, Flags = &h21
		Private mPageSize As Integer
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
