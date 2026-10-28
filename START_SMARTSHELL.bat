@echo off
where pwsh >nul 2>&1 && (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0SmartShell.ps1" %*
) || (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0SmartShell.ps1" %*
)
