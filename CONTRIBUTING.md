# Contributing to SmartShell

Thanks for your interest in contributing! Here's how to get started:

## Getting Started

1. Fork the repo: https://github.com/JovianOps/SmartShell/fork
2. Clone your fork locally
3. Make your changes
4. Test in PowerShell 7.6.6+
5. Open a PR

## Development

- All PowerShell code must work in **PowerShell 7.6.6+**
- Files must be UTF-8 with BOM
- Run `Import-Module` to test before committing

## ⚠️ Linux / Ubuntu Support Needed

**SmartShell currently only works on Windows.** PRs that add Linux/Ubuntu support are **highly welcome and desperately needed**. Specifically:

- `Get-DiskInfo` — uses `Get-PSDrive` which should work on Linux but may need path adjustments
- `Get-Uptime` — uses `Win32_OperatingSystem` CIM class which is Windows-only; needs `Get-Uptime` equivalent or `/proc/uptime`
- `Get-NetworkInfo` — `Get-NetIPAddress` is Windows-only; needs `ip addr` or `ifconfig` fallback
- `Get-MemoryInfo` — `Win32_OperatingSystem` CIM class is Windows-only; needs `/proc/meminfo` fallback

If you're a Linux user and want to contribute, this is where the project needs you most.

## Submitting Changes

- Keep your PR focused — one feature or fix at a time
- Include before/after screenshots if you change emoji or colors
- Update `README.md` if you add new commands
- All PRs welcome — we review within 24-48 hours
