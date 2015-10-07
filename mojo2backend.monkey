Strict

Public

' Preprocessor related:
#AUTOFIT_MOJO2_USE_VIEWPORT = True ' False

' Friends:
Friend autofit.shared

' Imports (Public):
' Nothing so far.

' Imports (Private):
Private

Import basedisplay

Import mojo.app
Import mojo2.graphics

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

' Functions:
#If AUTOFIT_LEGACY_API
	' This command updates the global-display. This should be called in 'OnRender', before clearing the screen for the first time. (Every render that is, not just the first overall use)
	' For a full description of this command, view the 'VirtualDisplay' class's implementation's documentation.
	Function UpdateVirtualDisplay:Void(Graphics:Canvas, ZoomBorders:Bool=VirtualDisplay.Default_ZoomBorders, KeepBorders:Bool=VirtualDisplay.Default_KeepBorders, DrawBorders:Bool=VirtualDisplay.Default_DrawBorders)
		VirtualDisplay.Display.UpdateVirtualDisplay(Graphics, ZoomBorders, KeepBorders, DrawBorders)
		
		Return
	End
#End

' Classes:
Class VirtualDisplay Extends BaseDisplay
	' Defaults:
	
	' Booleans / Flags:
	#If AUTOFIT_LEGACY_API
		Const Default_GlobalDisplay:Bool = False
	#End
	
	' Global variable(s) (Private):
	Private
	
	#If AUTOFIT_LEGACY_API
		Global Display:VirtualDisplay = Null
	#End
	
	Public
	
	' Functions:
	#If AUTOFIT_LEGACY_API
		Function SetGlobalDisplay:Void(D:VirtualDisplay)
			Display = D
			
			Return
		End
		
		Function GetGlobalDisplay:VirtualDisplay()
			Return Display
		End
	#End
	
	' Constructor(s):
	#If AUTOFIT_LEGACY_API
		Method New(Width:Int=AUTO, Height:Int=AUTO, Zoom:Float=Default_Zoom, GlobalDisplay:Bool=Default_GlobalDisplay)
			Super.New(Width, Height, Zoom)
			
			If (GlobalDisplay) Then
				SetGlobalDisplay(Self)
			Endif
		End
	#Else
		Method New(Width:Int, Height:Int, Zoom:Float=Default_Zoom)
			Super.New(Width, Height, Zoom)
		End
		
		Method New(Zoom:Float=Default_Zoom)
			Super.New(Zoom)
		End
	#End
	
	' Destructor(s):
	#Rem
		Method Free:Void()
			Super.Free()
			
			Return
		End
	#End
	
	' Methods:
	#If BRL_GAMETARGET_IMPLEMENTED
		#Rem
			DESCRIPTION:
				* The following is the main update-routine for virtual displays.
			
			NOTES:
				* This command should always be called in 'OnRender'.
				
				* If this is the global-display, this command should be called before clearing the screen for the first time.
				This isn't a requirement, but it is recommended. (Unless you've disabled the 'DrawBorders' option, then everything's up to you)
				
				* The color of the border can be changed by setting the 'BorderColor_R', 'BorderColor_G', and 'BorderColor_B' fields.
				
			ARGUMENTS:
				* By enabling 'ZoomBorders', you effectively make sure your game is at a fixed resolution no matter the zoom setting.
				Effectively, this means that zooming will only affect the scale of the inner virtual-screen,
				instead of showing more of the scene when zoomed out.
				
				TL;DR: With this disabled, the actual scene is scaled within the virtual display. And with it enabled, the virtual display gets scaled.
				
				* By enabling 'KeepBorders', the effects of the other arguments still take place,
				but if you zoom in, your screen-area is limited to the virtual area, instead of taking up the rest of the screen safely.
				In other words, you'd be keeping the borders, even when they aren't necessary.
				
				The effects of 'KeepBorders' only apply when 'ZoomBorders' is enabled, otherwise it isn't noticeable.
				
				* The 'DrawBorders' argument is VERY important to know about.
				
				By disabling it, you effectively take responsibility for the area outside of the virtual display.
				Unless you're dealing with sub-displays, or you really want to manage that yourself, keep this enabled.
		#End
		
		#If AUTOFIT_LEGACY_API
			Method UpdateVirtualDisplay:Void(Graphics:Canvas, ZoomBorders:Bool=Default_ZoomBorders, KeepBorders:Bool=Default_KeepBorders, DrawBorders:Bool=Default_DrawBorders)
				Refresh(Graphics, ZoomBorders, KeepBorders, DrawBorders)
				
				Return
			End
		#End
		
		Method Refresh:Void(Graphics:Canvas, ZoomBorders:Bool=Default_ZoomBorders, KeepBorders:Bool=Default_KeepBorders, DrawBorders:Bool=Default_DrawBorders)
			' Check for errors:
			' Nothing so far.
			
			' Set the 'last' flag for 'DrawBorders'.
			Self.Last_DrawBorders = DrawBorders
			
			' This check is performed so we can optionally support call-back based screen-size updates:
			#If Not AUTOFIT_AUTOCHECK_SCREENSIZE
				If (Not IsGlobalDisplay) Then
			#End
					' Check if we aren't already changing the screen size:
					If (Not SizeChanged) Then
						Local ScreenWidth:= Self.ScreenWidth
						Local ScreenHeight:= Self.ScreenHeight
						
						' Check if the "device's" screen resolution has changed:
						If ((ScreenWidth <> Last_ScreenWidth) Or (ScreenHeight <> Last_ScreenHeight)) Then
							Last_ScreenWidth = ScreenWidth
							Last_ScreenHeight = ScreenHeight
							
							SizeChanged = True
						Endif
					Endif
			#If Not AUTOFIT_AUTOCHECK_SCREENSIZE
				Endif
			#End
			
			' Now that the previous operations of occurred, check if we have a new screen-size:
			If (SizeChanged) Then
				' Store the "device" resolution in floats to avoid unneeded casts down the road:
				Converted_ScreenWidth = Float(ScreenWidth)
				Converted_ScreenHeight = Float(ScreenHeight)
				
				' Recalculate the device's screen-ratio.
				ScreenRatio = Converted_ScreenHeight / Converted_ScreenWidth
	
				' Compare the newly calculated ratio against the pre-calculated virtual ratio:
				If (ScreenRatio > VirtualRatio) Then
					' The "device's" aspect ratio is narrower than (Or the same as) the calculated aspect ratio.
					' We need to have a horizontal border of zero, and calcuate a new vertical border.
					
					' Calculate the scalar needed to generate the border.
					Scalar = Converted_ScreenWidth / VirtualWidth
					
					' Calculate the desired borders:
					BorderWidth = 0.0
					BorderHeight = (Converted_ScreenHeight - VirtualHeight * Scalar) / 2.0
				Else
					' The "device's" aspect ratio is width than (Or the same as) the calculated aspect ratio.
					' We need to have a vertical border of zero, and calcuate a new horizontal border.
					
					' Calculate the scalar needed to generate the border.
					Scalar = Converted_ScreenHeight / VirtualHeight
					
					' Calculate the desired borders:
					BorderWidth = (Converted_ScreenWidth - VirtualWidth * Scalar) / 2.0
					BorderHeight = 0.0
				Endif
			Endif
			
			' Recalculate the display area if the virtual zoom or screen-size has changed:
			If (ZoomChanged Or SizeChanged) Then
				If (ZoomBorders) Then
					' Calculate the width and height of the scaled virtual resolution:
					RealWidth = VirtualWidth * VirtualZoom * Scalar
					RealHeight = VirtualHeight * VirtualZoom * Scalar
			
					' Calculate the amount of space (in pixels) between the "real device" borders and the virtual borders:
					Border_OffsetX = (Converted_ScreenWidth - RealWidth) * 0.5
					Border_OffsetY = (Converted_ScreenHeight - RealHeight) * 0.5
					
					' In the event we keep borders, do the following:
					If (KeepBorders) Then
						' Calculate the inner area:
						If (Border_OffsetX < BorderWidth) Then
							ScissorX = BorderWidth
							ScissorW = Converted_ScreenWidth - BorderWidth * 2.0
						Else
							ScissorX = Border_OffsetX
							ScissorW = Converted_ScreenWidth - (Border_OffsetX * 2.0)
						Endif
		
						If (Border_OffsetY < BorderHeight) Then
							ScissorY = BorderHeight
							ScissorH = Converted_ScreenHeight - BorderHeight * 2.0
						Else
							ScissorY = Border_OffsetY
							ScissorH = Converted_ScreenHeight - (Border_OffsetY * 2.0)
						Endif
					Else
						ScissorX = Border_OffsetX
						ScissorW = Converted_ScreenWidth - (Border_OffsetX * 2.0)
						
						ScissorY = Border_OffsetY
						ScissorH = Converted_ScreenHeight - (Border_OffsetY * 2.0)
					Endif
					
					' Apply limits to the scissor:
					ScissorX = Max(0, ScissorX)
					ScissorY = Max(0, ScissorY)
					ScissorW = Min(ScissorW, ScreenWidth)
					ScissorH = Min(ScissorH, ScreenHeight)
				Else
					' Apply limits to the scissor:
					ScissorX = Max(0, Int(BorderWidth))
					ScissorY = Max(0, Int(BorderHeight))
					ScissorW = Min(Int(Converted_ScreenWidth - BorderWidth * 2.0), ScreenWidth)
					ScissorH = Min(Int(Converted_ScreenHeight - BorderHeight * 2.0), ScreenHeight)
				Endif
				
				' Calculate the dimensions of the scaled virtual display (In pixels):
				ScaledScreenWidth = (VirtualWidth * Scalar * VirtualZoom)
				ScaledScreenHeight = (VirtualHeight * Scalar * VirtualZoom)
	
				' Find the view offsets:
				ViewOffsetX = (((Converted_ScreenWidth - ScaledScreenWidth) / 2.0) / Scalar) / VirtualZoom
				ViewOffsetY = (((Converted_ScreenHeight - ScaledScreenHeight) / 2.0) / Scalar) / VirtualZoom
			
				' Reset the 'change-flags':
				SizeChanged = False
				ZoomChanged = False
			Endif
			
			'#If BRL_GAMETARGET_IMPLEMENTED
			Local M:= MatrixCache
			
			Local MScaleX:Float, MScaleY:Float
			Local MX:Float, MY:Float
			
			' Get the current matrix-data.
			Graphics.GetMatrix(M)
			
			MX = M[MATRIX_LOCATION_TX]
			MY = M[MATRIX_LOCATION_TY]
			
			MScaleX = Sqrt((M[MATRIX_LOCATION_IX]*M[MATRIX_LOCATION_IX]) + (M[MATRIX_LOCATION_JX]*M[MATRIX_LOCATION_JX]))
			MScaleY = Sqrt((M[MATRIX_LOCATION_IY]*M[MATRIX_LOCATION_IY]) + (M[MATRIX_LOCATION_JY]*M[MATRIX_LOCATION_JY]))
			
			Local SX:Float, SY:Float
			
			SX = ((X*MScaleX)+MX)
			SY = ((Y*MScaleY)+MY)
			
			#If AUTOFIT_MOJO2_USE_VIEWPORT
				Graphics.SetProjection2d(0, VirtualWidth, 0, VirtualHeight)
			#End
			
			If (DrawBorders) Then
				#If AUTOFIT_MOJO2_USE_VIEWPORT
					' Draw the border for the entire "device":
					Graphics.SetViewport(SX, SY, ScreenWidth*MScaleX, ScreenHeight*MScaleY)
				#Else
					Graphics.SetScissor(SX, SY, ScreenWidth*MScaleX, ScreenHeight*MScaleY)
				#End
				
				Graphics.Clear(BorderColor_R, BorderColor_G, BorderColor_B)
			Endif
			
			' Set the scissor to the inner area:
			#If AUTOFIT_MOJO2_USE_VIEWPORT
				Graphics.SetViewport((ScissorX*MScaleX)+SX, (ScissorY*MScaleY)+SY, ScissorW*MScaleX, ScissorH*MScaleY)
			#Else
				' Set the scissor to the inner area.
				Graphics.SetScissor((ScissorX*MScaleX)+SX, (ScissorY*MScaleY)+SY, ScissorW*MScaleX, ScissorH*MScaleY)
				
				' Scale everything.
				Graphics.Scale(Scalar * VirtualZoom, Scalar * VirtualZoom)
		
				' Shift the display to account for the borders.
				If (VirtualZoom > 0.0) Then
					Graphics.Translate(ViewOffsetX, ViewOffsetY)
				Endif
			#End
			
			Return
		End
	
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
		
		Method ScissorW:Int() Property
			Return Scissor[SCISSOR_LOCATION_WIDTH]
		End
		
		Method ScissorH:Int() Property
			Return Scissor[SCISSOR_LOCATION_HEIGHT]
		End
		
		Method ScissorX:Int() Property
			Return Scissor[SCISSOR_LOCATION_X]
		End
		
		Method ScissorY:Int() Property
			Return Scissor[SCISSOR_LOCATION_Y]
		End
		
		Method ScissorW:Void(Input:Int) Property
			Scissor[SCISSOR_LOCATION_WIDTH] = Input
			
			Return
		End
		
		Method ScissorH:Void(Input:Int) Property
			Scissor[SCISSOR_LOCATION_HEIGHT] = Input
			
			Return
		End
		
		Method ScissorX:Void(Input:Int) Property
			Scissor[SCISSOR_LOCATION_X] = Input
			
			Return
		End
		
		Method ScissorY:Void(Input:Int) Property
			Scissor[SCISSOR_LOCATION_Y] = Input
			
			Return
		End
	#End
	
	' Properties (Protected):
	Protected
	
	' This is for internal use only.
	Method IsGlobalDisplay:Bool() Property
		#If AUTOFIT_LEGACY_API
			Return (Display = Self)
		#Else
			Return False
		#End
	End
	
	Public
	
	' Fields (Public):	
	#If BRL_GAMETARGET_IMPLEMENTED
		Field X:Float
		Field Y:Float
		
		Field ScreenRatio:Float
		
		Field ScaledScreenWidth:Float
		Field ScaledScreenHeight:Float
		
		' A cache used for matrix manipulation.
		Field MatrixCache:Float[MATRIX_ARRAY_SIZE]
		
		' The pixels between the real borders and the virtual boders
		Field Border_OffsetX:Float
		Field Border_OffsetY:Float
		
		' The offsets by which the view needs to be shifted:
		Field ViewOffsetX:Float
		Field ViewOffsetY:Float
		
		#If AUTOFIT_AUTOCHECK_SCREENSIZE
			' The last known "literal" screen dimensions:
			Field Last_ScreenWidth:Int
			Field Last_ScreenHeight:Int
		#End
		
		' The viewport's area using the parent display's space. (Viewport coordinates)
		Field Scissor:Int[SCISSOR_ARRAY_SIZE]
	#End
	
	' The 'real' / scaled width and height of the virtual display:
	Field RealWidth:Float
	Field RealHeight:Float
End