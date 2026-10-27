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
echo   smartshell calc
echo   smartshell memory
echo.
echo I will show you how types of command works.
echo smartshell memory shows you how much ram usage you have right now.
echo smartshell calc shows you the answer to the expression question you have right now.
echo smartshell echo shows you echo message and there might be some emojis(thats supposed to be there its good for yall)
echo.
echo Source: %MODULE_SRC%
echo.
pause
