Strict

Public

' Preprocessor related:
#AUTOFIT_IMPLEMENTED = True

' This may be used to toggle use of the old autofit API. (Disable at your own risk)
#AUTOFIT_LEGACY_API = True

' Disable this if your application explicitly calls
' 'OnResize' / 'OnVirtualResize'; if unsure, leave this as it is.
#AUTOFIT_AUTOCHECK_SCREENSIZE = True

' To enable Mojo 2 support, set this to 'True'.
' If you are for some reason using both Mojo and
' Mojo 2, use the 'mojo2backend' module yourself.
' Such an environment has not been tested.
'#AUTOFIT_MOJO2 = False

' Imports:
Import backend
Import shared