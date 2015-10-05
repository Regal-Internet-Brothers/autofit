Strict

Public

' Preprocessor related:
#AUTOFIT_LEGACY_API = True

' Imports:
Import backend

' Functions:
#If AUTOFIT_LEGACY_API
	' This command generates a new virtual display, and if requested, sets it as the global display.
	Function SetVirtualDisplay:VirtualDisplay(Width:Int=640, Height:Int=480, Zoom:Float=1.0, GlobalDisplay:Bool=True)
		Return New VirtualDisplay(Width, Height, Zoom, GlobalDisplay)
	End
	
	#If BRL_GAMETARGET_IMPLEMENTED
		' This command manually sets the virtual-zoom of the global-display.
		Function SetVirtualZoom:Void(Zoom:Float)
			VirtualDisplay.Display.SetZoom(Zoom)
			
			Return
		End
		
		' This command adjusts the global-display's virtual-zoom
		' by adding the amount specified to the internal magnitude.
		Function AdjustVirtualZoom:Void(Amount:Float)
			VirtualDisplay.Display.AdjustZoom(Amount)
			
			Return
		End
		
		' This command retrieves the virtual-zoom of the global-display, then returns it.
		Function GetVirtualZoom:Float()
			Return VirtualDisplay.Display.GetZoom()
		End
		
		' This command updates the global-display. This should be called in 'OnRender', before clearing the screen for the first time. (Every render that is, not just the first overall use)
		' For a full description of this command, view the 'VirtualDisplay' class's implementation's documentation.
		#If Not AUTOFIT_MOJO2
			Function UpdateVirtualDisplay:Void(ZoomBorders:Bool=VirtualDisplay.Default_ZoomBorders, KeepBorders:Bool=VirtualDisplay.Default_KeepBorders, DrawBorders:Bool=VirtualDisplay.Default_DrawBorders)
				VirtualDisplay.Display.UpdateVirtualDisplay(ZoomBorders, KeepBorders, DrawBorders)
			
				Return
			End
		#Else
			Function UpdateVirtualDisplay:Void(Graphics:Canvas, ZoomBorders:Bool=VirtualDisplay.Default_ZoomBorders, KeepBorders:Bool=VirtualDisplay.Default_KeepBorders, DrawBorders:Bool=VirtualDisplay.Default_DrawBorders)
				VirtualDisplay.Display.UpdateVirtualDisplay(Graphics, ZoomBorders, KeepBorders, DrawBorders)
				
				Return
			End
		#End
	#End
	
	#Rem
		DESCRIPTION:
			* These commands return the mouse/touch positions as transformed by the global virtual-display.
		
		NOTES:
			* These commands should generally be called within 'OnUpdate', though that's really just up to 'Mojo'.
			
			* These are meant to be direct replacements for the standard 'Mojo' implementations,
			so their initial arguments are identical to 'Mojo's' versions.
			
		ARGUMENTS:
			* When calling these, the 'Limit' agument can be specified. By default, this is currently enabled.
			By enabling 'Limit', you state that the output from these commands will be locked to the bounds of the virtual display.
			
			By disabling 'Limit', you state that the input can escape the virtual display,
			thus allowing positions both larger than the display-area, and positions at negative coordinates.
			
		ORIGINAL NOTES (I did not write this/these):
			* "Set the 'limit' parameter to False to allow returning of values outside
			the virtual display area. Combine this with ScaleVirtualDisplay's zoomborders
			parameter set to False if you want to be able to zoom way out and allow
			gameplay in the full zoomed-out area..."
	#End
	
	#If BRL_GAMETARGET_IMPLEMENTED
		Function VMouseX:Float(Limit:Bool=True)
			Return VirtualDisplay.Display.VMouseX(Limit)
		End
		
		Function VMouseY:Float(Limit:Bool=True)
			Return VirtualDisplay.Display.VMouseY(Limit)
		End
		
		Function VTouchX:Float(Index:Int=0, Limit:Bool=True)
			Return VirtualDisplay.Display.VTouchX(Index, Limit)
		End
		
		Function VTouchY:Float(Index:Int=0, Limit:Bool=True)
			Return VirtualDisplay.Display.VTouchY(Index, Limit)
		End
	#End
	
	' See the 'VirtualDisplay' class's 'OnResize'
	' documentation for more information about this command.
	Function OnVirtualResize:Void()
		If (VirtualDisplay.Display <> Null) Then
			VirtualDisplay.Display.OnResize()
		Endif
		
		Return
	End
	
	' These commands do not check if the global-display is present, so use them at your own risk:
	
	' This commands return the virtual width and height of the global display:
	Function VDeviceWidth:Float()
		Return VirtualDisplay.Display.VirtualWidth
	End
	
	Function VDeviceHeight:Float()
		Return VirtualDisplay.Display.VirtualHeight
	End
#End

' Classes:

' A 'SubDisplay' is a virtual display which uses the global virtual display as a parent, rather than the hardware-display.
Class SubDisplay Extends VirtualDisplay
	' Constant variable(s):
	
	' Defaults:
	Const Default_Zoom:Float = 1.0
	
	' Booleans / Flags:
	Const Default_KeepBorders:Bool = False
	Const Default_ZoomBorders:Bool = False
	Const Default_DrawBorders:Bool = False
	
	' Constructor(s):
	Method New(Width:Int=AUTO, Height:Int=AUTO, Zoom:Float=Default_Zoom)
		' Call the super-class's implementation.
		Super.New(Width, Height, Zoom, False)
		
		' Nothing else so far.
	End
	
	Method ApplyDefaultResolution:Void()
		' Check for the virtual display:
		If (Display <> Null) Then
			Self.VirtualWidth = VDeviceWidth()
			Self.VirtualHeight = VDeviceHeight()
		Else
			Super.ApplyDefaultResolution()
		Endif
		
		Return
	End
	
	' Methods:
	#If BRL_GAMETARGET_IMPLEMENTED
		' This overload is only here for the sake of this class's defaults:
		#If Not AUTOFIT_MOJO2
			Function UpdateVirtualDisplay:Void(ZoomBorders:Bool=VirtualDisplay.Default_ZoomBorders, KeepBorders:Bool=VirtualDisplay.Default_KeepBorders, DrawBorders:Bool=VirtualDisplay.Default_DrawBorders)
				' Call the super-class's implementation.
				Super.UpdateVirtualDisplay(ZoomBorders, KeepBorders, DrawBorders)
			
				Return
			End
		#Else
			Function UpdateVirtualDisplay:Void(Graphics:Canvas, ZoomBorders:Bool=VirtualDisplay.Default_ZoomBorders, KeepBorders:Bool=VirtualDisplay.Default_KeepBorders, DrawBorders:Bool=VirtualDisplay.Default_DrawBorders)
				' Call the super-class's implementation.
				Super.UpdateVirtualDisplay(Graphics, ZoomBorders, KeepBorders, DrawBorders)
				
				Return
			End
		#End
	#End
	
	' Properties (Public):
	Method ScreenWidth:Int() Property
		Return VDeviceWidth()
	End
	
	Method ScreenHeight:Int() Property
		Return VDeviceHeight()
	End
	
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
	
	#If Not AUTOFIT_CACHE_GLOBALDISPLAY_FLAG
		Method IsGlobalDisplay:Bool() Property
			Return False
		End
	#End
	
	Public
	
	' Fields (Public):
	' Nothing so far.
	
	' Fields (Private):
	Private
	
	' Nothing so far.
	
	Public
End

#Rem
	DESCRIPTION:
		* A 'CameraDisplay' is basically just a 'SubDisplay', but with manual 'ScreenWidth' and 'ScreenHeight' properties.
		This class is best used for camera views, such as in situations where the intent is 'picture-in-picture', or 'split-screen'.
		By itself this is by no means a camera code-base, but it should give you sub-displays at whatever size and position you desire.
#End

Class CameraDisplay Extends SubDisplay ' Final
	' Constant variable(s):
	' Nothing so far.
	
	' Constructor(s):
	Method New(Width:Int, Height:Int, VirtualWidth:Int=AUTO, VirtualHeight:Int=AUTO, Zoom:Float=Default_Zoom)
		' Call the super-class's implementation.
		Super.New(VirtualWidth, VirtualHeight, Zoom)
		
		ScreenWidth = Width
		ScreenHeight = Height
	End
	
	' Methods:
	' Nothing so far.
	
	' Properties:
	Method ScreenWidth:Int() Property
		Return Self._ScreenWidth
	End
	
	Method ScreenHeight:Int() Property
		Return Self._ScreenHeight
	End
	
	Method ScreenWidth:Void(Input:Int) Property
		Self._ScreenWidth = Input
		
		Return
	End
	
	Method ScreenHeight:Void(Input:Int) Property
		Self._ScreenHeight = Input
		
		Return
	End
	
	' Fields (Public):
	' Nothing so far.
	
	' Fields (Private):
	Private
	
	Field _ScreenWidth:Int, _ScreenHeight:Int
	
	Public
End