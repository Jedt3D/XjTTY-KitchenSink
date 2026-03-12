#tag Class
Protected Class XjProgressBar
Inherits XjWidget
	#tag Method, Flags = &h0
		Sub Advance(amount As Double)
		  Call SetValue(mValue + amount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CalcETA() As String
		  If mStartTime < 0 Or mValue <= 0 Then Return "--:--"
		  
		  Var elapsed As Double = Microseconds / 1000000.0 - mStartTime
		  Var remaining As Double = elapsed * (mTotal - mValue) / mValue
		  
		  If remaining < 0 Then Return "00:00"
		  If remaining > 3600 Then Return ">1h"
		  
		  Var mins As Integer = CType(remaining / 60, Integer)
		  Var secs As Integer = CType(remaining, Integer) Mod 60
		  
		  Return Format(mins, "00") + ":" + Format(secs, "00")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Super.Constructor
		  mValue = 0.0
		  mTotal = 1.0
		  mFormat = ":bar :percent"
		  mBarWidth = -1
		  mFilledChar = Chr(&h2588)
		  mEmptyChar = Chr(&h2591)
		  mHeadChar = ""
		  mIndeterminate = False
		  mBouncePos = 0
		  mBounceDir = 1
		  mStartTime = -1
		  
		  Var base As New XjStyle
		  mFilledStyle = base.SetFG(XjANSI.FG_GREEN)
		  mEmptyStyle = base.SetFG(XjANSI.FG_BRIGHT_BLACK)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HandleTick(tickCount As Integer)
		  If mIndeterminate Then
		    mBouncePos = mBouncePos + mBounceDir
		    Var bw As Integer = ContentWidth
		    If bw <= 0 Then bw = 20
		    If mBouncePos >= bw - 3 Then
		      mBounceDir = -1
		    ElseIf mBouncePos <= 0 Then
		      mBounceDir = 1
		    End If
		    mDirty = True
		  End If
		  
		  Super.HandleTick(tickCount)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsComplete() As Boolean
		  Return mValue >= mTotal
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PaintContent(canvas As XjCanvas, x As Integer, y As Integer, w As Integer, h As Integer)
		  #Pragma Unused h
		  
		  If w <= 0 Then Return
		  
		  If mIndeterminate Then
		    PaintIndeterminate(canvas, x, y, w)
		    Return
		  End If
		  
		  // Build format string, replacing tokens
		  Var pct As Integer = Percent
		  Var pctStr As String = Str(pct) + "%"
		  Var currentStr As String = Str(CType(mValue, Integer))
		  Var totalStr As String = Str(CType(mTotal, Integer))
		  Var etaStr As String = CalcETA
		  
		  // Split format at :bar first, then replace tokens once per half
		  Var fmtParts() As String = mFormat.Split(":bar")
		  
		  // Pre-bar text
		  Var preBar As String = ""
		  If fmtParts.Count > 0 Then
		    preBar = fmtParts(0)
		    preBar = preBar.ReplaceAll(":percent", pctStr)
		    preBar = preBar.ReplaceAll(":current", currentStr)
		    preBar = preBar.ReplaceAll(":total", totalStr)
		    preBar = preBar.ReplaceAll(":eta", etaStr)
		  End If
		  
		  // Post-bar text
		  Var postBar As String = ""
		  If fmtParts.Count > 1 Then
		    postBar = fmtParts(1)
		    postBar = postBar.ReplaceAll(":percent", pctStr)
		    postBar = postBar.ReplaceAll(":current", currentStr)
		    postBar = postBar.ReplaceAll(":total", totalStr)
		    postBar = postBar.ReplaceAll(":eta", etaStr)
		  End If
		  
		  // Determine bar width
		  Var barW As Integer = mBarWidth
		  If barW < 0 Then
		    // Auto: fill remaining space
		    barW = w - preBar.Length - postBar.Length
		    If barW < 5 Then barW = 5
		  End If
		  
		  // Build bar string
		  Var filled As Integer = CType(barW * mValue / mTotal, Integer)
		  If filled > barW Then filled = barW
		  
		  Var cx As Integer = x
		  
		  // Draw pre-bar text
		  If preBar <> "" Then
		    canvas.WriteText(cx, y, preBar, mStyle)
		    cx = cx + preBar.Length
		  End If
		  
		  // Draw filled portion
		  For i As Integer = 0 To filled - 1
		    If cx >= x + w Then Exit
		    If i = filled - 1 And mHeadChar <> "" And filled < barW Then
		      canvas.SetCell(cx, y, mHeadChar, mFilledStyle)
		    Else
		      canvas.SetCell(cx, y, mFilledChar, mFilledStyle)
		    End If
		    cx = cx + 1
		  Next
		  
		  // Draw empty portion
		  For i As Integer = filled To barW - 1
		    If cx >= x + w Then Exit
		    canvas.SetCell(cx, y, mEmptyChar, mEmptyStyle)
		    cx = cx + 1
		  Next
		  
		  // Draw post-bar text
		  If postBar <> "" Then
		    canvas.WriteText(cx, y, postBar, mStyle)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PaintIndeterminate(canvas As XjCanvas, x As Integer, y As Integer, w As Integer)
		  // Bouncing bar for indeterminate progress
		  Var bounceW As Integer = 3
		  For i As Integer = 0 To w - 1
		    If i >= mBouncePos And i < mBouncePos + bounceW Then
		      canvas.SetCell(x + i, y, mFilledChar, mFilledStyle)
		    Else
		      canvas.SetCell(x + i, y, mEmptyChar, mEmptyStyle)
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Percent() As Integer
		  If mTotal <= 0 Then Return 0
		  Return CType(mValue / mTotal * 100, Integer)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  mValue = 0
		  mStartTime = -1
		  mBouncePos = 0
		  mBounceDir = 1
		  mDirty = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetBarWidth(w As Integer) As XjProgressBar
		  mBarWidth = w
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetEmptyChar(c As String) As XjProgressBar
		  mEmptyChar = c
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetEmptyStyle(s As XjStyle) As XjProgressBar
		  mEmptyStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetFilledChar(c As String) As XjProgressBar
		  mFilledChar = c
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetFilledStyle(s As XjStyle) As XjProgressBar
		  mFilledStyle = s
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetFormat(f As String) As XjProgressBar
		  mFormat = f
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetHeadChar(c As String) As XjProgressBar
		  mHeadChar = c
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetIndeterminate(v As Boolean) As XjProgressBar
		  mIndeterminate = v
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetTotal(t As Double) As XjProgressBar
		  mTotal = t
		  If mTotal <= 0 Then mTotal = 1.0
		  mDirty = True
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetValue(v As Double) As XjProgressBar
		  If mStartTime < 0 And v > 0 Then
		    mStartTime = Microseconds / 1000000.0
		  End If
		  mValue = v
		  If mValue < 0 Then mValue = 0
		  If mValue > mTotal Then mValue = mTotal
		  mDirty = True
		  Return Self
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value() As Double
		  Return mValue
		End Function
	#tag EndMethod


	#tag Note, Name = "About"
		XjProgressBar — Progress Bar Widget
		
		Part of XjTTY-Toolkit Phase 3 (Widget System).
		Displays progress with format tokens: :bar, :percent,
		:current, :total, :eta. Supports indeterminate bounce mode.
		
		Usage:
		  Var pb As New XjProgressBar
		  Call pb.SetFormat(":bar :percent :eta")
		  Call pb.SetTotal(100)
		  pb.Advance(10)
	#tag EndNote


	#tag Property, Flags = &h21
		Private mBarWidth As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBounceDir As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBouncePos As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEmptyChar As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEmptyStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFilledChar As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFilledStyle As XjStyle
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFormat As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHeadChar As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIndeterminate As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStartTime As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTotal As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mValue As Double
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
