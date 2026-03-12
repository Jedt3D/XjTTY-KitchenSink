#tag Module
Protected Module XjUIParser
	#tag Method, Flags = &h0
		Function Build(yamlText As String) As XjWidget
		  Var root As XjYAMLNode = XjYAML.Parse(yamlText)
		  If root.ChildCount = 0 Then Return Nil
		  
		  // The first child of root is the top-level widget
		  Return BuildWidget(root.ChildAt(0))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function BuildFromNode(node As XjYAMLNode) As XjWidget
		  If node Is Nil Then Return Nil
		  If node.ChildCount = 0 Then Return Nil
		  Return BuildWidget(node.ChildAt(0))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BuildWidget(node As XjYAMLNode) As XjWidget
		  If node Is Nil Then Return Nil
		  
		  Var widgetType As String = node.Key.Lowercase
		  
		  Select Case widgetType
		  Case "box"
		    Return ConfigBox(node)
		  Case "text"
		    Return ConfigText(node)
		  Case "textinput", "input"
		    Return ConfigTextInput(node)
		  Case "table"
		    Return ConfigTable(node)
		  Case "progressbar", "progress"
		    Return ConfigProgressBar(node)
		  Case "spinner"
		    Return ConfigSpinner(node)
		  Case Else
		    // Unknown type — create a generic box
		    Return ConfigBox(node)
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ConfigBox(node As XjYAMLNode) As XjBox
		  Var box As New XjBox
		  
		  For i As Integer = 0 To node.ChildCount - 1
		    Var child As XjYAMLNode = node.ChildAt(i)
		    Var k As String = child.Key.Lowercase
		    
		    Select Case k
		    Case "name"
		      Call box.SetName(child.Value)
		    Case "width"
		      Call box.SetWidth(ParseConstraint(child.Value))
		    Case "height"
		      Call box.SetHeight(ParseConstraint(child.Value))
		    Case "border"
		      Call box.SetBorder(ParseBorderStyle(child.Value), Nil)
		    Case "title"
		      Call box.SetTitle(child.Value)
		    Case "direction", "dir"
		      If child.Value.Lowercase = "row" Then
		        Call box.SetDirection(XjLayoutNode.DIR_ROW)
		      Else
		        Call box.SetDirection(XjLayoutNode.DIR_COLUMN)
		      End If
		    Case "padding"
		      Var p As Integer = Val(child.Value)
		      Call box.SetPadding(p, p, p, p)
		    Case "margin"
		      Var m As Integer = Val(child.Value)
		      Call box.SetMargin(m, m, m, m)
		    Case "align"
		      Call box.SetContentAlign(ParseAlign(child.Value))
		    Case "valign"
		      Call box.SetContentVAlign(ParseVAlign(child.Value))
		    Case "fg"
		      Var s As New XjStyle
		      Call box.SetStyle(s.SetFG(ParseColor(child.Value)))
		    Case "visible"
		      Call box.SetVisible(child.Value.Lowercase = "true" Or child.Value = "1")
		    Case "children"
		      // Process child widgets
		      For j As Integer = 0 To child.ChildCount - 1
		        Var childWidget As XjWidget = BuildWidget(child.ChildAt(j))
		        If childWidget <> Nil Then
		          box.AddChild(childWidget)
		        End If
		      Next
		    End Select
		  Next
		  
		  Return box
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ConfigProgressBar(node As XjYAMLNode) As XjProgressBar
		  Var bar As New XjProgressBar
		  
		  For i As Integer = 0 To node.ChildCount - 1
		    Var child As XjYAMLNode = node.ChildAt(i)
		    Var k As String = child.Key.Lowercase
		    
		    Select Case k
		    Case "name"
		      Call bar.SetName(child.Value)
		    Case "value"
		      Call bar.SetValue(Val(child.Value))
		    Case "total"
		      Call bar.SetTotal(Val(child.Value))
		    Case "format"
		      Call bar.SetFormat(child.Value)
		    Case "width"
		      Call bar.SetWidth(ParseConstraint(child.Value))
		    Case "height"
		      Call bar.SetHeight(ParseConstraint(child.Value))
		    Case "border"
		      Call bar.SetBorder(ParseBorderStyle(child.Value), Nil)
		    Case "title"
		      Call bar.SetTitle(child.Value)
		    End Select
		  Next
		  
		  Return bar
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ConfigSpinner(node As XjYAMLNode) As XjSpinner
		  Var spin As New XjSpinner
		  
		  For i As Integer = 0 To node.ChildCount - 1
		    Var child As XjYAMLNode = node.ChildAt(i)
		    Var k As String = child.Key.Lowercase
		    
		    Select Case k
		    Case "name"
		      Call spin.SetName(child.Value)
		    Case "format"
		      Call spin.SetFormat(child.Value)
		    Case "message", "text"
		      Call spin.SetMessage(child.Value)
		    Case "width"
		      Call spin.SetWidth(ParseConstraint(child.Value))
		    Case "height"
		      Call spin.SetHeight(ParseConstraint(child.Value))
		    Case "border"
		      Call spin.SetBorder(ParseBorderStyle(child.Value), Nil)
		    Case "title"
		      Call spin.SetTitle(child.Value)
		    End Select
		  Next
		  
		  Return spin
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ConfigTable(node As XjYAMLNode) As XjTable
		  Var tbl As New XjTable
		  
		  For i As Integer = 0 To node.ChildCount - 1
		    Var child As XjYAMLNode = node.ChildAt(i)
		    Var k As String = child.Key.Lowercase
		    
		    Select Case k
		    Case "name"
		      Call tbl.SetName(child.Value)
		    Case "headers"
		      Var headers() As String = child.Value.Split(",")
		      For h As Integer = 0 To headers.Count - 1
		        headers(h) = headers(h).Trim
		      Next
		      Call tbl.SetHeaders(headers)
		    Case "rows"
		      // Each child is a row with comma-separated values
		      For r As Integer = 0 To child.ChildCount - 1
		        Var rowNode As XjYAMLNode = child.ChildAt(r)
		        Var cells() As String = rowNode.Value.Split(",")
		        For c As Integer = 0 To cells.Count - 1
		          cells(c) = cells(c).Trim
		        Next
		        tbl.AddRow(cells)
		      Next
		    Case "width"
		      Call tbl.SetWidth(ParseConstraint(child.Value))
		    Case "height"
		      Call tbl.SetHeight(ParseConstraint(child.Value))
		    Case "border"
		      Call tbl.SetBorder(ParseBorderStyle(child.Value), Nil)
		    Case "title"
		      Call tbl.SetTitle(child.Value)
		    End Select
		  Next
		  
		  Return tbl
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ConfigText(node As XjYAMLNode) As XjText
		  Var txt As New XjText
		  
		  For i As Integer = 0 To node.ChildCount - 1
		    Var child As XjYAMLNode = node.ChildAt(i)
		    Var k As String = child.Key.Lowercase
		    
		    Select Case k
		    Case "name"
		      Call txt.SetName(child.Value)
		    Case "content", "text", "value"
		      Call txt.SetText(child.Value)
		    Case "align"
		      Call txt.SetAlign(ParseAlign(child.Value))
		    Case "wrap"
		      Call txt.SetWrap(child.Value.Lowercase = "true" Or child.Value = "1")
		    Case "width"
		      Call txt.SetWidth(ParseConstraint(child.Value))
		    Case "height"
		      Call txt.SetHeight(ParseConstraint(child.Value))
		    Case "border"
		      Call txt.SetBorder(ParseBorderStyle(child.Value), Nil)
		    Case "title"
		      Call txt.SetTitle(child.Value)
		    Case "fg"
		      Var s As New XjStyle
		      Call txt.SetStyle(s.SetFG(ParseColor(child.Value)))
		    End Select
		  Next
		  
		  Return txt
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ConfigTextInput(node As XjYAMLNode) As XjTextInput
		  Var inp As New XjTextInput
		  
		  For i As Integer = 0 To node.ChildCount - 1
		    Var child As XjYAMLNode = node.ChildAt(i)
		    Var k As String = child.Key.Lowercase
		    
		    Select Case k
		    Case "name"
		      Call inp.SetName(child.Value)
		    Case "placeholder"
		      Call inp.SetPlaceholder(child.Value)
		    Case "value"
		      Call inp.SetValue(child.Value)
		    Case "mask"
		      Call inp.SetMask(child.Value)
		    Case "maxlength"
		      Call inp.SetMaxLength(Val(child.Value))
		    Case "label"
		      Call inp.SetLabel(child.Value, Nil)
		    Case "width"
		      Call inp.SetWidth(ParseConstraint(child.Value))
		    Case "height"
		      Call inp.SetHeight(ParseConstraint(child.Value))
		    Case "border"
		      Call inp.SetBorder(ParseBorderStyle(child.Value), Nil)
		    Case "title"
		      Call inp.SetTitle(child.Value)
		    End Select
		  Next
		  
		  Call inp.SetFocusable(True)
		  Return inp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DumpWidgetTree(widget As XjWidget, indent As Integer = 0) As String
		  If widget Is Nil Then Return ""
		  
		  Var padParts() As String
		  For i As Integer = 1 To indent
		    padParts.Add("  ")
		  Next
		  Var pad As String = String.FromArray(padParts, "")
		  
		  Var info As String = pad
		  // Determine type name
		  If widget IsA XjBox Then
		    info = info + "XjBox"
		  ElseIf widget IsA XjText Then
		    info = info + "XjText"
		  ElseIf widget IsA XjTextInput Then
		    info = info + "XjTextInput"
		  ElseIf widget IsA XjTable Then
		    info = info + "XjTable"
		  ElseIf widget IsA XjProgressBar Then
		    info = info + "XjProgressBar"
		  ElseIf widget IsA XjSpinner Then
		    info = info + "XjSpinner"
		  Else
		    info = info + "XjWidget"
		  End If
		  
		  If widget.Name <> "" Then
		    info = info + " (" + widget.Name + ")"
		  End If
		  
		  Var parts() As String
		  parts.Add(info + Chr(10))
		  
		  For i As Integer = 0 To widget.ChildCount - 1
		    parts.Add(DumpWidgetTree(widget.Child(i), indent + 1))
		  Next
		  
		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseAlign(value As String) As Integer
		  Select Case value.Trim.Lowercase
		  Case "left"
		    Return 0
		  Case "center"
		    Return 1
		  Case "right"
		    Return 2
		  End Select
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseBorderStyle(value As String) As Integer
		  Select Case value.Trim.Lowercase
		  Case "single"
		    Return 0
		  Case "double"
		    Return 1
		  Case "round", "rounded"
		    Return 2
		  Case "bold", "heavy"
		    Return 3
		  Case "ascii"
		    Return 4
		  Case "none"
		    Return -1
		  End Select
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseColor(value As String) As Integer
		  Select Case value.Trim.Lowercase
		  Case "black"
		    Return XjANSI.FG_BLACK
		  Case "red"
		    Return XjANSI.FG_RED
		  Case "green"
		    Return XjANSI.FG_GREEN
		  Case "yellow"
		    Return XjANSI.FG_YELLOW
		  Case "blue"
		    Return XjANSI.FG_BLUE
		  Case "magenta"
		    Return XjANSI.FG_MAGENTA
		  Case "cyan"
		    Return XjANSI.FG_CYAN
		  Case "white"
		    Return XjANSI.FG_WHITE
		  End Select
		  // Try numeric
		  Return Val(value)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseConstraint(value As String) As XjConstraint
		  Var v As String = value.Trim.Lowercase
		  
		  If v = "auto" Then
		    Return XjConstraint.Auto
		  End If
		  
		  // Percentage: "50%"
		  If v.Right(1) = "%" Then
		    Var pct As Double = Val(v.Left(v.Length - 1))
		    Return XjConstraint.Percent(pct)
		  End If
		  
		  // MinMax: "20-100"
		  Var dashPos As Integer = v.IndexOf("-")
		  If dashPos > 0 Then
		    Var minVal As Integer = Val(v.Left(dashPos))
		    Var maxVal As Integer = Val(v.Middle(dashPos + 1))
		    Return XjConstraint.MinMax(minVal, maxVal)
		  End If
		  
		  // Fixed: "20"
		  Return XjConstraint.Fixed(Val(v))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseVAlign(value As String) As Integer
		  Select Case value.Trim.Lowercase
		  Case "top"
		    Return 0
		  Case "middle", "center"
		    Return 1
		  Case "bottom"
		    Return 2
		  End Select
		  Return 0
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjUIParser — YAML to Widget Tree Builder
		
		Part of XjTTY-Toolkit Phase 6 (YAML UI Definition).
		Parses YAML text and constructs a widget tree.
		
		Supported widget types:
		  box, text, textinput/input, table,
		  progressbar/progress, spinner
		
		Common properties:
		  name, width, height, border, title,
		  direction, padding, margin, fg, visible
		
		Usage:
		  Var widget As XjWidget = XjUIParser.Build(yamlText)
		  // widget is ready to Paint to a canvas
		
		  // Or from pre-parsed YAML:
		  Var root As XjYAMLNode = XjYAML.Parse(yamlText)
		  Var widget As XjWidget = XjUIParser.BuildFromNode(root)
	#tag EndNote


End Module
#tag EndModule
