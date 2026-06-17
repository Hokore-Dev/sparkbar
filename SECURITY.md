# Security Policy

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Instead, email **haminjun0@gmail.com** with:

- A description of the issue and its impact
- Steps to reproduce
- Any relevant logs or proof of concept

You can expect an initial response within a few days. Please give a reasonable
amount of time for a fix before any public disclosure.

## How SparkBar handles your data

- The app reads the OAuth token that **Claude Code** stores in your macOS login
  keychain (service `Claude Code-credentials`) — the same credential Claude Code
  itself uses.
- That token is sent **only** to Anthropic's API (`api.anthropic.com`) to fetch
  your usage and to refresh the token when it expires. Refreshed tokens are
  written back to the keychain so Claude Code stays in sync.
- No usage data, tokens, or telemetry are sent anywhere else. There is no
  analytics or third-party service.
- Settings are stored locally in `UserDefaults`.

## Supported versions

This is an actively developed project; only the latest release is supported with
security fixes.
