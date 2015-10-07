Strict

Public

#Rem
	Based on the "simpledemo.monkey" file provided with Monkey's "bananas" examples.
#End

' Preprocessor related:
#AUTOFIT_MOJO2 = True
#AUTOFIT_MOJO2_USE_VIEWPORT = False ' True

#AUTOFIT_LEGACY_API = False

#GLFW_WINDOW_TITLE = "Autofit Mojo 2 Demo"
#GLFW_WINDOW_WIDTH = 640
#GLFW_WINDOW_HEIGHT = 480
#GLFW_WINDOW_RESIZABLE = True

#GLFW_WINDOW_RENDER_WHILE_RESIZING = True

' Imports:
Import autofit

Import mojo2

' Classes:
Class Application Extends App Final
	' Fields:
	Field Graphics:Canvas
	Field Display:VirtualDisplay
	
	' Constructor(s):
	Method OnCreate:Int()
		SetUpdateRate(0)
		
		Graphics = New Canvas()
		
		Display = New VirtualDisplay(1440, 900)
		
		Display.BorderColor_R = 0.25
		Display.BorderColor_G = 0.25
		Display.BorderColor_B = 0.25
		
		' Return the default response.
		Return 0
	End
	
	Method OnUpdate:Int()
		If (KeyDown(KEY_LEFT)) Then
			Display.AdjustZoom(-0.01) ' Zoom out.
		Endif
		
		If (KeyDown(KEY_RIGHT)) Then
			Display.AdjustZoom(0.01) ' Zoom in.
		Endif
		
		' Return the default response.
		Return 0
	End
	
	Method OnRender:Int()
		' Constant variable(s):
		Const Size:Float = 64.0
		Const HSize:Float = (Size / 2.0)
		
		Graphics.SetViewport(0, 0, DeviceWidth(), DeviceHeight())
		Graphics.SetProjection2d(0, DeviceWidth(), 0, DeviceHeight())
		
		' If we're using Mojo 2, and 'AUTOFIT_MOJO2_USE_VIEWPORT' is enabled,
		' we do not need to manage the current matrix.
		#If Not AUTOFIT_MOJO2_USE_VIEWPORT
			Graphics.PushMatrix()
		#End
		
		' Update the virtual display.
		Display.Refresh(Graphics)
		
		' Clear the canvas.
		Graphics.Clear(1.0, 0.0, 0.0)
		
		Graphics.PushMatrix()
		
		Graphics.Translate(-HSize, -HSize)
		
		' Draw a rectangle in the middle of the virtual display:
		Graphics.SetColor(0.0, 0.0, 0.0)
		
		Graphics.DrawRect(Display.VirtualWidth * 0.5, Display.VirtualHeight * 0.5, Size, Size)

		' Draw a rectangle at the virtual mouse position:
		Graphics.SetColor(1.0, 1.0, 1.0)
		
		Graphics.DrawRect(Display.MouseX, Display.MouseY, Size, Size)
		
		Graphics.PopMatrix()
		
		' Flush the canvas.
		Graphics.Flush()
		
		#If Not AUTOFIT_MOJO2_USE_VIEWPORT
			Graphics.PopMatrix()
		#End
		
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