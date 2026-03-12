#tag Module
Protected Module XjSymbols
	#tag Method, Flags = &h0
		Sub EnsureInit()
		  // Lazy initialization — called before first use
		  If mInitialized Then Return
		  UseUnicode
		  mInitialized = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UseASCII()
		  Marker = ">"
		  Check = "[x]"
		  Cross = "[!]"
		  Circle = "(*)"
		  CircleEmpty = "( )"
		  Square = "[x]"
		  SquareEmpty = "[ ]"
		  ArrowRight = ">"
		  Bullet = "*"
		  Ellipsis = "..."
		  QuestionMark = "?"
		  mInitialized = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UseUnicode()
		  Marker = Chr(&h276F)
		  Check = Chr(&h2714)
		  Cross = Chr(&h2718)
		  Circle = Chr(&h25CF)
		  CircleEmpty = Chr(&h25CB)
		  Square = Chr(&h25A0)
		  SquareEmpty = Chr(&h25A1)
		  ArrowRight = Chr(&h25B8)
		  Bullet = Chr(&h2022)
		  Ellipsis = Chr(&h2026)
		  QuestionMark = "?"
		  mInitialized = True
		End Sub
	#tag EndMethod


	#tag Note, Name = "About"
		XjSymbols — Prompt Symbols Configuration
		
		Part of XjTTY-Toolkit Phase 4 (Prompt System).
		Configurable Unicode/ASCII symbols used by all prompts.
		Call UseASCII() for ASCII-only terminals.
		EnsureInit() is called automatically before first use.
	#tag EndNote


	#tag Property, Flags = &h0
		ArrowRight As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Bullet As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Check As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Circle As String
	#tag EndProperty

	#tag Property, Flags = &h0
		CircleEmpty As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Cross As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Ellipsis As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Marker As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mInitialized As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		QuestionMark As String = "?"
	#tag EndProperty

	#tag Property, Flags = &h0
		Square As String
	#tag EndProperty

	#tag Property, Flags = &h0
		SquareEmpty As String
	#tag EndProperty


End Module
#tag EndModule
