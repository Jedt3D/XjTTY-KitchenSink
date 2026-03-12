#tag Class
Protected Class XjTable
Inherits XjWidget
	#tag Method, Flags = &h0
		Sub AddRow(cells() As String)
		  For i As Integer = 0 To cells.Count - 1
		    mRows.Add(cells(i))
		  Next
		  // Pad if fewer cells than columns
		  Var remaining As Integer = mColumnCount - cells.Count
		  For i As Integer = 0 To remaining - 1
		    mRows.Add("")
		  Next
		  mDirty = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearRows()
		  mRows.RemoveAll
		  mDirty = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor
		  mColumnCount = 0
		  mShowHeader = True
		  mShowBorder = True
		  mBorderChars = 0
		  
		  Var base As New XjStyle
		  mHeaderStyle = base.SetFG(XjANSI.FG_BRIGHT_WHITE).SetBold
		  mCellStyle = base.SetFG(XjANSI.FG_WHITE)
		  mAltRowStyle = Nil
		  mBorderStyle_ = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawAlignedCell(canvas As XjCanvas, x As Integer, y As Integer, w As Integer, text As String, style As XjStyle, align As Integer)
		  // Truncate
		  If text.Length > w Then
		    text = text.Left(w - 1) + Chr(&h2026)
		  End If
		  
		  Var padded As String = text
		  Var padding As Integer = w - text.Length
		  
		  Select Case align
		  Case ALIGN_CENTER
		    Var leftPad As Integer = padding / 2
		    Var rightPad As Integer = padding - leftPad
		    Var lpParts() As String
		    For i As Integer = 0 To leftPad - 1
		      lpParts.Add(" ")
		    Next
		    Var rpParts() As String
		    For i As Integer = 0 To rightPad - 1
		      rpParts.Add(" ")
		    Next
		    padded = String.FromArray(lpParts, "") + text + String.FromArray(rpParts, "")
		  Case ALIGN_RIGHT
		    Var lpParts() As String
		    For i As Integer = 0 To padding - 1
		      lpParts.Add(" ")
		    Next
		    padded = String.FromArray(lpParts, "") + text
		  Case Else
		    // Left align — pad right
		    Var rpParts() As String
		    For i As Integer = 0 To padding - 1
		      rpParts.Add(" ")
		    Next
		    padded = text + String.FromArray(rpParts, "")
		  End Select
		  
		  canvas.WriteText(x, y, padded, style)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintContent(canvas As XjCanvas, x As Integer, y As Integer, w As Integer, h As Integer)
		  If mColumnCount <= 0 Or w <= 0 Or h <= 0 Then Return
		  
		  // Calculate effective column widths
		  Var effWidths() As Integer
		  Var totalFixed As Integer = 0
		  Var autoCount As Integer = 0
		  
		  For i As Integer = 0 To mColumnCount - 1
		    If mColumnWidths(i) > 0 Then
		      effWidths.Add(mColumnWidths(i))
		      totalFixed = totalFixed + mColumnWidths(i)
		    Else
		      effWidths.Add(-1)
		      autoCount = autoCount + 1
		    End If
		  Next
		  
		  // Account for column separators
		  Var sepWidth As Integer = 0
		  If mShowBorder Then sepWidth = mColumnCount - 1
		  
		  Var remaining As Integer = w - totalFixed - sepWidth
		  If remaining < 0 Then remaining = 0
		  
		  If autoCount > 0 Then
		    Var perAuto As Integer = remaining / autoCount
		    If perAuto < 3 Then perAuto = 3
		    For i As Integer = 0 To effWidths.Count - 1
		      If effWidths(i) < 0 Then
		        effWidths(i) = perAuto
		      End If
		    Next
		  End If
		  
		  // Get separator character
		  Var sep As String = Chr(&h2502)
		  Var hLine As String = Chr(&h2500)
		  If mBorderChars = 4 Then
		    sep = "|"
		    hLine = "-"
		  End If
		  
		  Var row As Integer = y
		  Var maxRow As Integer = y + h
		  
		  // Draw header
		  If mShowHeader And row < maxRow Then
		    Var cx As Integer = x
		    For col As Integer = 0 To mColumnCount - 1
		      If col > 0 And mShowBorder Then
		        canvas.SetCell(cx, row, sep, mBorderStyle_)
		        cx = cx + 1
		      End If
		      Var text As String = ""
		      If col < mHeaders.Count Then text = mHeaders(col)
		      DrawAlignedCell(canvas, cx, row, effWidths(col), text, mHeaderStyle, mColumnAligns(col))
		      cx = cx + effWidths(col)
		    Next
		    row = row + 1
		    
		    // Draw header separator
		    If row < maxRow Then
		      Var sx As Integer = x
		      For col As Integer = 0 To mColumnCount - 1
		        If col > 0 And mShowBorder Then
		          canvas.SetCell(sx, row, "+", mBorderStyle_)
		          sx = sx + 1
		        End If
		        For j As Integer = 0 To effWidths(col) - 1
		          canvas.SetCell(sx, row, hLine, mBorderStyle_)
		          sx = sx + 1
		        Next
		      Next
		      row = row + 1
		    End If
		  End If
		  
		  // Draw data rows
		  Var totalRows As Integer = RowCount
		  For r As Integer = 0 To totalRows - 1
		    If row >= maxRow Then Exit
		    
		    Var rowStyle As XjStyle = mCellStyle
		    If mAltRowStyle <> Nil And r Mod 2 = 1 Then
		      rowStyle = mAltRowStyle
		    End If
		    
		    Var cx As Integer = x
		    For col As Integer = 0 To mColumnCount - 1
		      If col > 0 And mShowBorder Then
		        canvas.SetCell(cx, row, sep, mBorderStyle_)
		        cx = cx + 1
		      End If
		      Var cellIdx As Integer = r * mColumnCount + col
		      Var text As String = ""
		      If cellIdx < mRows.Count Then text = mRows(cellIdx)
		      DrawAlignedCell(canvas, cx, row, effWidths(col), text, rowStyle, mColumnAligns(col))
		      cx = cx + effWidths(col)
		    Next
		    row = row + 1
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RowCount() As Integer
		  If mColumnCount <= 0 Then Return 0
		  Return mRows.Count / mColumnCount
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetAltRowStyle(s As XjStyle) As XjTable
		  mAltRowStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBorderChars(style As Integer) As XjTable
		  mBorderChars = style
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetCellStyle(s As XjStyle) As XjTable
		  mCellStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetColumnAlign(col As Integer, align As Integer) As XjTable
		  If col >= 0 And col < mColumnAligns.Count Then
		    mColumnAligns(col) = align
		  End If
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetColumnWidth(col As Integer, width As Integer) As XjTable
		  If col >= 0 And col < mColumnWidths.Count Then
		    mColumnWidths(col) = width
		  End If
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetHeaders(headers() As String) As XjTable
		  mHeaders.RemoveAll
		  mColumnCount = headers.Count
		  For i As Integer = 0 To headers.Count - 1
		    mHeaders.Add(headers(i))
		  Next
		  
		  // Initialize column widths and aligns
		  mColumnWidths.RemoveAll
		  mColumnAligns.RemoveAll
		  For i As Integer = 0 To mColumnCount - 1
		    mColumnWidths.Add(-1)
		    mColumnAligns.Add(ALIGN_LEFT)
		  Next
		  
		  mDirty = True
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetHeaderStyle(s As XjStyle) As XjTable
		  mHeaderStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetShowBorder(v As Boolean) As XjTable
		  mShowBorder = v
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetShowHeader(v As Boolean) As XjTable
		  mShowHeader = v
		  Return Self
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjTable — Table Display Widget
		
		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Displays tabular data with column headers, alignment,
		auto/fixed widths, and alternating row styles.
		
		Usage:
		  Var t As New XjTable
		  Var hdrs() As String = Array("Name", "Value", "Status")
		  Call t.SetHeaders(hdrs)
		  Var row1() As String = Array("CPU", "45%", "OK")
		  t.AddRow(row1)
	#tag EndNote


	#tag Property, Flags = &h21
		Private mAltRowStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBorderChars As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBorderStyle_ As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCellStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mColumnAligns() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mColumnCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mColumnWidths() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHeaders() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHeaderStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRows() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowBorder As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mShowHeader As Boolean
	#tag EndProperty


	#tag Constant, Name = ALIGN_CENTER, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ALIGN_LEFT, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ALIGN_RIGHT, Type = Double, Dynamic = False, Default = \"2", Scope = Public
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
