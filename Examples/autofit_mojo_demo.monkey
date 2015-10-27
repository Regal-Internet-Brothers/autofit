Strict

Public

#Rem
	Based on the "simpledemo.monkey" file provided with Monkey's "bananas" examples.
#End

' Preprocessor related:
#AUTOFIT_MOJO2 = False
#AUTOFIT_LEGACY_API = True

#GLFW_WINDOW_TITLE = "Autofit Mojo Demo"
#GLFW_WINDOW_WIDTH = 640
#GLFW_WINDOW_HEIGHT = 480
#GLFW_WINDOW_RESIZABLE = True

#GLFW_WINDOW_RENDER_WHILE_RESIZING = True

' Imports:
Import regal.autofit

Import mojo

' Classes:
Class Application Extends App Final
	' Constructor(s):
	Method OnCreate:Int()
		SetUpdateRate(0)
		
		SetVirtualDisplay(1440, 900)
		
		' Return the default response.
		Return 0
	End
	
	Method OnUpdate:Int()
		If (KeyDown(KEY_LEFT)) Then
			AdjustVirtualZoom(-0.01) ' Zoom out.
		Endif
		
		If (KeyDown(KEY_RIGHT)) Then
			AdjustVirtualZoom(0.01) ' Zoom in.
		Endif
		
		' Return the default response.
		Return 0
	End
	
	Method OnRender:Int()
		Const Size:Float = 64.0
		Const HSize:Float = (Size / 2.0)
		
		' Update the virtual display.
		UpdateVirtualDisplay()
		
		' Clear the screen.
		Cls(127.5, 127.5, 127.5)
		
		Translate(-HSize, -HSize)
		
		' Draw a rectangle in the middle of the virtual display:
		SetColor(0.0, 0.0, 0.0)
		
		DrawRect(VDeviceWidth() * 0.5, VDeviceHeight() * 0.5, Size, Size)

		' Draw a rectangle at the virtual mouse position:
		SetColor(255.0, 255.0, 255.0)
		
		DrawRect(VMouseX(), VMouseY(), Size, Size)
		
		' Return the default response.
		Return 0
	End
End

' Functions:
Function Main:Int()
	' Start the application.
	New Application()
	
	' Return the default response.
	Return 0
End