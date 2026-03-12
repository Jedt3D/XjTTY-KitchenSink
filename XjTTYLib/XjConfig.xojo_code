#tag Class
Protected Class XjConfig
	#tag Method, Flags = &h0
		Sub Constructor()
		  mData = New Dictionary
		  mEnvPrefix = ""
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Count() As Integer
		  Return mData.Count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Get(key As String, defaultValue As String = "") As String
		  // Check environment override first
		  If mEnvPrefix <> "" Then
		    Var envKey As String = mEnvPrefix + "_" + key.ReplaceAll(".", "_").Uppercase
		    Var envVal As String = System.EnvironmentVariable(envKey)
		    If envVal <> "" Then Return envVal
		  End If
		  
		  If mData.HasKey(key) Then
		    Return mData.Value(key).StringValue
		  End If
		  Return defaultValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetBoolean(key As String, defaultValue As Boolean = False) As Boolean
		  Var v As String = Get(key, If(defaultValue, "true", "false"))
		  Return v = "true" Or v = "1" Or v = "yes"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetInteger(key As String, defaultValue As Integer = 0) As Integer
		  Var v As String = Get(key, Str(defaultValue))
		  Return Val(v)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Has(key As String) As Boolean
		  Return mData.HasKey(key)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Keys() As String()
		  Var result() As String
		  For Each key As Variant In mData.Keys
		    result.Add(key.StringValue)
		  Next
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadFromFile(f As FolderItem)
		  If f Is Nil Or Not f.Exists Then Return
		  
		  Var tis As TextInputStream = TextInputStream.Open(f)
		  While Not tis.EndOfFile
		    Var line As String = tis.ReadLine.Trim
		    // Skip empty lines and comments
		    If line = "" Or line.Left(1) = "#" Then Continue
		    
		    Var eqPos As Integer = line.IndexOf("=")
		    If eqPos >= 0 Then
		      Var key As String = line.Left(eqPos).Trim
		      Var value As String = line.Middle(eqPos + 1).Trim
		      mData.Value(key) = value
		    End If
		  Wend
		  tis.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Merge(other As XjConfig) As XjConfig
		  // Merge another config into this one (other values win)
		  Var otherKeys() As String = other.Keys
		  For i As Integer = 0 To otherKeys.Count - 1
		    mData.Value(otherKeys(i)) = other.Get(otherKeys(i))
		  Next
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Remove(key As String)
		  If mData.HasKey(key) Then mData.Remove(key)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SaveToFile(f As FolderItem)
		  If f Is Nil Then Return
		  
		  Var tos As TextOutputStream = TextOutputStream.Create(f)
		  Var allKeys() As String = Keys()
		  
		  // Sort keys for readability
		  allKeys.Sort
		  
		  For i As Integer = 0 To allKeys.Count - 1
		    tos.WriteLine(allKeys(i) + " = " + mData.Value(allKeys(i)).StringValue)
		  Next
		  tos.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Set(key As String, value As String)
		  mData.Value(key) = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetEnvPrefix(prefix As String) As XjConfig
		  mEnvPrefix = prefix
		  Return Self
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjConfig — App Configuration
		
		Part of XjTTY-Toolkit Phase 5 (Utility Modules).
		Key-value configuration with file I/O and environment overrides.
		
		Usage:
		  Var cfg As New XjConfig
		  cfg.Set("app.name", "MyApp")
		  cfg.Set("server.port", "8080")
		  Print cfg.Get("app.name")
		
		  // Environment override
		  Call cfg.SetEnvPrefix("MYAPP")
		  // MYAPP_SERVER_PORT=9090 overrides server.port
		
		  // File I/O (key = value format)
		  cfg.LoadFromFile(configFile)
		  cfg.SaveToFile(configFile)
	#tag EndNote


	#tag Property, Flags = &h21
		Private mData As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEnvPrefix As String
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
