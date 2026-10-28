# Security Policy

## Reporting a Vulnerability

We take security seriously. If you find a vulnerability in SmartShell, please report it responsibly:

- **Do NOT open a public issue**
- Message @athallajovian in Telegram or DM sg2terompet_35750 in Discord
  
We will respond within 48 hours and work with you to address the issue.

## Known Risks

- `calc` command uses `Invoke-Expression` — only run expressions you trust
- No network requests are made by SmartShell; all commands run locally
