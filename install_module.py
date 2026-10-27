#!/usr/bin/env python3
"""Install SmartShell module files with BOM."""
import os, shutil

BASE = os.path.dirname(os.path.abspath(__file__))
SCRATCH_PSM1 = os.path.join(BASE, "scratch_psm1.txt")
SCRATCH_PSD1 = os.path.join(BASE, "scratch_psd1.txt")

REPO_DIR = os.path.join(BASE, "Modules", "SmartShell")
PS_DIR = "D:/Athalla/Desktop/PowerShell-7.6.6-win-x64/Modules/SmartShell"
SRC_PSM1 = os.path.join(BASE, "SmartShell.ps1")  # standalone mirror of .psm1

BOM = b"\xef\xbb\xbf"

os.makedirs(REPO_DIR, exist_ok=True)
os.makedirs(PS_DIR, exist_ok=True)

with open(SCRATCH_PSM1, encoding="utf-8") as f:
    psm1 = f.read()
with open(SCRATCH_PSD1, encoding="utf-8") as f:
    psd1 = f.read()

def write_bom(path, content):
    raw = content.encode("utf-8")
    if raw[:3] != BOM:
        raw = BOM + raw
    with open(path, "wb") as f:
        f.write(raw)

repo_psm1 = os.path.join(REPO_DIR, "SmartShell.psm1")
repo_psd1 = os.path.join(REPO_DIR, "SmartShell.psd1")
ps_psm1 = os.path.join(PS_DIR, "SmartShell.psm1")
ps_psd1 = os.path.join(PS_DIR, "SmartShell.psd1")

write_bom(repo_psm1, psm1)
write_bom(repo_psd1, psd1)
write_bom(ps_psm1, psm1)
write_bom(ps_psd1, psd1)
shutil.copy2(repo_psm1, SRC_PSM1)  # .ps1 mirror

for p in [repo_psm1, repo_psd1, ps_psm1, ps_psd1]:
    print(f"  {p}: {os.path.getsize(p)} bytes")
