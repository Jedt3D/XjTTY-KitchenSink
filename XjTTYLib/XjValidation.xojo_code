#tag Class
Protected Class XjValidation
	#tag Method, Flags = &h0
		Sub Constructor()
		  mRuleType = RULE_REQUIRED
		  mMessage = ""
		  mPattern = ""
		  mMinLength = 0
		  mMaxLength = 0
		  mMinInt = 0
		  mMaxInt = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function InList(values() As String, message As String = "") As XjValidation
		  Var v As New XjValidation
		  v.mRuleType = RULE_IN_LIST
		  For i As Integer = 0 To values.Count - 1
		    v.mAllowedValues.Add(values(i))
		  Next
		  v.mMessage = message
		  Return v
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function MaxLength(n As Integer, message As String = "") As XjValidation
		  Var v As New XjValidation
		  v.mRuleType = RULE_MAX_LENGTH
		  v.mMaxLength = n
		  v.mMessage = message
		  Return v
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function MinLength(n As Integer, message As String = "") As XjValidation
		  Var v As New XjValidation
		  v.mRuleType = RULE_MIN_LENGTH
		  v.mMinLength = n
		  v.mMessage = message
		  Return v
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function RangeInt(min As Integer, max As Integer, message As String = "") As XjValidation
		  Var v As New XjValidation
		  v.mRuleType = RULE_RANGE_INT
		  v.mMinInt = min
		  v.mMaxInt = max
		  v.mMessage = message
		  Return v
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Required(message As String = "") As XjValidation
		  Var v As New XjValidation
		  v.mRuleType = RULE_REQUIRED
		  v.mMessage = message
		  Return v
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Validate(value As String, ByRef errorMsg As String) As Boolean
		  Select Case mRuleType
		  Case RULE_REQUIRED
		    If value.Trim = "" Then
		      errorMsg = mMessage
		      If errorMsg = "" Then errorMsg = "This field is required"
		      Return False
		    End If
		    
		  Case RULE_MIN_LENGTH
		    If value.Length < mMinLength Then
		      errorMsg = mMessage
		      If errorMsg = "" Then errorMsg = "Must be at least " + Str(mMinLength) + " characters"
		      Return False
		    End If
		    
		  Case RULE_MAX_LENGTH
		    If value.Length > mMaxLength Then
		      errorMsg = mMessage
		      If errorMsg = "" Then errorMsg = "Must be at most " + Str(mMaxLength) + " characters"
		      Return False
		    End If
		    
		  Case RULE_RANGE_INT
		    Var v As Integer = Val(value)
		    If v < mMinInt Or v > mMaxInt Then
		      errorMsg = mMessage
		      If errorMsg = "" Then errorMsg = "Must be between " + Str(mMinInt) + " and " + Str(mMaxInt)
		      Return False
		    End If
		    
		  Case RULE_IN_LIST
		    Var found As Boolean = False
		    For i As Integer = 0 To mAllowedValues.Count - 1
		      If value = mAllowedValues(i) Then
		        found = True
		        Exit
		      End If
		    Next
		    If Not found Then
		      errorMsg = mMessage
		      If errorMsg = "" Then errorMsg = "Invalid choice"
		      Return False
		    End If
		    
		  End Select
		  
		  Return True
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjValidation — Input Validation Rules
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Factory methods create validation rules:
		  XjValidation.Required()
		  XjValidation.MinLength(3)
		  XjValidation.RangeInt(1, 100)
	#tag EndNote


	#tag Property, Flags = &h21
		Private mAllowedValues() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMaxInt As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMaxLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMessage As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMinInt As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMinLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPattern As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRuleType As Integer
	#tag EndProperty


	#tag Constant, Name = RULE_IN_LIST, Type = Double, Dynamic = False, Default = \"6", Scope = Public
	#tag EndConstant

	#tag Constant, Name = RULE_MAX_LENGTH, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = RULE_MIN_LENGTH, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = RULE_RANGE_INT, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = RULE_REQUIRED, Type = Double, Dynamic = False, Default = \"0", Scope = Public
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
