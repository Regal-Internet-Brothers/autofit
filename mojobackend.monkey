Strict

Public

#Rem
	TODO:
		* Optimize the border drawing routine.
		* Add an image-option to the border drawing routine.
#End

' Preprocessor related:
#AUTOFIT_IMPLEMENTED = True

' Disable this if your application explicitly calls 'OnResize'/'OnVirtualResize'.
' If unsure, leave this as it is.
#AUTOFIT_AUTOCHECK_SCREENSIZE = True

' Enabling this will cause every 'VirtualDisplay' object to hold
' a private flag describing if it is the global display.

' Disabling this will cause this to be backed by
' a check against the 'Display' global variable.
#AUTOFIT_CACHE_GLOBALDISPLAY_FLAG = True

' This enables experimental support for Mojo 2.
'#AUTOFIT_MOJO2 = True

' Imports:
#If Not AUTOFIT_MOJO2
	#If BRL_GAMETARGET_IMPLEMENTED
		Import mojo
	#Else
		Import mojoemulator
	#End
	
	' Aliases:
	Alias Graphics = mojo.graphics
#Else
	Import mojo2
#End

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
Class VirtualDisplay
	' Constant variable(s):
	Const AUTO:Int = -1
	
	' Defaults:
	Const Default_Zoom:Float = 1.0
	
	' Booleans / Flags:
	Const Default_GlobalDisplay:Bool = False
	
	Const Default_ZoomBorders:Bool = True
	Const Default_KeepBorders:Bool = False
	Const Default_DrawBorders:Bool = True
	
	Const Default_LimitInput:Bool = True ' False
	
	' Global variable(s):
	Global Display:VirtualDisplay = Null
	
	' Constructor(s):
	Method New(Width:Int=AUTO, Height:Int=AUTO, Zoom:Float=Default_Zoom, GlobalDisplay:Bool=Default_GlobalDisplay)
		' Call the main construction routine.
		Construct(Width, Height, Zoom, GlobalDisplay)
	End
	
	Method Construct:Void(Width:Int=AUTO, Height:Int=AUTO, Zoom:Float=Default_Zoom, GlobalDisplay:Bool=Default_GlobalDisplay)
		If (Width <> AUTO And Height <> AUTO) Then
			Self.VirtualWidth = Width
			Self.VirtualHeight = Height
		Else
			' Apply the default resolution.
			ApplyDefaultResolution()
		Endif
		
		#If BRL_GAMETARGET_IMPLEMENTED
			' Set the virtual zoom.
			VirtualZoom = Zoom
			
			' Force auto-detection of the virtual-zoom. (Needed for initialization)
			ZoomChanged = True
			
			' Store the virtual display-ratio.
			'CalculateVirtualRatio()
		#End
		
		#If Not AUTOFIT_AUTOCHECK_SCREENSIZE
			OnResize()
		#End
		
		If (GlobalDisplay) Then
			' Set this object as the primary/global display.
			Display = Self
			
			#If AUTOFIT_CACHE_GLOBALDISPLAY_FLAG
				' Set the global-display flag to 'True'.
				IsGlobalDisplay = True
			#ENd
		Endif
		
		Return
	End
	
	Method ApplyDefaultResolution:Void()
		Self.VirtualWidth = DeviceWidth()
		Self.VirtualHeight = DeviceHeight()
		
		Return
	End
	
	' Destructor(s):
	
	' This is just a quick wrapper for 'Free':
	Method Discard:Bool()
		Return Free()
	End
	
	Method Free:Bool()
		#If AUTOFIT_CACHE_GLOBALDISPLAY_FLAG
			' Set the global-display flag to 'False'.
			Self.IsGlobalDisplay = False
		#End
		
		' Return the default response.
		Return True
	End
	
	' Methods:
	#If BRL_GAMETARGET_IMPLEMENTED
		Method CalculateVirtualRatio:Void()
			VirtualRatio = Max(VirtualHeight, 1.0) / Max(VirtualWidth, 1.0)
			
			Return
		End
		
		Method GetZoom:Float()
			Return VirtualZoom
		End
		
		Method SetZoom:Void(Zoom:Float)
			' Check for errors:
			If (Zoom < 0.0) Then
				Zoom = 0.0
			Endif
			
			' Set the virtual zoom to the specified value.
			VirtualZoom = Zoom
			
			Return
		End
		
		Method AdjustZoom:Void(Amount:Float)
			' Add the amount specified to the 'virtual-zoom'.
			VirtualZoom += Amount
			
			' Make sure we don't have an inverted zoom-value:
			If (VirtualZoom < 0.0) Then
				VirtualZoom = 0.0
			Endif
			
			Return
		End
		
		' For a full description of these methods, please read the globally defined functions' documentation:
		Method VMouseX:Float(Limit:Bool=Default_LimitInput)
			Return MouseX(Limit)
		End
		
		Method VMouseY:Float(Limit:Bool=Default_LimitInput)
			Return MouseY(Limit)
		End
		
		Method MouseX:Float(Limit:Bool=Default_LimitInput)
			Return ProcessVirtualPosition_X(input.MouseX(), Limit)
		End
		
		Method MouseY:Float(Limit:Bool=Default_LimitInput)
			Return ProcessVirtualPosition_Y(input.MouseY(), Limit)
		End
		
		Method VTouchX:Float(Index:Int, Limit:Bool=Default_LimitInput)
			Return TouchX(Index, Limit)
		End
		
		Method VTouchY:Float(Index:Int, Limit:Bool=Default_LimitInput)
			Return TouchY(Index, Limit)
		End
		
		Method TouchX:Float(Index:Int, Limit:Bool=Default_LimitInput)
			Return ProcessVirtualPosition_X(input.TouchX(Index), Limit)
		End
	
		Method TouchY:Float(Index:Int, Limit:Bool=Default_LimitInput)
			Return ProcessVirtualPosition_Y(input.TouchY(Index), Limit)
		End
		
		' These two commands process input-coordinates, producing their virtual equivalents:
		Method ProcessVirtualPosition_X:Float(InputX:Float, Limit:Bool=Default_LimitInput)
			' Local variable(s):
			Local SW:= Converted_ScreenWidth ' Float(ScreenWidth)
			
			' Grab the position of the mouse from the center of the screen.
			Local Offset:Float = (InputX - SW / 2.0)
			
			' Calculate the virtual position of the mouse.
			Local X:Float = ((Offset / Scalar) / VirtualZoom + (VirtualWidth / 2.0))
			
			' Limit the the calculated position if requested:
			If (Limit) Then
				Local WidthLimit:Float = ((VirtualWidth - 1.0)) + BorderWidth
				
				If (X > 0.0) Then
					If (X > WidthLimit) Then
						Return WidthLimit
					Endif
				Elseif (Not Last_DrawBorders) Then
					Return 0.0
				Endif
			Endif
			
			Return X
		End
		
		Method ProcessVirtualPosition_Y:Float(InputY:Float, Limit:Bool=Default_LimitInput)
			' Local variable(s):
			Local SH:= Converted_ScreenHeight ' Float(ScreenHeight)
			
			' Grab the position of the mouse from the center of the screen.
			Local Offset:Float = (InputY - SH / 2.0)
			
			' Calculate the virtual position of the mouse.
			Local Y:Float = ((Offset / Scalar) / VirtualZoom + (VirtualHeight / 2.0))
			
			' Limit the the calculated position if requested:
			If (Limit) Then
				Local HeightLimit:Float = ((VirtualHeight - 1.0)) + BorderHeight
				
				If (Y > 0.0) Then
					If (Y > HeightLimit) Then
						Return HeightLimit
					Endif
				Elseif (Not Last_DrawBorders) Then
					Return 0.0
				Endif
			Endif
			
			Return Y
		End
		
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
		
		#If Not AUTOFIT_MOJO2
			Method UpdateVirtualDisplay:Void(ZoomBorders:Bool=Default_ZoomBorders, KeepBorders:Bool=Default_KeepBorders, DrawBorders:Bool=Default_DrawBorders)
		#Else
			Method UpdateVirtualDisplay:Void(Graphics:Canvas, ZoomBorders:Bool=Default_ZoomBorders, KeepBorders:Bool=Default_KeepBorders, DrawBorders:Bool=Default_DrawBorders)
		#End
				' Check for errors:
				' Nothing so far.
				
				' Set the 'last' flag for 'DrawBorders'.
				Self.Last_DrawBorders = DrawBorders
				
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
						ScissorX = Max (0.0, ScissorX)
						ScissorY = Max (0.0, ScissorY)
						ScissorW = Min (ScissorW, Converted_ScreenWidth)
						ScissorH = Min (ScissorH, Converted_ScreenHeight)
					Else
						' Apply limits to the scissor:
						ScissorX = Max (0.0, BorderWidth)
						ScissorY = Max (0.0, BorderHeight)
						ScissorW = Min (Converted_ScreenWidth - BorderWidth * 2.0, Converted_ScreenWidth)
						ScissorH = Min (Converted_ScreenHeight - BorderHeight * 2.0, Converted_ScreenHeight)
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
				
				If (DrawBorders) Then
					' Draw the border for the entire "device":
					Graphics.SetScissor(SX, SY, ScreenWidth*MScaleX, ScreenHeight*MScaleY)
					
					#If Not AUTOFIT_MOJO2
						Graphics.Cls(BorderColor_R, BorderColor_G, BorderColor_B)
					#Else
						Graphics.Clear(BorderColor_R, BorderColor_G, BorderColor_B)
					#End
				Endif
				
				' Set the scissor to the inner area.
				Graphics.SetScissor((ScissorX*MScaleX)+SX, (ScissorY*MScaleY)+SY, ScissorW*MScaleX, ScissorH*MScaleY)
				
				' Scale everything.
				Graphics.Scale(Scalar * VirtualZoom, Scalar * VirtualZoom)
		
				' Shift the display to account for the borders.
				If (VirtualZoom > 0.0) Then
					Graphics.Translate(ViewOffsetX, ViewOffsetY)
				Endif
				'#End
				
				Return
			End
	#End
	
	' Call this when your application's device-resolution
	' has changed (When your 'OnResize' method is called).
	' This will force screen-size recalculation.
	Method OnResize:Void()
		#If BRL_GAMETARGET_IMPLEMENTED
			Self.SizeChanged = True
		#End
		
		Return
	End
	
	' Properties (Public):
	#If BRL_GAMETARGET_IMPLEMENTED
		#Rem
			DESCRIPTION:
				* These properties are wrappers for the internal scissor data.
				
				The internal scissor data is calculated every time 'UpdateVirtualDisplay' is called.
				The scissor represents the "real" position and size of the current display. (Not counting borders)
				
				This information may be useful to some users, and along with usability, this is why these properties exist.
				
				These properties are only available when some form of 'BBGame' is implemented.
		#End
		
		Method ScissorW:Float() Property
			Return Scissor[SCISSOR_LOCATION_WIDTH]
		End
		
		Method ScissorH:Float() Property
			Return Scissor[SCISSOR_LOCATION_HEIGHT]
		End
		
		Method ScissorX:Float() Property
			Return Scissor[SCISSOR_LOCATION_X]
		End
		
		Method ScissorY:Float() Property
			Return Scissor[SCISSOR_LOCATION_Y]
		End
		
		Method ScissorW:Void(Input:Float) Property
			Scissor[SCISSOR_LOCATION_WIDTH] = Input
			
			Return
		End
		
		Method ScissorH:Void(Input:Float) Property
			Scissor[SCISSOR_LOCATION_HEIGHT] = Input
			
			Return
		End
		
		Method ScissorX:Void(Input:Float) Property
			Scissor[SCISSOR_LOCATION_X] = Input
			
			Return
		End
		
		Method ScissorY:Void(Input:Float) Property
			Scissor[SCISSOR_LOCATION_Y] = Input
			
			Return
		End
		
		Method VirtualZoom:Float() Property
			Return Self._VirtualZoom
		End
		
		Method VirtualZoom:Void(Value:Float) Property
			If (Value <> Self._VirtualZoom) Then
				ZoomChanged = True
			Endif
			
			Self._VirtualZoom = Value
			
			Return
		End
	#End
	
	#Rem
		DESCRIPTION:
			* These two properties represent the "virtual", or "conceptual" dimensions of the display area.
			
			Basically, this will be the resolution you use for your game;
			whatever resolution you're designing your game with, you should set it with these.
			
			The values of these properties are user-defined, and can be changed at any time.
	#End
	
	Method VirtualWidth:Float() Property
		Return Self._VirtualWidth
	End
	
	Method VirtualHeight:Float() Property
		Return Self._VirtualHeight
	End
	
	Method VirtualWidth:Void(Input:Float) Property
		Self._VirtualWidth = Input
		
		#If BRL_GAMETARGET_IMPLEMENTED
			CalculateVirtualRatio()
		#End
		
		Return
	End
	
	Method VirtualHeight:Void(Input:Float) Property
		Self._VirtualHeight = Input
		
		#If BRL_GAMETARGET_IMPLEMENTED
			CalculateVirtualRatio()
		#End
		
		Return
	End
	
	#Rem
		DESCRIPTION:
			* These two properties represent the "hardware" dimensions of the display area.
			In the case of a normal virtual-display, this is the device's width and height.
			
			For something like picture-in-picture, you'd want these to be the desired area's dimensions.
			
			Also note that with P-In-P/split-screen, disabling 'DrawBorders'
			when "updating" (Calling 'UpdateVirtualDisplay') is usually ideal.
	#End
	
	Method ScreenWidth:Int() Property
		Return DeviceWidth()
	End
	
	Method ScreenHeight:Int() Property
		Return DeviceHeight()
	End
	
	' Reserved / Other:
	Method ScreenWidth:Void(Input:Int) Property
		' Nothing so far.
		
		Return
	End
	
	Method ScreenHeight:Void(Input:Int) Property
		' Nothing so far.
		
		Return
	End
	
	' Properties (Private):
	Private
	
	' To ensure you can't assign this to anything outside of this module,
	' assuming this flag is not cached, we will not have a property for assignment:
	#If Not AUTOFIT_CACHE_GLOBALDISPLAY_FLAG
		Method IsGlobalDisplay:Bool() Property
			Return (Display = Self)
		End
	#End
	
	Public
	
	' Fields (Public):	
	#If BRL_GAMETARGET_IMPLEMENTED
		' The colors used when drawing the border.
		Field BorderColor_R:Float, BorderColor_G:Float, BorderColor_B:Float
		
		Field X:Float
		Field Y:Float
		
		' The last known "literal" screen dimensions:
		Field Last_ScreenWidth:Int
		Field Last_ScreenHeight:Int
		
		Field VirtualRatio:Float
		Field ScreenRatio:Float
		
		Field ScaledScreenWidth:Float
		Field ScaledScreenHeight:Float
		
		' The dimensions of the border:
		Field BorderWidth:Float
		Field BorderHeight:Float
		
		' The generated scissor-area.
		Field Scissor:Float[SCISSOR_ARRAY_SIZE]
		
		' A cache used for matrix manipulation.
		Field MatrixCache:Float[MATRIX_ARRAY_SIZE]
		
		' The pixels between the real borders and the virtual boders
		Field Border_OffsetX:Float
		Field Border_OffsetY:Float
		
		' The offsets by which the view needs to be shifted:
		Field ViewOffsetX:Float
		Field ViewOffsetY:Float
		
		' The main multiplier for the scale of this display.
		Field Scalar:Float
		
		' Pre-casted floating-point versions of 'ScreenWidth' and 'ScreenHeight' (Via UpdateVirtualDisplay):
		Field Converted_ScreenWidth:Float
		Field Converted_ScreenHeight:Float
		
		' Booleans / Flags:
		
		' The last known border-draw flag.
		Field Last_DrawBorders:Bool
	#End
	
	' The 'real' / scaled width and height of the virtual display:
	Field RealWidth:Float
	Field RealHeight:Float
	
	' Fields (Private):
	Private
	
	' The virtual display size:
	Field _VirtualWidth:Float
	Field _VirtualHeight:Float
	
	#If BRL_GAMETARGET_IMPLEMENTED
		' The last known virtual zoom.
		Field _VirtualZoom:Float
	#End
	
	' Booleans / Flags:
	Field SizeChanged:Bool
	Field ZoomChanged:Bool
	
	#If AUTOFIT_CACHE_GLOBALDISPLAY_FLAG
		' This field should not be set outside of this module.
		Field IsGlobalDisplay:Bool
	#End
	
	Public
End