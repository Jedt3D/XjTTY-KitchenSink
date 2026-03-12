#tag Class
Protected Class XjLogger
	#tag Method, Flags = &h0
		Sub Constructor(name As String = "")
		  mName = name
		  mLevel = LEVEL_INFO
		  mUseColor = True
		  mUseJSON = False
		  mShowTimestamp = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Debug(message As String, meta As String = "")
		  Log(LEVEL_DEBUG, message, meta)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Error_(message As String, meta As String = "")
		  Log(LEVEL_ERROR, message, meta)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function EscapeJSON(s As String) As String
		  Var result As String = s
		  result = result.ReplaceAll(Chr(34), "'" )
		  result = result.ReplaceAll(Chr(10), " ")
		  result = result.ReplaceAll(Chr(13), " ")
		  result = result.ReplaceAll(Chr(9), " ")
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Fatal(message As String, meta As String = "")
		  Log(LEVEL_FATAL, message, meta)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FormatJSON(level As Integer, message As String, meta As String) As String
		  Var d As DateTime = DateTime.Now
		  Var q As String = Chr(34)
		  Var parts() As String
		  parts.Add("{" + q + "time" + q + ":" + q + d.SQLDateTime + q)
		  parts.Add("," + q + "level" + q + ":" + q + LevelName(level).Trim + q)
		  If mName <> "" Then
		    parts.Add("," + q + "logger" + q + ":" + q + mName + q)
		  End If
		  parts.Add("," + q + "msg" + q + ":" + q + EscapeJSON(message) + q)
		  If meta <> "" Then
		    parts.Add("," + q + "meta" + q + ":" + q + EscapeJSON(meta) + q)
		  End If
		  parts.Add("}")
		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FormatText(level As Integer, message As String, meta As String) As String
		  Var parts() As String
		  
		  // Timestamp
		  If mShowTimestamp Then
		    Var d As DateTime = DateTime.Now
		    Var ts As String = d.SQLDateTime
		    If mUseColor Then
		      Var s As New XjStyle
		      parts.Add(s.SetFG(90).Apply(ts))
		    Else
		      parts.Add(ts)
		    End If
		  End If
		  
		  // Level label
		  Var label As String = LevelName(level)
		  If mUseColor Then
		    Var s As New XjStyle
		    Select Case level
		    Case LEVEL_DEBUG
		      parts.Add(s.SetFG(XjANSI.FG_CYAN).Apply(label))
		    Case LEVEL_INFO
		      parts.Add(s.SetFG(XjANSI.FG_GREEN).Apply(label))
		    Case LEVEL_WARN
		      parts.Add(s.SetFG(XjANSI.FG_YELLOW).Apply(label))
		    Case LEVEL_ERROR
		      parts.Add(s.SetFG(XjANSI.FG_RED).Apply(label))
		    Case LEVEL_FATAL
		      Var sf As New XjStyle
		      Var sfBold As XjStyle = sf.SetFG(XjANSI.FG_RED).SetBold
		      parts.Add(sfBold.Apply(label))
		    End Select
		  Else
		    parts.Add(label)
		  End If
		  
		  // Logger name
		  If mName <> "" Then
		    If mUseColor Then
		      Var s As New XjStyle
		      parts.Add(s.SetFG(XjANSI.FG_MAGENTA).Apply("[" + mName + "]"))
		    Else
		      parts.Add("[" + mName + "]")
		    End If
		  End If
		  
		  // Message
		  parts.Add(message)
		  
		  // Metadata
		  If meta <> "" Then
		    If mUseColor Then
		      Var s As New XjStyle
		      parts.Add(s.SetFG(90).Apply(meta))
		    Else
		      parts.Add(meta)
		    End If
		  End If
		  
		  Return String.FromArray(parts, " ")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Info(message As String, meta As String = "")
		  Log(LEVEL_INFO, message, meta)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LevelName(level As Integer) As String
		  Select Case level
		  Case LEVEL_DEBUG
		    Return "DEBUG"
		  Case LEVEL_INFO
		    Return "INFO "
		  Case LEVEL_WARN
		    Return "WARN "
		  Case LEVEL_ERROR
		    Return "ERROR"
		  Case LEVEL_FATAL
		    Return "FATAL"
		  End Select
		  Return "??   "
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Log(level As Integer, message As String, meta As String)
		  If level < mLevel Then Return
		  
		  Var output As String
		  
		  If mUseJSON Then
		    output = FormatJSON(level, message, meta)
		  Else
		    output = FormatText(level, message, meta)
		  End If
		  
		  Print(output)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetColor(useColor As Boolean) As XjLogger
		  mUseColor = useColor
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetJSON(useJSON As Boolean) As XjLogger
		  mUseJSON = useJSON
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetLevel(level As Integer) As XjLogger
		  mLevel = level
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetTimestamp(show As Boolean) As XjLogger
		  mShowTimestamp = show
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Warn(message As String, meta As String = "")
		  Log(LEVEL_WARN, message, meta)
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjLogger — Structured Colored Logger
		
		Part of XjTTY-Toolkit Phase 5 (Utility Modules).
		Logging with levels, color, JSON format, metadata.
		
		Usage:
		  Var log As New XjLogger("MyApp")
		  log.Info("Server started", "port=8080")
		  log.Warn("Slow query", "duration=2.5s")
		  log.Error_("Connection failed")
	#tag EndNote


	#tag Property, Flags = &h21
		Private mLevel As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowTimestamp As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUseColor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUseJSON As Boolean
	#tag EndProperty


	#tag Constant, Name = LEVEL_DEBUG, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LEVEL_ERROR, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LEVEL_FATAL, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LEVEL_INFO, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LEVEL_WARN, Type = Double, Dynamic = False, Default = \"2", Scope = Public
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
