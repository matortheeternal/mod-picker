@echo off
set separator===================================================

REM loop through esms first
for /r %%f in (Skyrim\plugins\*.esm) do (
	if NOT "%%~nxf"=="Skyrim.esm" if NOT "%%~nxf"=="Update.esm" if NOT "%%~nxf"=="Dawnguard.esm" if NOT "%%~nxf"=="HearthFires.esm" if NOT "%%~nxf"=="Dragonborn.esm" (
		ModDump.exe "Skyrim\plugins\%%~nxf" -sk
		echo. && echo. && echo %separator% && echo. && echo.
	)
)

REM loop through esps second
for /r %%f in (Skyrim\plugins\*.esp) do (
	ModDump.exe "Skyrim\plugins\%%~nxf" -sk
	echo. && echo. && echo %separator% && echo. && echo.
)

pause