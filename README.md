# SmartShell

Expressive terminal for PowerShell 7.6.6+ with emoji reactions and smart commands.

## Install

### Windows (PowerShell 7.6.6+)

```bat
INSTALL_SMARTSHELL.bat
```

Or manually copy `Modules/SmartShell/` to your PowerShell modules directory.

### Quick Clone (any OS with Node.js)

```bash
npx degit JovianOps/SmartShell
```

Then run `INSTALL_SMARTSHELL.bat` (Windows) or copy files manually (Linux/macOS — experimental).
## Usage

```powershell
smartshell time          # Show current time
smartshell date          # Show today's date
smartshell uptime        # Show system uptime
smartshell disk          # Show disk usage
smartshell temp          # Show disk, CPU, GPU temperatures
smartshell system        # Show system overview (CPU, GPU, RAM, disk, battery)
smartshell snake         # Play Snake (arrow keys to steer, Escape to quit)
smartshell memory        # Show RAM usage
smartshell ip            # Show local IP + bandwidth usage
smartshell internet      # Show public IP + bandwidth usage
smartshell network       # Alias for ip
smartshell weather [city] # Show weather (e.g. smartshell weather bromo)
smartshell cpu           # Show top processes by CPU usage (with color emoji)
smartshell gpu           # Show GPU load (NVIDIA/AMD via vendor tools)
smartshell processes     # Show top 10 processes
smartshell listening     # Show listening ports
smartshell env           # Show environment info
smartshell whoami        # Show current user
smartshell help          # Show all commands
smartshell echo I am happy  # Echo with emoji reaction
smartshell calc 2*3+5    # Calculate expression
smartshell close <name>  # Close process by partial name (auto-kills all matches)
```

### CPU Usage

The `cpu` command shows the top 5 processes by CPU usage with color-coded indicators:

- 🔴 50%+ — high usage
- 🟡 20–49% — moderate usage
- 🟢 below 20% — low usage

### GPU Load

The `gpu` command shows real-time GPU utilization. Detection is vendor-aware:

- **NVIDIA**: uses `nvidia-smi` (requires NVIDIA drivers installed)
- **AMD**: uses `amd-smi` (requires AMD software stack)
- **Intel**: uses `Get-Counter` Windows performance counters
- **Other**: shows `N/A` if no supported vendor tool is available

Color-coded indicators match CPU (🔴/🟡/🟢).

### Network Usage

The `ip` command shows your local IPv4 address and per-interface bandwidth (bytes/sec).
The `internet` command additionally shows your public IP via ipify.org.

Both use `Get-Counter "\Network Interface(*)\Bytes Total/sec"` with 500ms sampling for real-time values:

- 🟢 under 1 KB/s — low traffic
- 🟡 over 1 KB/s — moderate traffic
- 🔴 over 1 MB/s — high traffic

### System Overview

The `system` command shows a one-line overview of your entire machine:

```
🟢 CPU: AMD Ryzen 5 3600  🟢 14%
🟡 GPU: NVIDIA GeForce GTX 1650  🟡 47% | 63.30°C
🧠 RAM: 7.3/15.9 GB  🟢 46%
💾 Disk: 213.1/237.4 GB  🔴 90%
```

- CPU: model + load percentage with color emoji (🔴 >50%, 🟡 >20%, 🟢 below)
- GPU: model + load + temperature (NVIDIA via `nvidia-smi`, AMD via `amd-smi`)
- RAM: used/total with color emoji
- Disk: used/total with color emoji (🔴 >80%, 🟡 >60%, 🟢 below)
- Battery: percentage + charging/discharging (only on laptops)

### Snake

The `snake` command launches a playable Snake game with arrow-key controls. The snake wraps around screen edges. Food appears as 🍎, the head as 🟪, and the body as 🟦. The game speeds up as you score. Press Escape to quit.

### Temperature

The `temp` command shows system temperatures:

- **GPU**: via `nvidia-smi` (NVIDIA) or `amd-smi` (AMD)
- **Disks**: via `Get-PhysicalDisk` with `Get-StorageReliabilityCounter` (SSD/HDD/NVMe)
- **CPU**: via `MSAcpi_ThermalZoneTemperature` (ACPI — availability depends on motherboard/BIOS)

Color-coded disk indicators:
- 🟢 below 45°C — cool
- 🟡 above 45°C — warm  
- 🔴 above 60°C — hot

## REPL Mode

```powershell
smartshell              # Enter interactive REPL
```

Type `exit` to quit.

## Requirements

- PowerShell 7.6.6+
- UTF-8 output encoding for emoji support

## Security

This module uses `Invoke-Expression` for the `calc` command. Only run trusted expressions.
See [SECURITY.md](SECURITY.md) for details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). **Linux/Ubuntu support is needed** — PRs welcome!
