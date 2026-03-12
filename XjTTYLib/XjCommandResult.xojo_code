#tag Class
Protected Class XjCommandResult
	#tag Method, Flags = &h0
		Sub Constructor()
		  Output = ""
		  ExitCode = -1
		  TimedOut = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsSuccess() As Boolean
		  Return ExitCode = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Lines() As String()
		  Return Output.Split(Chr(10))
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjCommandResult — Shell Command Output

		Part of XjTTY-Toolkit (Polish phase).
		Holds the result of an XjCommand.Run call.
	#tag EndNote

	#tag Property, Flags = &h0
		Output As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ExitCode As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		TimedOut As Boolean
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
