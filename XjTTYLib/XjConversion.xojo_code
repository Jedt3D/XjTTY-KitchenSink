#tag Module
Protected Module XjConversion
	#tag Method, Flags = &h0
		Function ApplyModifier(value As String, modifier As Integer) As String
		  Select Case modifier
		  Case MOD_UP
		    Return value.Uppercase
		  Case MOD_DOWN
		    Return value.Lowercase
		  Case MOD_CAPITALIZE
		    If value.Length = 0 Then Return value
		    Return value.Left(1).Uppercase + value.Middle(1).Lowercase
		  Case MOD_STRIP
		    Return value.Trim
		  Case Else
		    Return value
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToBool(value As String) As Boolean
		  Var v As String = value.Trim.Lowercase
		  Return v = "y" Or v = "yes" Or v = "true" Or v = "1" Or v = "t"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToDouble(value As String, ByRef result As Double) As Boolean
		  If value.Trim = "" Then Return False
		  result = CDbl(value)
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToInteger(value As String, ByRef result As Integer) As Boolean
		  If value.Trim = "" Then Return False
		  result = Val(value)
		  // Check it was actually numeric
		  Return Str(result) = value.Trim Or value.Trim = "0"
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjConversion — Type Conversion and Input Modifiers
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Converts string input to typed values and applies modifiers.
	#tag EndNote


	#tag Constant, Name = MOD_CAPITALIZE, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MOD_DOWN, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MOD_NONE, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MOD_STRIP, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MOD_UP, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant


End Module
#tag EndModule
