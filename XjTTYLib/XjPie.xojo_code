#tag Class
Protected Class XjPie
	#tag Method, Flags = &h0
		Function AddSlice(label As String, value As Double) As XjPie
		  mLabels.Add(label)
		  mValues.Add(value)
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  mWidth = 40
		  mUseColor = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Draw()
		  If mValues.Count = 0 Then Return
		  
		  // Calculate total
		  Var total As Double = 0
		  For i As Integer = 0 To mValues.Count - 1
		    total = total + mValues(i)
		  Next
		  If total = 0 Then Return
		  
		  // Color codes for slices
		  Var colors() As Integer
		  colors.Add(XjANSI.FG_RED)
		  colors.Add(XjANSI.FG_GREEN)
		  colors.Add(XjANSI.FG_YELLOW)
		  colors.Add(XjANSI.FG_BLUE)
		  colors.Add(XjANSI.FG_MAGENTA)
		  colors.Add(XjANSI.FG_CYAN)
		  colors.Add(XjANSI.FG_WHITE)
		  
		  // Block characters
		  Var full As String = Chr(&hE2) + Chr(&h96) + Chr(&h88)
		  Var light As String = Chr(&hE2) + Chr(&h96) + Chr(&h91)
		  
		  // Draw combined bar
		  Var barParts() As String
		  For i As Integer = 0 To mValues.Count - 1
		    Var pct As Double = mValues(i) / total
		    Var chars As Integer = Round(pct * mWidth)
		    If chars < 1 And mValues(i) > 0 Then chars = 1
		    
		    Var segParts() As String
		    For c As Integer = 1 To chars
		      segParts.Add(full)
		    Next
		    Var segment As String = String.FromArray(segParts, "")
		    
		    If mUseColor Then
		      Var s As New XjStyle
		      Var colorIdx As Integer = i Mod colors.Count
		      barParts.Add(s.SetFG(colors(colorIdx)).Apply(segment))
		    Else
		      barParts.Add(segment)
		    End If
		  Next
		  Print("  " + String.FromArray(barParts, ""))
		  Print("")
		  
		  // Draw legend
		  For i As Integer = 0 To mLabels.Count - 1
		    Var pct As Double = (mValues(i) / total) * 100
		    Var pctStr As String = Format(pct, "0.0") + "%"
		    
		    Var swatch As String = full + full
		    If mUseColor Then
		      Var s As New XjStyle
		      Var colorIdx As Integer = i Mod colors.Count
		      swatch = s.SetFG(colors(colorIdx)).Apply(swatch)
		    End If
		    
		    Var label As String = swatch + " " + mLabels(i)
		    // Pad label
		    While label.Length < 30
		      label = label + " "
		    Wend
		    Print("  " + label + pctStr)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Render() As String()
		  // Return lines instead of printing
		  Var lines() As String
		  
		  If mValues.Count = 0 Then Return lines
		  
		  Var total As Double = 0
		  For i As Integer = 0 To mValues.Count - 1
		    total = total + mValues(i)
		  Next
		  If total = 0 Then Return lines
		  
		  Var colors() As Integer
		  colors.Add(XjANSI.FG_RED)
		  colors.Add(XjANSI.FG_GREEN)
		  colors.Add(XjANSI.FG_YELLOW)
		  colors.Add(XjANSI.FG_BLUE)
		  colors.Add(XjANSI.FG_MAGENTA)
		  colors.Add(XjANSI.FG_CYAN)
		  colors.Add(XjANSI.FG_WHITE)
		  
		  Var full As String = Chr(&hE2) + Chr(&h96) + Chr(&h88)
		  
		  // Combined bar
		  Var barParts() As String
		  For i As Integer = 0 To mValues.Count - 1
		    Var pct As Double = mValues(i) / total
		    Var chars As Integer = Round(pct * mWidth)
		    If chars < 1 And mValues(i) > 0 Then chars = 1
		    
		    Var segParts() As String
		    For c As Integer = 1 To chars
		      segParts.Add(full)
		    Next
		    Var segment As String = String.FromArray(segParts, "")
		    
		    If mUseColor Then
		      Var s As New XjStyle
		      Var colorIdx As Integer = i Mod colors.Count
		      barParts.Add(s.SetFG(colors(colorIdx)).Apply(segment))
		    Else
		      barParts.Add(segment)
		    End If
		  Next
		  lines.Add(String.FromArray(barParts, ""))
		  lines.Add("")
		  
		  // Legend
		  For i As Integer = 0 To mLabels.Count - 1
		    Var pct As Double = (mValues(i) / total) * 100
		    Var pctStr As String = Format(pct, "0.0") + "%"
		    Var swatch As String = full + full
		    If mUseColor Then
		      Var s As New XjStyle
		      Var colorIdx As Integer = i Mod colors.Count
		      swatch = s.SetFG(colors(colorIdx)).Apply(swatch)
		    End If
		    lines.Add(swatch + " " + mLabels(i) + "  " + pctStr)
		  Next
		  
		  Return lines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetColor(useColor As Boolean) As XjPie
		  mUseColor = useColor
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetWidth(w As Integer) As XjPie
		  mWidth = w
		  Return Self
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjPie — Terminal Chart
		
		Part of XjTTY-Toolkit Phase 5 (Utility Modules).
		Horizontal bar chart with colored segments and legend.
		
		Usage:
		  Var pie As New XjPie
		  Call pie.AddSlice("Xojo", 60)
		  Call pie.AddSlice("Python", 25)
		  Call pie.AddSlice("Ruby", 15)
		  pie.Draw
	#tag EndNote


	#tag Property, Flags = &h21
		Private mLabels() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUseColor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValues() As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mWidth As Integer
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
