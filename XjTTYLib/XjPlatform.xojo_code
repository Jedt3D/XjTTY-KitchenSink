#tag Module
Protected Module XjPlatform
	#tag Method, Flags = &h0
		Function Architecture() As String
		  #If TargetARM Then
		    #If Target64Bit Then
		      Return "arm64"
		    #Else
		      Return "arm"
		    #EndIf
		  #Else
		    #If Target64Bit Then
		      Return "x86_64"
		    #Else
		      Return "x86"
		    #EndIf
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Is64Bit() As Boolean
		  #If Target64Bit Then
		    Return True
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsARM() As Boolean
		  #If TargetARM Then
		    Return True
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsLinux() As Boolean
		  #If TargetLinux Then
		    Return True
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsMacOS() As Boolean
		  #If TargetMacOS Then
		    Return True
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsUnix() As Boolean
		  #If TargetMacOS Or TargetLinux Then
		    Return True
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsWindows() As Boolean
		  #If TargetWindows Then
		    Return True
		  #Else
		    Return False
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OSName() As String
		  #If TargetMacOS Then
		    Return "macOS"
		  #ElseIf TargetLinux Then
		    Return "Linux"
		  #ElseIf TargetWindows Then
		    Return "Windows"
		  #Else
		    Return "Unknown"
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function PlatformInfo() As String
		  Return OSName + " " + Architecture + " (" + If(Is64Bit, "64-bit", "32-bit") + ")"
		End Function
	#tag EndMethod


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
End Module
#tag EndModule
