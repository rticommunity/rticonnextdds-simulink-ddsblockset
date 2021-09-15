@REM This script generates a shorcut in the desktop of RTI Connext DDS
@REM %1 is the name of the shorcut
@REM %2 is the path where RTILauncher.exe lives
@REM example: shorcut.bat "RTI Connext DDS 6.0.1" "C:\rti_connext_dds-6.0.1\"

@echo off

set lnk_path_name=%HOMEDRIVE%%HOMEPATH%\Desktop\%~1.lnk
set launcher_path=%~2\RTILauncher.exe
set script=shorcut_%RANDOM%_tmp.vbs
(
  echo set wscript_object = WScript.CreateObject("WScript.Shell"^)
  echo lnk_path = wscript_object.ExpandEnvironmentStrings("%lnk_path_name%"^)
  echo set shorcut = wscript_object.CreateShortcut(lnk_path^)
  echo shorcut.TargetPath = "%launcher_path%"
  echo shorcut.Save
)1>%script%
cscript //nologo .\%script%
del %script% /f /q
