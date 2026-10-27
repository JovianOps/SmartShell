param($InputScript = "")

$Emoji = @{
    ":)" = "😊"; ":(" = "😞"; ";)" = "😉"
    "<3" = "❤️"; ":o" = "😮"; ":p" = "😛"
    "angry" = "😠"; "happy" = "😄"; "sad" = "😢"
    "think" = "🤔"; "cool" = "😎"; "confused" = "😕"
    "love" = "😍"; "tired" = "😩"; "surprised" = "😱"
    "wink" = "😉"; "silly" = "🤪"; "nerd" = "🤓"
    "cute" = "🥰"; "cry" = "😭"; "wow" = "🤯"
    "shy" = "😊"; "mad" = "😠"; "bored" = "😴"
    "excited" = "🤩"; "scared" = "😨"; "joking" = "😂"
    "facepalm" = "🤦"; "ok" = "👌"; "yes" = "👍"
    "no" = "👎"; "hi" = "👋"; "bye" = "👋"
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

function Get-MemoryInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $used = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 2)
    $total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    Write-Host "🧠 Memory: $used GB used / $total GB total" -ForegroundColor Blue
}

function Get-NetworkInfo {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet","Wi-Fi" -ErrorAction SilentlyContinue).IPAddress
    Write-Host "🌐 IP: $ip" -ForegroundColor Cyan
}

function Show-Expression {
    param([string]$Text)
    $lower = $Text.ToLower()
    foreach ($key in $Emoji.Keys) {
        if ($lower.Contains($key.ToLower())) {
            Write-Host "  ─ $($Emoji[$key])" -ForegroundColor Yellow
            return
        }
    }
}

function Smart-Write {
    param([string]$Line)
    Show-Expression $Line
    switch -Regex ($Line) {
        "^time$" { Get-Time }
        "^date$" { Get-DateInfo }
        "^uptime$" { Get-Uptime }
        "^disk$" { Get-DiskInfo }
        "^memory$" { Get-MemoryInfo }
        "^mem$" { Get-MemoryInfo }
        "^ip$" { Get-NetworkInfo }
        "^network$" { Get-NetworkInfo }
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
  memory / mem    - Show RAM usage
  ip / network    - Show network IP
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

function Smartshell {
    [CmdletBinding()]
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$InputScript)
    if ($InputScript) {
        Smart-Write -Line ($InputScript -join ' ').Trim()
    } else {
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

Export-ModuleMember -Function Smartshell, Smart-Write, Get-Time, Get-DateInfo, Get-DiskInfo, Get-Uptime, Get-MemoryInfo, Get-NetworkInfo, Show-Expression
