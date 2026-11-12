@echo off
REM Double-click this file to install the Hollow Knight Lithuanian translation.
REM
REM If you keep the game in a Steam library other than the default one, run
REM this from a command prompt instead and pass the installation folder:
REM     install.bat "D:\SteamLibrary\steamapps\common\Hollow Knight"

setlocal
set "HERE=%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%install.ps1" %*
set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
    pause
) else (
    echo Installation failed. Read the message above.
    pause
)
exit /b %RC%
