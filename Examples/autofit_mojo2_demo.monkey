Strict

Public

#Rem
	This demo may change wildly as Mojo 2 is better supported.
	
	Based on the "simpledemo.monkey" file provided with Monkey's "bananas" examples.
#End

' Preprocessor related:
#AUTOFIT_MOJO2 = True

' Imports:
Import autofit

Import mojo2

' Classes:
Class Application Extends App Final
	' Fields:
	Field Graphics:Canvas
	
	' Constructor(s):
	Method OnCreate:Int()
		SetUpdateRate(0)
		
		Graphics = New Canvas()
		
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
		' Currently required.
		Graphics.PushMatrix()
		
		' Update the virtual display.
		UpdateVirtualDisplay(Graphics)
		
		' Clear the canvas.
		Graphics.Clear(0.5, 0.5, 0.5)

		' Draw a rectangle in the middle of the virtual display:
		Graphics.SetColor(0.0, 0.0, 0.0)
		Graphics.DrawRect(VDeviceWidth() * 0.5, VDeviceHeight() * 0.5, 64.0, 64.0)

		' Draw a rectangle at the virtual mouse position:
		Graphics.SetColor(1.0, 1.0, 1.0)
		Graphics.DrawRect(VMouseX(), VMouseY(), 64.0, 64.0)
		
		' Currently required.
		Graphics.PopMatrix()
		
		' Flush the canvas.
		Graphics.Flush()
		
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