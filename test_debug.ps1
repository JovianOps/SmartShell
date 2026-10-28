Import-Module SmartShell -Force
Get-SystemInfo
if ($Error) { $Error | Select-Object -First 3 | Format-List }
