Strict

Public

' Friends:
Friend autofit.shared
Friend autofit.mojobackend
Friend autofit.mojo2backend

' Imports (Public):
Import shared

' Imports (Private):
Private

#If BRL_GAMETARGET_IMPLEMENTED
	Import mojo.app
	Import mojo.input
#Else
	Import mojoemulator.app
#End

Public

' Classes:

' Shared base-class for 'VirtualDisplay' implementations.
Class BaseDisplay Abstract
	' Constant variable(s):
	#If AUTOFIT_LEGACY_API
		Const AUTO:Int = -1
	#End
	
	' Defaults:
	Const Default_Zoom:Float = 1.0
	
	Const Default_ZoomBorders:Bool = True
	Const Default_KeepBorders:Bool = False
	Const Default_DrawBorders:Bool = True
	
	Const Default_LimitInput:Bool = True ' False
	
	' Constructor(s) (Public):
	#If AUTOFIT_LEGACY_API
		Method New(Width:Int=AUTO, Height:Int=AUTO, Zoom:Float=Default_Zoom)
			If (Width <> AUTO And Height <> AUTO) Then
				Self.VirtualWidth = Width
				Self.VirtualHeight = Height
			Else
				' Apply the default resolution.
				ApplyDefaultResolution()
			Endif
			
			' Call the main construction routine.
			Construct(Zoom)
		End
	#Else
		Method New(Width:Int, Height:Int, Zoom:Float=Default_Zoom)
			Self.VirtualWidth = Width
			Self.VirtualHeight = Height
			
			' Call the main construction routine.
			Construct(Zoom)
		End
		
		Method New(Zoom:Float=Default_Zoom)
			' Apply the default resolution.
			ApplyDefaultResolution()
			
			' Call the main construction routine.
			Construct(Zoom)
		End
	#End
	
	Method ApplyDefaultResolution:Void()
		Self._VirtualWidth = DeviceWidth()
		Self._VirtualHeight = DeviceHeight()
		
		CalculateVirtualRatio()
		
		Return
	End
	
	' Constructor(s) (Protected):
	Protected
	
	Method Construct:Void(Zoom:Float=Default_Zoom) ' Final
		#If BRL_GAMETARGET_IMPLEMENTED
			' Set the virtual zoom.
			VirtualZoom = Zoom
			
			' Force auto-detection of the virtual-zoom. (Needed for initialization)
			ZoomChanged = True
		#End
		
		#If Not AUTOFIT_AUTOCHECK_SCREENSIZE
			OnResize()
		#End
		
		Return
	End
	
	Public
	
	' Destructor(s):
	
	' This is just a wrapper for 'Free'.
	Method Discard:Bool()
		Return Free()
	End
	
	Method Free:Void()
		' Nothing so far.
		
		Return
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
		Method VirtualZoom:Float() Property
			Return Self._VirtualZoom
		End
		
		Method VirtualZoom:Void(Value:Float) Property
			Self._VirtualZoom = Value
			
			Self.ZoomChanged = True
			
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
	
	' Properties (Protected):
	Protected
	
	' Reserved / Other:
	Method ScreenWidth:Void(Input:Int) Property
		' Nothing so far.
		
		Return
	End
	
	Method ScreenHeight:Void(Input:Int) Property
		' Nothing so far.
		
		Return
	End
	
	Public
	
	' Fields (Public):	
	#If BRL_GAMETARGET_IMPLEMENTED
		' The colors used when drawing the border.
		Field BorderColor_R:Float, BorderColor_G:Float, BorderColor_B:Float
		
		Field VirtualRatio:Float
		
		' The dimensions of the border:
		Field BorderWidth:Float
		Field BorderHeight:Float
		
		' The main multiplier for the scale of this display.
		Field Scalar:Float
		
		' Pre-casted floating-point versions of 'ScreenWidth'
		' and 'ScreenHeight' (Please provide these values):
		Field Converted_ScreenWidth:Float
		Field Converted_ScreenHeight:Float
		
		' Booleans / Flags:
		
		' The last known border-draw flag.
		Field Last_DrawBorders:Bool
	#End
	
	' Fields (Protected):
	Protected
	
	' Booleans / Flags:
	Field SizeChanged:Bool
	Field ZoomChanged:Bool
	
	' The virtual display size:
	Field _VirtualWidth:Float
	Field _VirtualHeight:Float
	
	#If BRL_GAMETARGET_IMPLEMENTED
		' The last known virtual zoom.
		Field _VirtualZoom:Float
	#End
	
	Public
End