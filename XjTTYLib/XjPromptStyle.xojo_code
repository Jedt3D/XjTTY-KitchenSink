#tag Class
Protected Class XjPromptStyle
	#tag Method, Flags = &h0
		Sub Constructor()
		  Var base As New XjStyle
		  PrefixStyle = base.SetFG(XjANSI.FG_GREEN).SetBold
		  QuestionStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE).SetBold
		  AnswerStyle = base.SetFG(XjANSI.FG_CYAN)
		  HelpStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  ErrorStyle = base.SetFG(XjANSI.FG_RED)
		  ActiveStyle = base.SetFG(XjANSI.FG_CYAN)
		  InactiveStyle = base.SetFG(XjANSI.FG_WHITE)
		  DisabledStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		  CursorStyle = base.SetInverse
		  FilterStyle = base.SetFG(XjANSI.FG_CYAN)
		  PlaceholderStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Default_() As XjPromptStyle
		  If mDefault Is Nil Then
		    mDefault = New XjPromptStyle
		  End If
		  Return mDefault
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjPromptStyle — Prompt Color Configuration
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Holds style/color settings for all prompt types.
	#tag EndNote


	#tag Property, Flags = &h0
		ActiveStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		AnswerStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		CursorStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		DisabledStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		ErrorStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		FilterStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		HelpStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		InactiveStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mDefault As XjPromptStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		PlaceholderStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		PrefixStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h0
		QuestionStyle As XjStyle
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
