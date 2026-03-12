#tag Module
Protected Module XjCommand
	#tag Method, Flags = &h0
		Function Capture(command As String, timeoutSeconds As Integer = 30) As String
		  // Run and return stdout only
		  Var sh As New Shell
		  sh.TimeOut = timeoutSeconds
		  sh.Execute(command)
		  Return sh.Result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DryRun(command As String) As String
		  // Return what would be executed without actually running it
		  Return "[dry-run] " + command
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Run(command As String, timeoutSeconds As Integer = 30) As XjCommandResult
		  Var result As New XjCommandResult
		  
		  Var sh As New Shell
		  sh.TimeOut = timeoutSeconds
		  
		  sh.Execute(command)
		  
		  result.Output = sh.Result
		  result.ExitCode = sh.ExitCode
		  result.TimedOut = (sh.ExitCode = -1 And sh.Result = "")
		  
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RunSilent(command As String, timeoutSeconds As Integer = 30) As Integer
		  // Run and return only exit code
		  Var sh As New Shell
		  sh.TimeOut = timeoutSeconds
		  sh.Execute(command)
		  Return sh.ExitCode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RunWithPrinter(command As String, timeoutSeconds As Integer = 30) As Integer
		  // Run and print output in real-time style
		  Var result As XjCommandResult = Run(command, timeoutSeconds)
		  
		  If result.Output <> "" Then
		    Print(result.Output)
		  End If
		  
		  Return result.ExitCode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Success(command As String, timeoutSeconds As Integer = 30) As Boolean
		  // Run and return whether it succeeded
		  Return RunSilent(command, timeoutSeconds) = 0
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjCommand — Shell Command Execution
		
		Part of XjTTY-Toolkit (Polish phase).
		Execute shell commands with output capture, timeout, and dry-run.
		
		Usage:
		  Var result As XjCommandResult = XjCommand.Run("ls -la")
		  Print(result.Output)
		  If result.ExitCode = 0 Then Print("Success!")
		
		  Var output As String = XjCommand.Capture("git status")
		  If XjCommand.Success("which git") Then Print("git found")
	#tag EndNote


End Module
#tag EndModule
