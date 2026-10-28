$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$DefaultLocation = $env:SMARTSHELL_WEATHER_LOCATION
if (-not $DefaultLocation) {
    $DefaultLocation = "auto"
}

# Emoji expressions
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
    "no" = "👎"; "hi" = "👋"; "bye" = "👋"; "seesh" = "🥶"
}

function Get-Time {
    $tz = [System.TimeZoneInfo]::Local
    $now = Get-Date
    Write-Host "🕒 Current time: $($now.ToString('HH:mm:ss')) ($($tz.StandardName))" -ForegroundColor Green
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

function Get-Weather {
    param([string]$Location = "")
    $loc = if ($Location) { $Location.Replace(' ','+') } else {
        if ($DefaultLocation -eq "auto") { "" } else { $DefaultLocation.Replace(' ','+') }
    }
    $url = if ($loc) { "https://wttr.in/$loc" } else { "https://wttr.in" }
    try {
        $resp = curl.exe -s --max-time 5 --get "$url" --data-urlencode "format=3" 2>$null
        if ($resp) {
            Write-Host "🌤️ $resp" -ForegroundColor Blue
        } else {
            Write-Host "🌤️ Offline - weather data unavailable" -ForegroundColor DarkGray
        }
    } catch {
        Write-Host "🌤️ Offline - weather data unavailable" -ForegroundColor DarkGray
    }
}

function Get-CpuInfo {
    Get-CimInstance Win32_PerfFormattedData_PerfProc_Process |
        Where-Object { $_.Name -notmatch '_Total|Idle|_Global' -and $_.PercentProcessorTime -gt 0 } |
        Sort-Object PercentProcessorTime -Descending |
        Select-Object -First 5 Name, PercentProcessorTime |
        ForEach-Object {
            $pct = $_.PercentProcessorTime
            $emoji = if ($pct -gt 50) { "🔴" } elseif ($pct -gt 20) { "🟡" } else { "🟢" }
            $color = if ($pct -gt 50) { "Red" } elseif ($pct -gt 20) { "Yellow" } else { "Green" }
            Write-Host "$emoji $($_.Name): $($pct)%" -ForegroundColor $color
        }
}

function Get-GpuInfo {
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    $pct = $null
    if ($gpu.AdapterCompatibility -match "NVIDIA") {
        try { $pct = (nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader 2>$null).Trim() } catch {}
    } elseif ($gpu.AdapterCompatibility -match "AMD|ATI") {
        try { $pct = (amd-smi metric gpu --json 2>$null | ConvertFrom-Json).gpu[0].gpu_utilization_percentage } catch {}
    } elseif ($gpu.AdapterCompatibility -match "Intel") {
        try {
            $samples = Get-Counter "\GPU Engine(*)\Utilization Percentage" -ErrorAction Stop |
                Select-Object -ExpandProperty CounterSamples |
                Where-Object { $_.CookedValue -gt 0 }
            if ($samples) { $pct = [int]($samples | Measure-Object -Property CookedValue -Average).Average }
        } catch {}
    }
    if ($null -ne $pct) {
        $p = if ($pct -is [string]) { [int]$pct.Replace('%','').Trim() } else { [int]$pct }
        $emoji = if ($p -gt 75) { "🔴" } elseif ($p -gt 40) { "🟡" } else { "🟢" }
        $color = if ($p -gt 75) { "Red" } elseif ($p -gt 40) { "Yellow" } else { "Green" }
        Write-Host "🎮 GPU: $($gpu.Name) — Load: " -NoNewline -ForegroundColor Magenta
        Write-Host "$emoji $p%" -ForegroundColor $color
    } else {
        Write-Host "🎮 GPU: $($gpu.Name) — Load: N/A (vendor: $($gpu.AdapterCompatibility))" -ForegroundColor Magenta
    }
}

function Get-ProcessList {
    $procs = Get-Process | Sort-Object WS -Descending | Select-Object -First 10
    foreach ($p in $procs) {
        $mem = [math]::Round($p.WS / 1MB, 1)
        Write-Host "  $($p.ProcessName) ($mem MB)" -ForegroundColor DarkGray
    }
}

function Get-ListeningPorts {
    netsh advfirewall firewall show rule name=all 2>$null | Out-Null
    $ports = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort
    foreach ($p in $ports) {
        Write-Host "  Listening: $($p.LocalAddress):$($p.LocalPort)" -ForegroundColor DarkGray
    }
}

function Get-EnvInfo {
    Write-Host "  Computer: $env:COMPUTERNAME" -ForegroundColor DarkGray
    Write-Host "  User: $env:USERNAME" -ForegroundColor DarkGray
    Write-Host "  OS: $env:OS" -ForegroundColor DarkGray
}

function Get-Whoami {
    Write-Host "  You are: $env:USERNAME@$env:COMPUTERNAME" -ForegroundColor DarkGray
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
        "^weather\s+(.+)$" { Get-Weather -Location $matches[1] }
        "^weather$" { Get-Weather }
        "^cpu$" { Get-CpuInfo }
        "^gpu$" { Get-GpuInfo }
        "^processes$" { Get-ProcessList }
        "^procs$" { Get-ProcessList }
        "^listening$" { Get-ListeningPorts }
        "^ports$" { Get-ListeningPorts }
        "^env$" { Get-EnvInfo }
        "^whoami$" { Get-Whoami }
        "^calc\s+(.+)$" {
            try {
                $result = Invoke-Expression $matches[1]
                Write-Host "🔢 Result: $result" -ForegroundColor Green
            } catch {
                Write-Host "❌ Calc error: $_" -ForegroundColor Red
            }
        }
        "^help$" {
            Write-Host @'
Available commands:
  time            - Show current time
  date            - Show today's date
  uptime          - Show system uptime
  disk            - Show disk usage
  memory / mem    - Show RAM usage
  ip / network    - Show network IP
  weather [location]  - Show weather (e.g. weather bromo)
  cpu             - Show CPU info
  gpu             - Show GPU info
  processes       - Show top 10 processes
  listening       - Show listening ports
  env             - Show environment info
  whoami          - Show current user
  calc <expr>     - Calculate expression (e.g. calc 2*3+5)
  echo <message>  - Echo message (with emoji expressions)
  help            - Show this help
'@ -ForegroundColor Cyan
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
        Write-Host "  Made by Athalla. All rights reserved. " -ForegroundColor DarkRed
        Write-Host "========================================" -ForegroundColor Blue
        Write-Host "   SmartShell v1.1.0 - Expressive Terminal" -ForegroundColor Blue
        Write-Host "========================================" -ForegroundColor Blue
        Write-Host "Type 'help' for commands, 'exit' to quit" -ForegroundColor DarkGray
        Write-Host ""

        while ($true) {
            Write-Host "✨ " -NoNewline -ForegroundColor Magenta
            $userInput = Read-Host
            if ($null -eq $userInput) { break }
            if ($userInput -match "^exit$|^quit$") { break }
            Smart-Write -Line ($userInput.Trim())
        }
        Write-Host "`n👋 Goodbye!" -ForegroundColor Green
    }
}

Export-ModuleMember -Function Smartshell, Smart-Write, Get-Time, Get-DateInfo, Get-DiskInfo, Get-Uptime, Get-MemoryInfo, Get-NetworkInfo, Get-Weather, Get-CpuInfo, Get-GpuInfo, Get-ProcessList, Get-ListeningPorts, Get-EnvInfo, Get-Whoami, Show-Expression
