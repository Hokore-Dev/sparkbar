# Contributing to SparkBar

Thanks for your interest in improving SparkBar! This is a small, focused
project — a single-purpose macOS menu bar app — and contributions of all sizes
are welcome.

## Getting started

```bash
git clone https://github.com/Hokore-Dev/sparkbar.git
cd sparkbar/app
./build.sh
```

The build script compiles a universal (arm64 + x86_64) binary, ad-hoc signs it,
and launches the app. No Xcode project is required — it's plain `swiftc`.

**Requirements:** macOS 12+, the Xcode Command Line Tools, and [Claude Code](https://claude.com/claude-code)
logged in (`claude login`) so the app has a token to read.

## Project layout

| File | Responsibility |
| --- | --- |
| `app/Sources/AppMain.swift` | Status item, menu, poll timer, menu bar icon |
| `app/Sources/UsageManager.swift` | Fetches usage, owns settings & notifications |
| `app/Sources/CredentialStore.swift` | Reads/refreshes the Claude Code OAuth token |
| `app/Sources/UsageMenuView.swift` | Usage gauges shown in the menu |
| `app/Sources/SettingsView.swift` | Settings window |
| `app/Sources/HotKeyCenter.swift` | Global ⌘U hotkey (Carbon) |
| `app/Sources/Support.swift` | Shared URLs, notifications, date formatting |

Keep the **one-responsibility-per-file** convention.

## Style

- Match the surrounding code: clear names, small types, comments that explain *why*.
- `swiftlint` runs in CI (non-blocking). Run it locally with `swiftlint` if you have it installed.
- No new compiler warnings.

## Submitting a change

1. Open an issue first for anything non-trivial, so we can agree on the approach.
2. Branch from `main`, make your change, and run `./build.sh` to confirm it compiles.
3. Open a PR using the template. Keep it focused — one logical change per PR.

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By
participating, you agree to uphold it.
