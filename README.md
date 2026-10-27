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

```Command prompt/Powershell
smartshell time          # Show current time
smartshell date          # Show today's date
smartshell uptime        # Show system uptime
smartshell disk          # Show disk usage
smartshell memory        # Show RAM usage
smartshell ip            # Show network IP
smartshell help          # Show all commands
smartshell echo I am happy  # Echo with emoji reaction
smartshell calc 2*3+5    # Calculate expression
```

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
