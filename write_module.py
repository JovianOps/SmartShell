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

BASE = os.path.dirname(os.path.abspath(__file__))

# Source files in the repo (no BOM — readable by any tool)
SRC_PSM1 = os.path.join(BASE, "Modules", "SmartShell", "SmartShell.psm1")
SRC_PSD1 = os.path.join(BASE, "Modules", "SmartShell", "SmartShell.psd1")

# Installed module path for PowerShell 7.6.6
PS_INSTALL = os.path.join(
    os.path.dirname(BASE),
    "PowerShell-7.6.6-win-x64", "Modules", "SmartShell"
)

# Mirror: standalone .ps1 that can be dot-sourced directly
STANDALONE_PS1 = os.path.join(BASE, "SmartShell.ps1")

BOM = b"\xef\xbb\xbf"


def write_bom_utf8(path, content):
    """Write content as UTF-8 with BOM, but avoid double-BOM if source already has one."""
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

    targets = {
        SRC_PSM1: psm1,
        SRC_PSD1: psd1,
        os.path.join(PS_INSTALL, "SmartShell.psm1"): psm1,
        os.path.join(PS_INSTALL, "SmartShell.psd1"): psd1,
        STANDALONE_PS1: psm1,
    }

    for path, content in targets.items():
        write_bom_utf8(path, content)
        print(f"  {path}: {os.path.getsize(path)} bytes")


if __name__ == "__main__":
    main()
