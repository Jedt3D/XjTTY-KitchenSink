#tag Class
Protected Class XjOption
	#tag Method, Flags = &h0
		Function AddArgument(name As String, desc As String, required As Boolean = False) As XjOption
		  mArgNames.Add(name)
		  mArgDescs.Add(desc)
		  mArgRequired.Add(required)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddFlag(name As String, shortFlag As String, longFlag As String, desc As String) As XjOption
		  mOptNames.Add(name)
		  mOptShorts.Add(shortFlag)
		  mOptLongs.Add(longFlag)
		  mOptDescs.Add(desc)
		  mOptDefaults.Add("")
		  mOptIsFlag.Add(True)
		  // Build O(1) lookup maps
		  Var idx As Integer = mOptNames.Count - 1
		  If shortFlag <> "" Then mShortMap.Value(shortFlag) = idx
		  If longFlag <> "" Then mLongMap.Value(longFlag) = idx
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AddOption(name As String, shortFlag As String, longFlag As String, desc As String, defaultValue As String = "") As XjOption
		  mOptNames.Add(name)
		  mOptShorts.Add(shortFlag)
		  mOptLongs.Add(longFlag)
		  mOptDescs.Add(desc)
		  mOptDefaults.Add(defaultValue)
		  mOptIsFlag.Add(False)
		  // Build O(1) lookup maps
		  Var idx As Integer = mOptNames.Count - 1
		  If shortFlag <> "" Then mShortMap.Value(shortFlag) = idx
		  If longFlag <> "" Then mLongMap.Value(longFlag) = idx
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(appName As String = "", appDesc As String = "")
		  mAppName = appName
		  mAppDesc = appDesc
		  mValues = New Dictionary
		  mShortMap = New Dictionary
		  mLongMap = New Dictionary
		  mParsed = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FindByLong(flag As String) As Integer
		  If mLongMap.HasKey(flag) Then Return mLongMap.Value(flag)
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FindByShort(flag As String) As Integer
		  If mShortMap.HasKey(flag) Then Return mShortMap.Value(flag)
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetFlag(name As String) As Boolean
		  If mValues.HasKey(name) Then
		    Return mValues.Value(name).StringValue = "true"
		  End If
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetInteger(name As String, defaultValue As Integer = 0) As Integer
		  If mValues.HasKey(name) Then
		    Return Val(mValues.Value(name).StringValue)
		  End If
		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetString(name As String, defaultValue As String = "") As String
		  If mValues.HasKey(name) Then
		    Return mValues.Value(name).StringValue
		  End If
		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(name As String) As Boolean
		  Return mValues.HasKey(name)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Help() As String
		  Var lines() As String
		  
		  // Usage line
		  Var usage As String = "Usage: " + mAppName
		  If mOptNames.Count > 0 Then usage = usage + " [options]"
		  For i As Integer = 0 To mArgNames.Count - 1
		    If mArgRequired(i) Then
		      usage = usage + " <" + mArgNames(i) + ">"
		    Else
		      usage = usage + " [" + mArgNames(i) + "]"
		    End If
		  Next
		  lines.Add(usage)
		  
		  // Description
		  If mAppDesc <> "" Then
		    lines.Add("")
		    lines.Add(mAppDesc)
		  End If
		  
		  // Options
		  If mOptNames.Count > 0 Then
		    lines.Add("")
		    lines.Add("Options:")
		    For i As Integer = 0 To mOptNames.Count - 1
		      Var flags As String = "  "
		      If mOptShorts(i) <> "" Then
		        flags = flags + "-" + mOptShorts(i)
		        If mOptLongs(i) <> "" Then flags = flags + ", "
		      Else
		        flags = flags + "    "
		      End If
		      If mOptLongs(i) <> "" Then
		        flags = flags + "--" + mOptLongs(i)
		      End If
		      // Pad to 24 chars
		      While flags.Length < 24
		        flags = flags + " "
		      Wend
		      Var line As String = flags + mOptDescs(i)
		      If Not mOptIsFlag(i) And mOptDefaults(i) <> "" Then
		        line = line + " (default: " + mOptDefaults(i) + ")"
		      End If
		      lines.Add(line)
		    Next
		  End If
		  
		  // Arguments
		  If mArgNames.Count > 0 Then
		    lines.Add("")
		    lines.Add("Arguments:")
		    For i As Integer = 0 To mArgNames.Count - 1
		      Var argLine As String = "  " + mArgNames(i)
		      While argLine.Length < 24
		        argLine = argLine + " "
		      Wend
		      argLine = argLine + mArgDescs(i)
		      If mArgRequired(i) Then argLine = argLine + " (required)"
		      lines.Add(argLine)
		    Next
		  End If
		  
		  Return String.FromArray(lines, EndOfLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Parse(args() As String) As Boolean
		  mValues = New Dictionary
		  mParsed = True
		  Var positionals() As String
		  
		  // Set defaults
		  For i As Integer = 0 To mOptNames.Count - 1
		    If mOptIsFlag(i) Then
		      mValues.Value(mOptNames(i)) = "false"
		    ElseIf mOptDefaults(i) <> "" Then
		      mValues.Value(mOptNames(i)) = mOptDefaults(i)
		    End If
		  Next
		  
		  Var idx As Integer = 0
		  While idx < args.Count
		    Var arg As String = args(idx)
		    
		    If arg.Left(2) = "--" Then
		      // Long option
		      Var eqPos As Integer = arg.IndexOf("=")
		      Var optName As String
		      Var optVal As String
		      
		      If eqPos >= 0 Then
		        optName = arg.Middle(2, eqPos - 2)
		        optVal = arg.Middle(eqPos + 1)
		      Else
		        optName = arg.Middle(2)
		        optVal = ""
		      End If
		      
		      Var found As Integer = FindByLong(optName)
		      If found >= 0 Then
		        If mOptIsFlag(found) Then
		          mValues.Value(mOptNames(found)) = "true"
		        Else
		          If optVal = "" And idx + 1 < args.Count Then
		            idx = idx + 1
		            optVal = args(idx)
		          End If
		          mValues.Value(mOptNames(found)) = optVal
		        End If
		      End If
		      
		    ElseIf arg.Left(1) = "-" And arg.Length > 1 Then
		      // Short option
		      Var shortName As String = arg.Middle(1, 1)
		      Var found As Integer = FindByShort(shortName)
		      If found >= 0 Then
		        If mOptIsFlag(found) Then
		          mValues.Value(mOptNames(found)) = "true"
		        Else
		          Var optVal As String = ""
		          If arg.Length > 2 Then
		            optVal = arg.Middle(2)
		          ElseIf idx + 1 < args.Count Then
		            idx = idx + 1
		            optVal = args(idx)
		          End If
		          mValues.Value(mOptNames(found)) = optVal
		        End If
		      End If
		      
		    Else
		      // Positional argument
		      positionals.Add(arg)
		    End If
		    
		    idx = idx + 1
		  Wend
		  
		  // Assign positionals
		  For i As Integer = 0 To mArgNames.Count - 1
		    If i < positionals.Count Then
		      mValues.Value(mArgNames(i)) = positionals(i)
		    End If
		  Next
		  
		  // Store remainder
		  If positionals.Count > mArgNames.Count Then
		    For i As Integer = mArgNames.Count To positionals.Count - 1
		      mRemainder.Add(positionals(i))
		    Next
		  End If
		  
		  // Check required arguments
		  For i As Integer = 0 To mArgNames.Count - 1
		    If mArgRequired(i) And Not mValues.HasKey(mArgNames(i)) Then
		      Return False
		    End If
		  Next
		  
		  Return True
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjOption — CLI Argument Parser
		
		Part of XjTTY-Toolkit Phase 5 (Utility Modules).
		Declarative CLI argument parsing with auto-generated help.
		
		Usage:
		  Var opt As New XjOption("myapp", "My application")
		  Call opt.AddOption("output", "o", "output", "Output file", "out.txt")
		  Call opt.AddFlag("verbose", "v", "verbose", "Verbose mode")
		  Call opt.AddArgument("input", "Input file", True)
		  Call opt.Parse(args)
		
		  Var file As String = opt.GetString("output")
		  If opt.GetFlag("verbose") Then ...
	#tag EndNote


	#tag Property, Flags = &h21
		Private mAppDesc As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mAppName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mArgDescs() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mArgNames() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mArgRequired() As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLongMap As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOptDefaults() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOptDescs() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOptIsFlag() As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOptLongs() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOptNames() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOptShorts() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mParsed As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRemainder() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShortMap As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValues As Dictionary
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
