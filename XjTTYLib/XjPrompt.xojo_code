#tag Module
Protected Module XjPrompt
	#tag Method, Flags = &h0
		Function Ask(question As String, defaultValue As String = "") As String
		  Var p As New XjAskPrompt(question, defaultValue)
		  Call p.SetPromptStyle(GetStyle)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AskValidated(question As String, defaultValue As String, validators() As XjValidation) As String
		  Var p As New XjAskPrompt(question, defaultValue)
		  Call p.SetPromptStyle(GetStyle)
		  For i As Integer = 0 To validators.Count - 1
		    Call p.AddValidation(validators(i))
		  Next
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AskWithHistory(question As String, history As XjHistory, defaultValue As String = "") As String
		  Var p As New XjAskPrompt(question, defaultValue)
		  Call p.SetPromptStyle(GetStyle)
		  Call p.SetHistory(history)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Collect() As XjCollectPrompt
		  Return New XjCollectPrompt
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Confirm(question As String, defaultYes As Boolean = True) As Boolean
		  Var p As New XjConfirmPrompt(question, defaultYes)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Deny(question As String, defaultNo As Boolean = True) As Boolean
		  // Deny is Confirm with inverted default
		  Return Not Confirm(question, Not defaultNo)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EnumSelect(question As String, choices() As String) As String
		  Var p As New XjEnumSelectPrompt(question, choices)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Error_(message As String)
		  XjSymbols.EnsureInit
		  Var base As New XjStyle
		  Print base.SetFG(XjANSI.FG_RED).Apply(XjSymbols.Cross + " " + message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Expand(question As String, choices() As String, keys() As String) As String
		  Var p As New XjExpandPrompt(question, choices, keys)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetStyle() As XjPromptStyle
		  If mStyle Is Nil Then
		    Return XjPromptStyle.Default_
		  End If
		  Return mStyle
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function KeyPress(question As String, timeoutMs As Integer = -1) As XjKeyEvent
		  Var p As New XjKeyPressPrompt(question, timeoutMs)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MultiLine(question As String) As String
		  Var p As New XjMultiLinePrompt(question)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MultiSelect(question As String, choices() As String, minCount As Integer = 0, maxCount As Integer = -1) As String()
		  Var p As New XjMultiSelectPrompt(question, choices)
		  Call p.SetMinMax(minCount, maxCount)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Ok(message As String)
		  XjSymbols.EnsureInit
		  Var base As New XjStyle
		  Print base.SetFG(XjANSI.FG_GREEN).Apply(XjSymbols.Check + " " + message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Password(question As String, mask As String = "") As String
		  Var p As New XjPasswordPrompt(question, mask)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Say(message As String)
		  XjSymbols.EnsureInit
		  Var base As New XjStyle
		  Print base.SetFG(XjANSI.FG_WHITE).Apply(message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Select_(question As String, choices() As String, perPage As Integer = 7) As String
		  Var p As New XjSelectPrompt(question, choices)
		  Call p.SetPerPage(perPage)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetStyle(style As XjPromptStyle)
		  mStyle = style
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Slider(question As String, min As Integer, max As Integer, step_ As Integer, defaultValue As Integer) As Integer
		  Var p As New XjSliderPrompt(question, min, max, step_, defaultValue)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Suggest(question As String, suggestions() As String) As String
		  Var c As XjCompleter = XjCompleter.FromWords(suggestions)
		  Var p As New XjSuggestPrompt(question, c)
		  Return p.Run
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Warn(message As String)
		  XjSymbols.EnsureInit
		  Var base As New XjStyle
		  Print base.SetFG(XjANSI.FG_YELLOW).Apply("! " + message)
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjPrompt — Prompt System Facade
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Top-level API for all 13 prompt types plus output helpers.
		
		Usage:
		  Var name As String = XjPrompt.Ask("What is your name?")
		  Var sure As Boolean = XjPrompt.Confirm("Are you sure?")
		  Var pass As String = XjPrompt.Password("Enter password:")
		  Var color As String = XjPrompt.Select_("Color:", colors)
		
		  XjPrompt.Ok("All done!")
		  XjPrompt.Warn("Be careful")
		  XjPrompt.Error_("Something failed")
	#tag EndNote


	#tag Property, Flags = &h21
		Private mStyle As XjPromptStyle
	#tag EndProperty


End Module
#tag EndModule
