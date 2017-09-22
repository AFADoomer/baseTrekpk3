@ECHO OFF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Mod Folder/Filename Information                                           ::
::  DevFolder	-	Root folder for your mod                             ::
::  WADFolder	-	A sub-folder of DevFolder containing all resources   ::
::                      that will be included in your mod (for me, this is   ::
::                      the files that sync with my GitHub repository.)      ::
::  TargetFile	-	The desired output filename for your mod             ::
::  ACSLib	-	The ACS library that your mod uses, if applicable    ::
::                                                                           ::
::  Sample File/Folder Structure:                                            ::
::                                                                           ::
::  \-Root Folder (contains this file and your compiled mod, once run)       ::
::    \-DevFolder                                                            ::
::      |-ACS (your raw ACS library source - optional)                       ::
::      |-Maps (the map files that you are editing - optional)               ::
::      |-Other Working Files (any other additional folders you want)        ::
::      \-WadFolder (other mod resources, arranged as in a .pk3 structure)   ::
::                                                                           ::
::  This .bat file should be placed *in the root folder*                     ::
::                                                                           ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET DevFolder=Working
SET WADFolder=baseTrekpk3
SET TargetFile=TrekData.pk7
SET LaunchFile=%DevFolder%\%WADFolder%\
SET ACSLib=TrekLib

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Engine/Launch Information                                                 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET Engine=C:\Games\Doom\gzdoom.exe
SET Map=demo
SET RunArgs=-iwad standalone.dat -file Autoload\*.* %* +skill 3 +logfile Log.txt -stdout

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Tool Paths                                                                ::
::  You can change the ACS compiler to GDCC if you want, but must use the    ::
::  command line tool that comes with 7-Zip.                                 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET ACCPath=C:\Games\Doom\Editing Tools\ACC
SET ACCExecutable=acc.exe
SET ZipPath=C:\Program Files\7-Zip\7z.exe

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: End of user-configurable parameters                                       ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CD "%~dp0"

ECHO อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

IF NOT EXIST .\%DevFolder% (
	ECHO The '%DevFolder%' folder does not exist!
	CALL :ERROR 2
)

CD %DevFolder%

IF NOT EXIST .\%WADFolder% (
	ECHO The '%WADFolder%' folder does not exist!
	CALL :ERROR 2
)

IF EXIST .\ACS (
	ECHO Recompiling ACS code...
	IF NOT EXIST .\%WADFolder%\ACS MKDIR .\%WADFolder%\ACS

	IF EXIST .\ACS\acs.err del .\ACS\acs.err

	IF NOT EXIST "%ACCPath%\%ACCExecutable%" (
		ECHO The '%ACCPath%\%ACCExecutable%' ACS compiler was not found!
		CALL :ERROR 2
	)

	ECHO %ACCExecutable% | FINDSTR /i "gdcc" > nul

	IF ERRORLEVEL 1 (
		"%ACCPath%\%ACCExecutable%" -i "%ACCPath%" .\ACS\%ACSLib%.acs ".\%WADFolder%\ACS\%ACSLib%.o" 1> nul 2> nul	
	) ELSE (
		"%ACCPath%\%ACCExecutable%" -i "%ACCPath%" .\ACS\%ACSLib%.acs ".\%WADFolder%\ACS\%ACSLib%.o" 1> nul 2> nul --error-file .\ACS\acs.err
	)

	IF EXIST .\ACS\acs.err CALL :ERROR 1

	IF NOT EXIST .\%WADFolder%\Source MKDIR .\%WADFolder%\Source
	COPY .\ACS\*.acs .\%WADFolder%\Source\ /Y > nul
) ELSE (
	ECHO No new ACS scripts found.
)

IF EXIST .\Maps  (
	ECHO Updating maps in build location...
	IF NOT EXIST .\%WADFolder%\Maps MKDIR .\%WADFolder%\Maps
	COPY .\Maps\*.wad .\%WADFolder%\Maps > nul
) ELSE (
	ECHO No new maps found.
)

ECHO Adding assets to compiled resource file...
CD %WADFolder%

SET ZipFormat=
IF %TargetFile:~-3%==pk3 (
	SET ZipFormat=zip
) ELSE IF %TargetFile:~-3%==pk7 (
	SET ZipFormat=7z
) ELSE (

	SET ZipFormat=%TargetFile:~-3%
)

"%ZipPath%" u -ms=off -uq0 -r -t%ZipFormat% ..\..\%TargetFile% * -xr!*.svn -xr!*.tmp -xr!MD3View_GL_report.txt -xr!*.*.old -xr!.git* -xr!Build > nul
CD ..

IF %ERRORLEVEL% NEQ 0 CALL :ERROR 2

CD ..

ECHO อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

IF "%1" == "norun" GOTO :EOF

IF [%LaunchFile%] EQU [] SET LaunchFile=%TargetFile%

IF [%MAP%] EQU [] (
	ECHO Launching '%LaunchFile%'...
) ELSE (
	ECHO Launching '%LaunchFile%' ^(%MAP%^)...
)

IF "%LaunchFile%"=="%TargetFile%" SET LaunchFile=%TargetFile% -iwad doom.wad

IF [%MAP%] EQU [] (
	%Engine% -file %LaunchFile% %RunArgs%
) ELSE (
	%Engine% -file %LaunchFile% %RunArgs% +map %MAP%
)

IF NOT EXIST %DevFolder%\%WADFolder%\Build MKDIR %DevFolder%\%WADFolder%\Build

REM If the file is over 100MB, GitHub won't take it...
REM COPY %TargetFile% %DevFolder%\%WADFolder%\Build > nul
COPY %0 %DevFolder%\%WADFolder%\Build > nul

ECHO อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
ECHO Build Complete

GOTO :EOF

:ERROR
ECHO อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

IF %1 EQU 1 (
	ECHO An error occured while compiling ACS scripts!
	IF EXIST .\ACS\acs.err (
		TYPE .\ACS\acs.err
	)
) ELSE (
	ECHO An error occurred while building '%TargetFile%'!
)

ECHO อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

PAUSE
EXIT