#!/usr/bin/env python3
import os

content = r"""param($InputScript = "")

# Emoji expressions
$Emoji = @{
    ":)" = "😊"; ":(" = "😞"; ";)" = "😉"
    "<3" = "❤️"; ":o" = "😮"; ":p" = "😛"
    "angry" = "😠"; "happy" = "😄"; "sad" = "😢"
    "think" = "🤔"; "cool" = "😎"; "confused" = "😕"
    "love" = "😍"; "tired" = "😩"; "surprised" = "😱"
    "wink" = "😉"; "silly" = "🤪"; "nerd" = "🤓"
}

function Get-Time {
    $now = Get-Date
    Write-Host "🕒 Current time: $($now.ToString('HH:mm:ss'))" -ForegroundColor Green
}

function Get-DateInfo {
    $now = Get-Date
    Write-Host "📅 Today is $($now.ToString('dddd, MMMM dd, yyyy'))" -ForegroundColor Cyan
}

function Get-DiskInfo {
    $drives = Get-PSDrive -PSProvider FileSystem
    foreach ($drive in $drives) {
        $used = [math]::Round($drive.Used / 1GB, 2)
        $total = [math]::Round(($drive.Used + $drive.Free) / 1GB, 2)
        Write-Host "💾 $($drive.Name): $used GB used / $total GB total" -ForegroundColor Yellow
    }
}

function Get-Uptime {
    $lastBoot = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime
    $uptime = (Get-Date) - $lastBoot
    Write-Host "⏱️ Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Magenta
}

function Show-Expression {
    param([string]$Input)
    $lower = $Input.ToLower()
    foreach ($key in $Emoji.Keys) {
        if ($lower.Contains($key.ToLower())) {
            Write-Host "  ═ ═ $($Emoji[$key])" -ForegroundColor Yellow
            return
        }
    }
}

function Smart-Write {
    param([string]$Line)
    Show-Expression -Input $Line
    switch -Regex ($Line) {
        "^time$" { Get-Time }
        "^date$" { Get-DateInfo }
        "^uptime$" { Get-Uptime }
        "^disk$" { Get-DiskInfo }
        "^calc\s+(.+)$" {
            try {
                $result = Invoke-Expression $matches[1]
                Write-Host "🔢 Result: $result" -ForegroundColor Green
            } catch {
                Write-Host "❌ Calc error: $_" -ForegroundColor Red
            }
        }
        "^help$" {
            Write-Host @"
Available commands:
  time            - Show current time
  date            - Show today's date
  uptime          - Show system uptime
  disk            - Show disk usage
  calc <expr>     - Calculate expression (e.g. calc 2*3+5)
  echo <message>  - Echo message (with emoji expressions)
  help            - Show this help
"@ -ForegroundColor Cyan
        }
        "^echo\s+(.+)$" {
            Write-Host "  📝 $($matches[1])" -ForegroundColor White
        }
        default {
            if ($Line.Trim()) {
                Write-Host "  💭 $($Line)" -ForegroundColor DarkGray
            }
        }
    }
}

function smartshell {
    if ($InputScript) {
        $cmd = $InputScript.Trim()
        Smart-Write -Line $cmd
    } else {
        Write-Host " Made by Athalla. All rights reserved.  " -ForegroundColor B
        Write-Host "========================================" -ForegroundColor Blue
        Write-Host "   SmartShell v1.0 - Expressive Terminal" -ForegroundColor Blue
        Write-Host "========================================" -ForegroundColor Blue
        Write-Host "Type 'help' for commands, 'exit' to quit" -ForegroundColor DarkGray
        Write-Host ""

        while ($true) {
            Write-Host "✨ " -NoNewline -ForegroundColor Magenta
            $userInput = Read-Host
            if ($userInput -match "^exit$|^quit$") { break }
            Smart-Write -Line $userInput
        }
        Write-Host "`n👋 Goodbye!" -ForegroundColor Green
    }
}

Export-ModuleMember -Function smartshell, Smart-Write, Get-Time, Get-DateInfo, Get-DiskInfo, Get-Uptime
"""

# Write .psm1 with UTF-8 BOM
psm1_path = "/d/Athalla/Desktop/SmartShell/Modules/SmartShell/SmartShell.psm1"
os.makedirs(os.path.dirname(psm1_path), exist_ok=True)
with open(psm1_path, "wb") as f:
    f.write(b"\xef\xbb\xbf")
    f.write(content.encode("utf-8"))

# Write manifest with UTF-8 BOM
psd1_path = "/d/Athalla/Desktop/SmartShell/Modules/SmartShell/SmartShell.psd1"
psd1_content = """@{
    RootModule        = 'SmartShell.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b8a4e2c1-9f3d-4a5b-8e6f-1a2b3c4d5e6f'
    Author            = 'JovianOps'
    CompanyName       = 'Vortex Industries'
    Description       = 'Expressive terminal with emoji reactions'
    FunctionsToExport = @('smartshell', 'Smart-Write', 'Get-Time', 'Get-DateInfo', 'Get-DiskInfo', 'Get-Uptime')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PowerShellVersion = '7.0'
}
"""
with open(psd1_path, "wb") as f:
    f.write(b"\xef\xbb\xbf")
    f.write(psd1_content.encode("utf-8"))

print(f"Wrote {psm1_path} ({len(content)} chars)")
print(f"Wrote {psd1_path}")
