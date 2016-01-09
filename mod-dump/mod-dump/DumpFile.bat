@echo off
set /p path="Enter path: "
ModDump.exe %path% -sk
pause