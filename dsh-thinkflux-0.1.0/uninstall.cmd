@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1" %*
set ERR=%ERRORLEVEL%
if not "%~1"=="" goto :eof
echo.
pause
exit /b %ERR%
