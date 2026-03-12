#tag Class
Protected Class XjConstraint
	#tag Method, Flags = &h0
		Shared Function Auto() As XjConstraint
		  Return New XjConstraint
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clone() As XjConstraint
		  Var c As New XjConstraint
		  c.mMode = mMode
		  c.mValue = mValue
		  c.mMinValue = mMinValue
		  c.mMaxValue = mMaxValue
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  mMode = MODE_AUTO
		  mValue = 0
		  mMinValue = -1
		  mMaxValue = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Fixed(value As Integer) As XjConstraint
		  Var c As New XjConstraint
		  c.mMode = MODE_FIXED
		  c.mValue = value
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsAuto() As Boolean
		  Return mMode = MODE_AUTO
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsFixed() As Boolean
		  Return mMode = MODE_FIXED
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsPercent() As Boolean
		  Return mMode = MODE_PERCENT
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MaxValue() As Double
		  Return mMaxValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function MinMax(minVal As Integer, maxVal As Integer) As XjConstraint
		  Var c As New XjConstraint
		  c.mMode = MODE_AUTO
		  c.mMinValue = minVal
		  c.mMaxValue = maxVal
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MinValue() As Double
		  Return mMinValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Mode() As Integer
		  Return mMode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Percent(value As Double) As XjConstraint
		  Var c As New XjConstraint
		  c.mMode = MODE_PERCENT
		  c.mValue = value
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Resolve(available As Integer) As Integer
		  // Given available space from parent, return resolved size
		  Var result As Integer
		  
		  Select Case mMode
		  Case MODE_FIXED
		    result = CType(mValue, Integer)
		  Case MODE_PERCENT
		    result = Floor(available * mValue / 100.0)
		  Case Else
		    // MODE_AUTO
		    result = available
		  End Select
		  
		  // Clamp to min/max
		  If mMinValue >= 0 And result < CType(mMinValue, Integer) Then
		    result = CType(mMinValue, Integer)
		  End If
		  If mMaxValue >= 0 And result > CType(mMaxValue, Integer) Then
		    result = CType(mMaxValue, Integer)
		  End If
		  
		  If result < 0 Then result = 0
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMax(v As Integer) As XjConstraint
		  Var c As XjConstraint = Clone
		  c.mMaxValue = v
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetMin(v As Integer) As XjConstraint
		  Var c As XjConstraint = Clone
		  c.mMinValue = v
		  Return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value() As Double
		  Return mValue
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjConstraint — Size Constraint
		
		Part of XjTTY-Toolkit Phase 2 (Layout Engine).
		Represents a size rule for one dimension (width or height).
		
		Modes:
		  MODE_AUTO    — fill remaining space (like flex: 1)
		  MODE_FIXED   — exact character/row count
		  MODE_PERCENT — percentage of parent's available space
		
		Usage:
		  XjConstraint.Fixed(3)     // exactly 3 rows
		  XjConstraint.Percent(25)  // 25% of parent
		  XjConstraint.Auto         // fill remaining
		  XjConstraint.MinMax(10, 40)  // auto with floor/ceiling
	#tag EndNote


	#tag Property, Flags = &h21
		Private mMaxValue As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMinValue As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMode As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValue As Double
	#tag EndProperty


	#tag Constant, Name = MODE_AUTO, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MODE_FIXED, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MODE_PERCENT, Type = Double, Dynamic = False, Default = \"2", Scope = Public
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
