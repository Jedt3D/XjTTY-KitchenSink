#tag Class
Protected Class XjHistory
	#tag Method, Flags = &h0
		Sub Add(entry As String)
		  If entry.Trim = "" Then Return
		  
		  // Don't add duplicates of the last entry
		  If mEntries.Count > 0 And mEntries(mEntries.Count - 1) = entry Then Return
		  
		  mEntries.Add(entry)
		  
		  // Trim to max size (only 1 entry added, so at most 1 removal)
		  If mEntries.Count > mMaxSize Then
		    mEntries.RemoveAt(0)
		  End If
		  
		  Reset
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Clear()
		  mEntries.RemoveAll
		  Reset
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(maxSize As Integer = 100)
		  mMaxSize = maxSize
		  mIndex = -1
		  mSaved = ""
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count() As Integer
		  Return mEntries.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsNavigating() As Boolean
		  Return mIndex < mEntries.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Next_(currentValue As String) As String
		  #Pragma Unused currentValue
		  If mEntries.Count = 0 Then Return mSaved
		  
		  If mIndex < mEntries.Count - 1 Then
		    mIndex = mIndex + 1
		    Return mEntries(mIndex)
		  ElseIf mIndex = mEntries.Count - 1 Then
		    mIndex = mEntries.Count
		    Return mSaved
		  End If
		  
		  Return mSaved
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Previous(currentValue As String) As String
		  If mEntries.Count = 0 Then Return currentValue
		  
		  // Save current input on first navigation
		  If mIndex = mEntries.Count Then
		    mSaved = currentValue
		  End If
		  
		  If mIndex > 0 Then
		    mIndex = mIndex - 1
		  End If
		  
		  Return mEntries(mIndex)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  mIndex = mEntries.Count
		  mSaved = ""
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjHistory — Input History
		
		Part of XjTTY-Toolkit (Polish phase).
		Provides up/down arrow history for text input prompts.
		
		Usage:
		  Var history As New XjHistory
		  history.Add("previous input")
		  Var recalled As String = history.Previous(currentInput)
		  Var next_ As String = history.Next_(currentInput)
	#tag EndNote


	#tag Property, Flags = &h21
		Private mEntries() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndex As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMaxSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSaved As String
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
