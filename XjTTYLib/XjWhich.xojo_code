#tag Module
Protected Module XjWhich
	#tag Method, Flags = &h0
		Function Which(name As String) As String
		  // Find the first executable matching name in PATH
		  Var paths() As String = GetPathDirs()

		  For i As Integer = 0 To paths.Count - 1
		    Var candidate As String = paths(i) + "/" + name
		    Var f As FolderItem = New FolderItem(candidate, FolderItem.PathModes.Native)
		    If f <> Nil And f.Exists And Not f.IsFolder Then
		      Return f.NativePath
		    End If
		  Next

		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function WhichAll(name As String) As String()
		  // Find all executables matching name in PATH
		  Var results() As String
		  Var paths() As String = GetPathDirs()

		  For i As Integer = 0 To paths.Count - 1
		    Var candidate As String = paths(i) + "/" + name
		    Var f As FolderItem = New FolderItem(candidate, FolderItem.PathModes.Native)
		    If f <> Nil And f.Exists And Not f.IsFolder Then
		      results.Add(f.NativePath)
		    End If
		  Next

		  Return results
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Exists(name As String) As Boolean
		  Return Which(name) <> ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetPathDirs() As String()
		  Var pathEnv As String = System.EnvironmentVariable("PATH")
		  If pathEnv = "" Then
		    Var empty() As String
		    Return empty
		  End If

		  Var sep As String = ":"
		  If TargetWindows Then sep = ";"

		  Return pathEnv.Split(sep)
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjWhich — Executable Path Finder

		Part of XjTTY-Toolkit Phase 5 (Utility Modules).
		Find executables in the system PATH.

		Usage:
		  Var path As String = XjWhich.Which("git")
		  If XjWhich.Exists("node") Then ...
		  Var all() As String = XjWhich.WhichAll("python")
	#tag EndNote

End Module
#tag EndModule
