#tag Class
Protected Class XjCanvas
	#tag Method, Flags = &h0
		Sub Constructor(width As Integer, height As Integer)
		  mWidth = width
		  mHeight = height
		  InitCells
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InitCells()
		  // Initialize the cell grid with empty cells
		  Var total As Integer = mWidth * mHeight
		  ReDim mCells(total - 1)
		  For i As Integer = 0 To total - 1
		    mCells(i) = New XjCell
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetWidth() As Integer
		  Return mWidth
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetHeight() As Integer
		  Return mHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetCell(x As Integer, y As Integer, char As String, style As XjStyle)
		  // Set a cell at (x, y) — 0-based coordinates
		  // x = column, y = row
		  If x < 0 Or x >= mWidth Or y < 0 Or y >= mHeight Then Return
		  Var idx As Integer = y * mWidth + x
		  mCells(idx).Set(char, style)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetCell(x As Integer, y As Integer) As XjCell
		  // Get cell at (x, y) — 0-based coordinates
		  If x < 0 Or x >= mWidth Or y < 0 Or y >= mHeight Then Return New XjCell
		  Return mCells(y * mWidth + x)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetChar(x As Integer, y As Integer, char As String)
		  // Set just the character at (x, y) without changing style
		  If x < 0 Or x >= mWidth Or y < 0 Or y >= mHeight Then Return
		  mCells(y * mWidth + x).SetChar(char)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteText(x As Integer, y As Integer, text As String, style As XjStyle)
		  // Write a string horizontally starting at (x, y)
		  For i As Integer = 0 To text.Length - 1
		    Var cx As Integer = x + i
		    If cx >= mWidth Then Exit
		    SetCell(cx, y, text.Middle(i, 1), style)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteTextWrapped(x As Integer, y As Integer, maxWidth As Integer, text As String, style As XjStyle)
		  // Write text with word wrapping within maxWidth
		  Var col As Integer = x
		  Var row As Integer = y
		  Var words() As String = text.Split(" ")

		  For w As Integer = 0 To words.Count - 1
		    Var word As String = words(w)

		    // Check if word fits on current line
		    If col > x And (col + word.Length) > (x + maxWidth) Then
		      col = x
		      row = row + 1
		      If row >= mHeight Then Return
		    End If

		    // Write the word
		    For i As Integer = 0 To word.Length - 1
		      If col >= x + maxWidth Then
		        col = x
		        row = row + 1
		        If row >= mHeight Then Return
		      End If
		      SetCell(col, row, word.Middle(i, 1), style)
		      col = col + 1
		    Next

		    // Add space after word (if not at end)
		    If w < words.Count - 1 And col < x + maxWidth Then
		      SetCell(col, row, " ", style)
		      col = col + 1
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Clear()
		  // Clear all cells to empty
		  For i As Integer = 0 To mCells.Count - 1
		    mCells(i).Reset
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearRegion(x As Integer, y As Integer, w As Integer, h As Integer)
		  // Clear a rectangular region
		  For row As Integer = y To y + h - 1
		    For col As Integer = x To x + w - 1
		      If col >= 0 And col < mWidth And row >= 0 And row < mHeight Then
		        mCells(row * mWidth + col).Reset
		      End If
		    Next
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub FillRegion(x As Integer, y As Integer, w As Integer, h As Integer, char As String, style As XjStyle)
		  // Fill a rectangular region with a character and style
		  For row As Integer = y To y + h - 1
		    For col As Integer = x To x + w - 1
		      SetCell(col, row, char, style)
		    Next
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawBox(x As Integer, y As Integer, w As Integer, h As Integer, style As XjStyle, borderStyle As Integer)
		  // Draw a box border
		  // borderStyle: 0=single, 1=double, 2=round, 3=bold, 4=ascii

		  Var tl, tr, bl, br, horiz, vert As String

		  Select Case borderStyle
		  Case 1
		    // Double line
		    tl = Chr(&h2554)
		    tr = Chr(&h2557)
		    bl = Chr(&h255A)
		    br = Chr(&h255D)
		    horiz = Chr(&h2550)
		    vert = Chr(&h2551)
		  Case 2
		    // Round corners
		    tl = Chr(&h256D)
		    tr = Chr(&h256E)
		    bl = Chr(&h2570)
		    br = Chr(&h256F)
		    horiz = Chr(&h2500)
		    vert = Chr(&h2502)
		  Case 3
		    // Bold/thick
		    tl = Chr(&h250F)
		    tr = Chr(&h2513)
		    bl = Chr(&h2517)
		    br = Chr(&h251B)
		    horiz = Chr(&h2501)
		    vert = Chr(&h2503)
		  Case 4
		    // ASCII
		    tl = "+"
		    tr = "+"
		    bl = "+"
		    br = "+"
		    horiz = "-"
		    vert = "|"
		  Case Else
		    // Single line (default)
		    tl = Chr(&h250C)
		    tr = Chr(&h2510)
		    bl = Chr(&h2514)
		    br = Chr(&h2518)
		    horiz = Chr(&h2500)
		    vert = Chr(&h2502)
		  End Select

		  // Top edge
		  SetCell(x, y, tl, style)
		  For col As Integer = x + 1 To x + w - 2
		    SetCell(col, y, horiz, style)
		  Next
		  SetCell(x + w - 1, y, tr, style)

		  // Sides
		  For row As Integer = y + 1 To y + h - 2
		    SetCell(x, row, vert, style)
		    SetCell(x + w - 1, row, vert, style)
		  Next

		  // Bottom edge
		  SetCell(x, y + h - 1, bl, style)
		  For col As Integer = x + 1 To x + w - 2
		    SetCell(col, y + h - 1, horiz, style)
		  Next
		  SetCell(x + w - 1, y + h - 1, br, style)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Resize(newWidth As Integer, newHeight As Integer)
		  // Resize the canvas, preserving existing content where possible
		  Var newTotal As Integer = newWidth * newHeight
		  Var newCells() As XjCell
		  ReDim newCells(newTotal - 1)

		  For i As Integer = 0 To newTotal - 1
		    newCells(i) = New XjCell
		  Next

		  // Copy existing cells
		  Var copyW As Integer = If(newWidth < mWidth, newWidth, mWidth)
		  Var copyH As Integer = If(newHeight < mHeight, newHeight, mHeight)

		  For row As Integer = 0 To copyH - 1
		    For col As Integer = 0 To copyW - 1
		      Var oldIdx As Integer = row * mWidth + col
		      Var newIdx As Integer = row * newWidth + col
		      newCells(newIdx) = mCells(oldIdx)
		    Next
		  Next

		  mWidth = newWidth
		  mHeight = newHeight
		  mCells = newCells
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Render() As String
		  // Render the entire canvas as an ANSI string
		  // Optimized: tracks current style to minimize escape codes

		  Var parts() As String
		  Var lastStyle As XjStyle = Nil

		  // Home cursor + clear screen + disable auto-wrap, all in one output.
		  // The clear ensures no artifacts survive from terminal resize, Cmd+K,
		  // or any external event. Since this is all sent in one Write() call,
		  // the terminal processes clear+redraw as a batch — no visible flicker.
		  parts.Add(XjANSI.CursorPosition(1, 1))
		  parts.Add(XjANSI.CSI + "2J")
		  parts.Add(XjANSI.AutoWrapDisable)

		  For row As Integer = 0 To mHeight - 1
		    // Position cursor at start of row (1-based)
		    parts.Add(XjANSI.CursorPosition(row + 1, 1))

		    For col As Integer = 0 To mWidth - 1
		      Var cell As XjCell = mCells(row * mWidth + col)
		      Var cellStyle As XjStyle = cell.Style

		      // Only emit style codes when style changes
		      If lastStyle Is Nil Or Not cellStyle.Equals(lastStyle) Then
		        If Not cellStyle.IsEmpty Then
		          parts.Add(XjANSI.Reset + cellStyle.ToANSI)
		        ElseIf lastStyle <> Nil And Not lastStyle.IsEmpty Then
		          parts.Add(XjANSI.Reset)
		        End If
		        lastStyle = cellStyle
		      End If

		      parts.Add(cell.Char)
		    Next
		  Next

		  // Reset at end and re-enable auto-wrap
		  parts.Add(XjANSI.Reset)
		  parts.Add(XjANSI.AutoWrapEnable)

		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DiffRender(previous As XjCanvas) As String
		  // Render only the cells that differ from the previous canvas
		  // This dramatically reduces output for incremental updates

		  If previous Is Nil Then Return Render

		  Var parts() As String

		  // Disable auto-wrap to prevent scroll when writing bottom-right corner
		  parts.Add(XjANSI.AutoWrapDisable)

		  Var lastRow As Integer = -1
		  Var lastCol As Integer = -1
		  Var lastStyle As XjStyle = Nil

		  For row As Integer = 0 To mHeight - 1
		    For col As Integer = 0 To mWidth - 1
		      Var idx As Integer = row * mWidth + col
		      Var cell As XjCell = mCells(idx)

		      // Check if this cell differs from the previous frame
		      Var prevCell As XjCell = Nil
		      If row < previous.mHeight And col < previous.mWidth Then
		        prevCell = previous.mCells(row * previous.mWidth + col)
		      End If

		      Var changed As Boolean = True
		      If prevCell <> Nil Then
		        changed = Not cell.Equals(prevCell)
		      End If

		      If changed Then
		        // Only move cursor if not at expected position
		        If row <> lastRow Or col <> lastCol Then
		          parts.Add(XjANSI.CursorPosition(row + 1, col + 1))
		        End If

		        // Apply style if changed
		        Var cellStyle As XjStyle = cell.Style
		        If lastStyle Is Nil Or Not cellStyle.Equals(lastStyle) Then
		          If Not cellStyle.IsEmpty Then
		            parts.Add(XjANSI.Reset + cellStyle.ToANSI)
		          ElseIf lastStyle <> Nil And Not lastStyle.IsEmpty Then
		            parts.Add(XjANSI.Reset)
		          End If
		          lastStyle = cellStyle
		        End If

		        parts.Add(cell.Char)
		        lastRow = row
		        lastCol = col + 1
		      End If
		    Next
		  Next

		  If parts.Count > 0 Then
		    parts.Add(XjANSI.Reset)
		  End If

		  // Re-enable auto-wrap
		  parts.Add(XjANSI.AutoWrapEnable)

		  Return String.FromArray(parts, "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Snapshot() As XjCanvas
		  // Create a deep copy of this canvas for diff rendering
		  Var copy As New XjCanvas(mWidth, mHeight)
		  For i As Integer = 0 To mCells.Count - 1
		    copy.mCells(i) = mCells(i).Clone
		  Next
		  Return copy
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Blit(source As XjCanvas, srcX As Integer, srcY As Integer, srcW As Integer, srcH As Integer, destX As Integer, destY As Integer)
		  // Copy a region from another canvas onto this canvas
		  For row As Integer = 0 To srcH - 1
		    For col As Integer = 0 To srcW - 1
		      Var sx As Integer = srcX + col
		      Var sy As Integer = srcY + row
		      Var dx As Integer = destX + col
		      Var dy As Integer = destY + row

		      If sx >= 0 And sx < source.mWidth And sy >= 0 And sy < source.mHeight Then
		        If dx >= 0 And dx < mWidth And dy >= 0 And dy < mHeight Then
		          Var srcCell As XjCell = source.mCells(sy * source.mWidth + sx)
		          mCells(dy * mWidth + dx) = srcCell.Clone
		        End If
		      End If
		    Next
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawHLine(x As Integer, y As Integer, length As Integer, char As String, style As XjStyle)
		  // Draw a horizontal line
		  If char = "" Then char = Chr(&h2500)
		  For i As Integer = 0 To length - 1
		    SetCell(x + i, y, char, style)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawVLine(x As Integer, y As Integer, length As Integer, char As String, style As XjStyle)
		  // Draw a vertical line
		  If char = "" Then char = Chr(&h2502)
		  For i As Integer = 0 To length - 1
		    SetCell(x, y + i, char, style)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As String
		  // Render as plain text (no ANSI codes) for debugging
		  Var parts() As String
		  For row As Integer = 0 To mHeight - 1
		    Var rowParts() As String
		    For col As Integer = 0 To mWidth - 1
		      rowParts.Add(mCells(row * mWidth + col).Char)
		    Next
		    parts.Add(String.FromArray(rowParts, ""))
		  Next
		  Return String.FromArray(parts, EndOfLine)
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjCanvas — 2D Character Render Buffer

		Part of XjTTY-Toolkit foundation layer.
		Provides a 2D grid of XjCell objects for composing
		terminal output before rendering.

		Key features:
		- Cell-level character and style control
		- Text writing with optional word wrap
		- Box drawing (single, double, round, bold, ASCII)
		- Region operations: clear, fill, blit
		- Full render: outputs complete ANSI for entire canvas
		- Diff render: outputs only changed cells (efficient updates)
		- Snapshot for frame-to-frame comparison
		- Optimized style tracking to minimize escape codes

		Coordinates are 0-based (x=column, y=row).
		The canvas is the foundation for all higher-level TUI
		widgets and layout in XjTTY-Toolkit.
	#tag EndNote

	#tag Property, Flags = &h21
		Private mWidth As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHeight As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCells() As XjCell
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
