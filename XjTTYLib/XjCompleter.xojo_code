#tag Class
Protected Class XjCompleter
	#tag Method, Flags = &h0
		Function Complete(input As String) As String()
		  // Case-insensitive prefix match
		  Var results() As String
		  If input = "" Then Return results
		  
		  Var inputLower As String = input.Lowercase
		  
		  For i As Integer = 0 To mWords.Count - 1
		    If mWordsLower(i).Left(inputLower.Length) = inputLower Then
		      results.Add(mWords(i))
		    End If
		  Next
		  
		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(words() As String)
		  For i As Integer = 0 To words.Count - 1
		    mWords.Add(words(i))
		    mWordsLower.Add(words(i).Lowercase)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function FromWords(words() As String) As XjCompleter
		  Var c As New XjCompleter(words)
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FuzzyComplete(input As String) As String()
		  // Characters appear in order (not necessarily contiguous)
		  Var results() As String
		  If input = "" Then Return results
		  
		  Var inputLower As String = input.Lowercase
		  
		  For i As Integer = 0 To mWords.Count - 1
		    If FuzzyMatch(inputLower, mWordsLower(i)) Then
		      results.Add(mWords(i))
		    End If
		  Next
		  
		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FuzzyMatch(pattern As String, target As String) As Boolean
		  // Check if all characters in pattern appear in target in order
		  Var pi As Integer = 0
		  Var ti As Integer = 0
		  
		  While pi < pattern.Length And ti < target.Length
		    If pattern.Middle(pi, 1) = target.Middle(ti, 1) Then
		      pi = pi + 1
		    End If
		    ti = ti + 1
		  Wend
		  
		  Return pi >= pattern.Length
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Words() As String()
		  Var result() As String
		  For i As Integer = 0 To mWords.Count - 1
		    result.Add(mWords(i))
		  Next
		  Return result
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjCompleter — Completion/Suggestion Provider
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Provides prefix and fuzzy completion matching for XjSuggestPrompt.
		
		Usage:
		  Var words() As String = Array("New York", "New Jersey", "Newark")
		  Var c As XjCompleter = XjCompleter.FromWords(words)
		  Var matches() As String = c.Complete("New")
		  // Returns: "New York", "New Jersey", "Newark"
		
		  Var fuzzy() As String = c.FuzzyComplete("nwk")
		  // Returns: "Newark"
	#tag EndNote


	#tag Property, Flags = &h21
		Private mWords() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWordsLower() As String
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
