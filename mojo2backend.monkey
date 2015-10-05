Import mojobackend

Import mojo2.graphics

' Functions:
#If AUTOFIT_LEGACY_API
	' This command updates the global-display. This should be called in 'OnRender', before clearing the screen for the first time. (Every render that is, not just the first overall use)
	' For a full description of this command, view the 'VirtualDisplay' class's implementation's documentation.
	Function UpdateVirtualDisplay:Void(Graphics:Canvas, ZoomBorders:Bool=VirtualDisplay.Default_ZoomBorders, KeepBorders:Bool=VirtualDisplay.Default_KeepBorders, DrawBorders:Bool=VirtualDisplay.Default_DrawBorders)
		'VirtualDisplay.Display.UpdateVirtualDisplay(Graphics, ZoomBorders, KeepBorders, DrawBorders)
		VirtualDisplay.GetGlobalDisplay().UpdateVirtualDisplay(Graphics, ZoomBorders, KeepBorders, DrawBorders)
		
		Return
	End
#End