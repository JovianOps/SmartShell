#!/usr/bin/env python3
"""
SmartShell module file generator.

Reads SmartShell.psm1 and SmartShell.psd1 from this directory and writes
BOM-enabled copies to the PowerShell module path. Avoids embedding
PowerShell source as Python string literals (which caused BOM/escape issues).

Usage:
    python write_module.py
"""
import os
import codecs

BASE = os.path.dirname(os.path.abspath(__file__))

# Source files in the repo
SRC_PSM1 = os.path.join(BASE, "Modules", "SmartShell", "SmartShell.psm1")
SRC_PSD1 = os.path.join(BASE, "Modules", "SmartShell", "SmartShell.psd1")

# Installed module path — uses SMARTSHELL_PS_INSTALL env var if set,
# otherwise defaults to LOCALAPPDATA\Microsoft\PowerShell\Modules\SmartShell
PS_INSTALL = os.environ.get(
    "SMARTSHELL_PS_INSTALL",
    os.path.join(os.environ.get("LOCALAPPDATA", ""), "Microsoft", "PowerShell", "Modules", "SmartShell")
) or os.path.join(os.path.dirname(BASE), "PowerShell-7.6.6-win-x64", "Modules", "SmartShell")

STANDALONE_PS1 = os.path.join(BASE, "SmartShell.ps1")

BOM = codecs.BOM_UTF8


def write_bom_utf8(path, content):
    """Write content as UTF-8 with BOM, avoiding double-BOM."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if isinstance(content, str):
        raw = content.encode("utf-8")
    else:
        raw = content
    if raw[:3] != BOM:
        raw = BOM + raw
    with open(path, "wb") as f:
        f.write(raw)


def main():
    with open(SRC_PSM1, encoding="utf-8") as f:
        psm1 = f.read()
    with open(SRC_PSD1, encoding="utf-8") as f:
        psd1 = f.read()

    # Standalone .ps1: param block FIRST, replace Export-ModuleMember line with invocation
    psm1_stripped = psm1[1:] if psm1.startswith("﻿") else psm1
    lines = psm1_stripped.splitlines(keepends=True)
    standalone_lines = []
    for line in lines:
        if line.strip().startswith("Export-ModuleMember"):
            standalone_lines.append("if ($Args) { Smartshell ($Args -join ' ').Trim() } else { Smartshell }\n")
        else:
            standalone_lines.append(line)
    standalone = "param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)\n" + "".join(standalone_lines)

    targets = {
        SRC_PSM1: psm1,
        SRC_PSD1: psd1,
        os.path.join(PS_INSTALL, "SmartShell.psm1"): psm1,
        os.path.join(PS_INSTALL, "SmartShell.psd1"): psd1,
        STANDALONE_PS1: standalone,
    }
    # Also write to portable pwsh module path if it exists
    portable_path = os.path.join(os.path.dirname(BASE), "PowerShell-7.6.6-win-x64", "Modules", "SmartShell")
    if os.path.isdir(os.path.dirname(portable_path)):
        targets[os.path.join(portable_path, "SmartShell.psm1")] = psm1
        targets[os.path.join(portable_path, "SmartShell.psd1")] = psd1
    # Also copy standalone .ps1 to portable pwsh directory
    portable_ps1 = os.path.join(os.path.dirname(BASE), "PowerShell-7.6.6-win-x64", "SmartShell.ps1")
    if os.path.isdir(os.path.dirname(portable_ps1)):
        targets[portable_ps1] = standalone

    for path, content in targets.items():
        write_bom_utf8(path, content)
        print(f"  {path}: {os.path.getsize(path)} bytes")


if __name__ == "__main__":
    main()
