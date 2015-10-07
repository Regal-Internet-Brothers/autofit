Strict

Public

' Friends:
Friend autofit.mojo2backend
Friend autofit.mojobackend

' Imports (Public):
Import shared

' Imports (Private):
Private

Import basedisplay

Import mojo.app

Public

' Constant variable(s) (Public):
' Nothing so far.

' Constant variable(s) (Private):
Private

' Array-size constants:
Const SCISSOR_ARRAY_SIZE:Int			= 4
Const MATRIX_ARRAY_SIZE:Int				= 6

' Scissor element positions:
Const SCISSOR_LOCATION_X:Int			= 0
Const SCISSOR_LOCATION_Y:Int			= 1
Const SCISSOR_LOCATION_WIDTH:Int		= 2
Const SCISSOR_LOCATION_HEIGHT:Int		= 3

Const MATRIX_LOCATION_IX:Int			= 0
Const MATRIX_LOCATION_IY:Int			= 1
Const MATRIX_LOCATION_JX:Int			= 2
Const MATRIX_LOCATION_JY:Int			= 3
Const MATRIX_LOCATION_TX:Int			= 4
Const MATRIX_LOCATION_TY:Int			= 5

Public

' Classes:
Class MojoDisplay<ScissorRepType> Extends BaseDisplay Abstract
	' Constructor(s):
	#If AUTOFIT_LEGACY_API
		Method New(Width:Int=AUTO, Height:Int=AUTO, Zoom:Float=Default_Zoom)
			Super.New(Width, Height, Zoom)
		End
	#Else
		Method New(Width:Int, Height:Int, Zoom:Float=Default_Zoom)
			Super.New(Width, Height, Zoom)
		End
		
		Method New(Zoom:Float=Default_Zoom)
			Super.New(Zoom)
		End
	#End
	
	' Properties (Public):
	#If BRL_GAMETARGET_IMPLEMENTED
		#Rem
			DESCRIPTION:
				* These properties are wrappers for the internal scissor data.
				
				The internal scissor data is calculated every time 'Refresh' is called.
				The scissor represents the "real" position and size of the current display. (Not counting borders)
				
				This information may be useful to some users, and along with usability, this is why these properties exist.
				
				These properties are only available when some form of 'BBGame' is implemented.
		#End
		
		Method ScissorW:ScissorRepType() Property
			Return Scissor[SCISSOR_LOCATION_WIDTH]
		End
		
		Method ScissorH:ScissorRepType() Property
			Return Scissor[SCISSOR_LOCATION_HEIGHT]
		End
		
		Method ScissorX:ScissorRepType() Property
			Return Scissor[SCISSOR_LOCATION_X]
		End
		
		Method ScissorY:ScissorRepType() Property
			Return Scissor[SCISSOR_LOCATION_Y]
		End
	#End
	
	' Properties (Protected):
	Protected
	
	#If BRL_GAMETARGET_IMPLEMENTED
		Method ScissorW:Void(Input:ScissorRepType) Property
			Scissor[SCISSOR_LOCATION_WIDTH] = Input
			
			Return
		End
		
		Method ScissorH:Void(Input:ScissorRepType) Property
			Scissor[SCISSOR_LOCATION_HEIGHT] = Input
			
			Return
		End
		
		Method ScissorX:Void(Input:ScissorRepType) Property
			Scissor[SCISSOR_LOCATION_X] = Input
			
			Return
		End
		
		Method ScissorY:Void(Input:ScissorRepType) Property
			Scissor[SCISSOR_LOCATION_Y] = Input
			
			Return
		End
	#End
	
	Public
	
	' Fields (Public):
	#If BRL_GAMETARGET_IMPLEMENTED
		Field X:Float
		Field Y:Float
		
		Field ScreenRatio:Float
		
		Field ScaledScreenWidth:Float
		Field ScaledScreenHeight:Float
		
		' The viewport's area using the parent display's space. (Viewport coordinates)
		Field Scissor:ScissorRepType[SCISSOR_ARRAY_SIZE]
		
		' The pixels between the real borders and the virtual boders
		Field Border_OffsetX:Float
		Field Border_OffsetY:Float
		
		' The offsets by which the view needs to be shifted:
		Field ViewOffsetX:Float
		Field ViewOffsetY:Float
		
		' The 'real' / scaled width and height of the virtual display:
		Field RealWidth:Float
		Field RealHeight:Float
	#End
	
	' Fields (Protected):
	Protected
	
	#If BRL_GAMETARGET_IMPLEMENTED
		'#If AUTOFIT_AUTOCHECK_SCREENSIZE
		
		' The last known "literal" screen dimensions:
		Field Last_ScreenWidth:Int
		Field Last_ScreenHeight:Int
		
		'#End
		
		' A cache used for matrix manipulation.
		Field MatrixCache:Float[MATRIX_ARRAY_SIZE]
	#End
	
	Public
End