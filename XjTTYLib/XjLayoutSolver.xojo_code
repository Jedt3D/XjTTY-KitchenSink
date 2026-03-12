#tag Module
Protected Module XjLayoutSolver
	#tag Method, Flags = &h0
		Sub Solve(root As XjLayoutNode, availWidth As Integer, availHeight As Integer)
		  // Main entry point: set root dimensions and solve all children
		  root.SetComputed(0, 0, availWidth, availHeight)
		  SolveChildren(root)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SolveChildren(parent As XjLayoutNode)
		  If parent.ChildCount = 0 Then Return

		  // Calculate parent's inner rect (content area)
		  Var innerX As Integer = parent.ContentX
		  Var innerY As Integer = parent.ContentY
		  Var innerW As Integer = parent.ContentWidth
		  Var innerH As Integer = parent.ContentHeight

		  Var isRow As Boolean = (parent.Direction = XjLayoutNode.DIR_ROW)

		  // Main axis = width for row, height for column
		  Var mainSize As Integer
		  If isRow Then
		    mainSize = innerW
		  Else
		    mainSize = innerH
		  End If

		  // Cross axis
		  Var crossSize As Integer
		  If isRow Then
		    crossSize = innerH
		  Else
		    crossSize = innerW
		  End If

		  // First pass: resolve fixed/percent children, count auto children
		  Var childSizes() As Integer
		  Var autoCount As Integer = 0
		  Var usedSpace As Integer = 0

		  For i As Integer = 0 To parent.ChildCount - 1
		    Var child As XjLayoutNode = parent.Child(i)

		    // Get the main axis constraint
		    Var mainConstraint As XjConstraint
		    If isRow Then
		      mainConstraint = child.WidthConstraint
		    Else
		      mainConstraint = child.HeightConstraint
		    End If

		    // Account for child's margin on main axis
		    Var mainMargin As Integer
		    If isRow Then
		      mainMargin = child.MarginLeft + child.MarginRight
		    Else
		      mainMargin = child.MarginTop + child.MarginBottom
		    End If

		    If mainConstraint.IsAuto Then
		      childSizes.Add(-1) // placeholder for auto
		      autoCount = autoCount + 1
		      usedSpace = usedSpace + mainMargin
		    Else
		      Var resolved As Integer = mainConstraint.Resolve(mainSize - mainMargin)
		      childSizes.Add(resolved + mainMargin)
		      usedSpace = usedSpace + resolved + mainMargin
		    End If
		  Next

		  // Distribute remaining space to auto children
		  Var remaining As Integer = mainSize - usedSpace
		  If remaining < 0 Then remaining = 0

		  If autoCount > 0 Then
		    Var perAuto As Integer = remaining / autoCount
		    Var leftover As Integer = remaining - (perAuto * autoCount)

		    Var autoIdx As Integer = 0
		    For i As Integer = 0 To childSizes.Count - 1
		      If childSizes(i) = -1 Then
		        Var child As XjLayoutNode = parent.Child(i)
		        Var mainMargin As Integer
		        If isRow Then
		          mainMargin = child.MarginLeft + child.MarginRight
		        Else
		          mainMargin = child.MarginTop + child.MarginBottom
		        End If

		        Var sz As Integer = perAuto
		        If autoIdx < leftover Then
		          sz = sz + 1
		        End If
		        childSizes(i) = sz
		        autoIdx = autoIdx + 1
		      End If
		    Next
		  End If

		  // Second pass: position children
		  Var offset As Integer = 0

		  For i As Integer = 0 To parent.ChildCount - 1
		    Var child As XjLayoutNode = parent.Child(i)
		    Var childMainSize As Integer = childSizes(i)

		    // Resolve cross axis
		    Var crossConstraint As XjConstraint
		    If isRow Then
		      crossConstraint = child.HeightConstraint
		    Else
		      crossConstraint = child.WidthConstraint
		    End If

		    Var crossMargin As Integer
		    If isRow Then
		      crossMargin = child.MarginTop + child.MarginBottom
		    Else
		      crossMargin = child.MarginLeft + child.MarginRight
		    End If

		    Var childCrossSize As Integer
		    If crossConstraint.IsAuto Then
		      childCrossSize = crossSize
		    Else
		      childCrossSize = crossConstraint.Resolve(crossSize - crossMargin) + crossMargin
		    End If

		    // Set computed rect
		    If isRow Then
		      child.SetComputed(innerX + offset, innerY, childMainSize, childCrossSize)
		    Else
		      child.SetComputed(innerX, innerY + offset, childCrossSize, childMainSize)
		    End If

		    offset = offset + childMainSize

		    // Recurse
		    SolveChildren(child)
		  Next
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjLayoutSolver — Layout Computation

		Part of XjTTY-Toolkit Phase 2 (Layout Engine).
		Stateless module that computes absolute positions for a layout tree.

		Algorithm:
		1. Set root to fill available space
		2. For perAuto parent, calculate inner content area
		3. Resolve fixed/percent children first
		4. Distribute remaining space equally to auto children
		5. Position children along main axis (row=horizontal, column=vertical)
		6. Recurse into perAuto child

		Usage:
		  XjLayoutSolver.Solve(root, termWidth, termHeight)
		  // All nodes now have ComputedX/Y/Width/Height set
	#tag EndNote

End Module
#tag EndModule
