# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-06-15

### Added

- Menu bar display of Claude **session (5-hour)** and **weekly (7-day)** usage,
  including weekly Sonnet when reported.
- Color-coded spark icon (green / orange / red) reflecting session usage.
- Threshold notifications at 25%, 50%, 75%, and 90% of the session limit.
- Global **⌘U** shortcut to open the popover.
- Auto-refresh every 5 minutes and on menu open.
- Optional "Open at Login" (macOS 13+).
- Reads the Claude Code OAuth token from the login keychain — no cookies or
  manual credentials required.

[Unreleased]: https://github.com/Hokore-Dev/sparkbar/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Hokore-Dev/sparkbar/releases/tag/v1.0.0
