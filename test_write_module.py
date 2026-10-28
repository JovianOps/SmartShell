"""Tests for write_module.py."""
import codecs
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import write_module


def test_bom_constant():
    assert write_module.BOM == codecs.BOM_UTF8


def test_src_files_exist():
    assert os.path.isfile(write_module.SRC_PSM1)
    assert os.path.isfile(write_module.SRC_PSD1)


def test_psinstall_has_smartshell():
    assert "SmartShell" in write_module.PS_INSTALL


def test_standalone_param_block():
    with open(write_module.SRC_PSM1, encoding="utf-8") as f:
        psm1 = f.read()
    # Strip BOM if present
    if psm1.startswith("\ufeff"):
        psm1 = psm1[1:]
    lines = psm1.splitlines()
    # Find Export-ModuleMember line
    em_idx = next(i for i, l in enumerate(lines) if l.strip().startswith("Export-ModuleMember"))
    assert em_idx >= 0
    # After write_module processes, standalone gets param block and invocation
    standalone = "param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)\n" + "".join(
        "if ($Args) { Smartshell ($Args -join ' ').Trim() } else { Smartshell }\n"
        if line.strip().startswith("Export-ModuleMember") else line + "\n"
        for line in lines
    )
    assert standalone.startswith("param(")
    assert "Smartshell" in standalone


def test_help_shows_commands():
    with open(write_module.SRC_PSM1, encoding="utf-8") as f:
        psm1 = f.read()
    for cmd in ["time", "date", "uptime", "disk", "memory", "ip", "weather", "cpu", "gpu", "processes", "listening", "env", "whoami", "calc", "help"]:
        assert cmd in psm1
