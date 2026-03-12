#tag Class
Protected Class XjCollectPrompt
	#tag Method, Flags = &h0
		Sub Constructor()
		  mResults = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddAsk(key As String, question As String, defaultValue As String = "") As XjCollectPrompt
		  mStepTypes.Add(TYPE_ASK)
		  mStepKeys.Add(key)
		  mStepQuestions.Add(question)
		  mStepDefaults.Add(defaultValue)
		  mStepChoices.Add("")
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddConfirm(key As String, question As String) As XjCollectPrompt
		  mStepTypes.Add(TYPE_CONFIRM)
		  mStepKeys.Add(key)
		  mStepQuestions.Add(question)
		  mStepDefaults.Add("")
		  mStepChoices.Add("")
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddPassword(key As String, question As String) As XjCollectPrompt
		  mStepTypes.Add(TYPE_PASSWORD)
		  mStepKeys.Add(key)
		  mStepQuestions.Add(question)
		  mStepDefaults.Add("")
		  mStepChoices.Add("")
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddSelect(key As String, question As String, choices() As String) As XjCollectPrompt
		  mStepTypes.Add(TYPE_SELECT)
		  mStepKeys.Add(key)
		  mStepQuestions.Add(question)
		  mStepDefaults.Add("")

		  // Join choices with semicolon for storage
		  Var joined As String = String.FromArray(choices, ";")
		  mStepChoices.Add(joined)

		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run() As Dictionary
		  For i As Integer = 0 To mStepTypes.Count - 1
		    Var stepType As Integer = mStepTypes(i)
		    Var stepKey As String = mStepKeys(i)
		    Var stepQuestion As String = mStepQuestions(i)

		    Select Case stepType
		    Case TYPE_ASK
		      Var p As New XjAskPrompt(stepQuestion, mStepDefaults(i))
		      Var result As String = p.Run
		      mResults.Value(stepKey) = result

		    Case TYPE_CONFIRM
		      Var p As New XjConfirmPrompt(stepQuestion)
		      Var result As Boolean = p.Run
		      mResults.Value(stepKey) = result

		    Case TYPE_PASSWORD
		      Var p As New XjPasswordPrompt(stepQuestion)
		      Var result As String = p.Run
		      mResults.Value(stepKey) = result

		    Case TYPE_SELECT
		      Var choiceStr As String = mStepChoices(i)
		      Var choices() As String = choiceStr.Split(";")
		      Var p As New XjSelectPrompt(stepQuestion, choices)
		      Var result As String = p.Run
		      mResults.Value(stepKey) = result

		    End Select
		  Next

		  Return mResults
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjCollectPrompt — Sequential Prompt Data Collector

		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Builder for collecting structured data from sequential prompts.

		Usage:
		  Var collect As New XjCollectPrompt
		  Call collect.AddAsk("name", "What is your name?")
		  Call collect.AddPassword("password", "Enter password:")
		  Call collect.AddConfirm("agree", "Do you agree?")
		  Call collect.AddSelect("color", "Pick a color:", Array("Red", "Green", "Blue"))
		  Var results As Dictionary = collect.Run

		  Var name As String = results.Value("name")
		  Var agree As Boolean = results.Value("agree")

		Features:
		- Builder pattern with AddAsk, AddConfirm, AddPassword, AddSelect
		- Runs each prompt sequentially
		- Collects all results into a Dictionary
		- Supports all 4 basic prompt types
	#tag EndNote

	#tag Property, Flags = &h21
		Private mStepTypes() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStepKeys() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStepQuestions() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStepDefaults() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStepChoices() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mResults As Dictionary
	#tag EndProperty


	#tag Constant, Name = TYPE_ASK, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_CONFIRM, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_PASSWORD, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_SELECT, Type = Double, Dynamic = False, Default = \"3", Scope = Public
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
