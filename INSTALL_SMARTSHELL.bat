@echo off
:: SmartShell Installer
:: Copies the module to PowerShell auto-load directory
:: After install, just type "Smartshell" in PowerShell 7.6.6+

set "MODULE_SRC=%~dp0Modules\SmartShell"
set "MODULE_DST=%LOCALAPPDATA\Microsoft\PowerShell\Modules\SmartShell"

echo Installing SmartShell module to: "%MODULE_DST%"

if not exist "%MODULE_DST%" mkdir "%MODULE_DST%"
xcopy /E /Y "%MODULE_SRC%" "%MODULE_DST%" >nul

echo.
echo Installed! Now in PowerShell 7.6.6+, just type:
echo   Smartshell
echo.
echo Or run a quick command:
echo   smartshell time
echo   smartshell echo I am happy
echo   smartshell calc 2*3+5
echo.
echo Source: %MODULE_SRC%
echo.
pause
