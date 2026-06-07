# Utilities for Codex

Utilities for Codex is a macOS companion app for stable local automation services that Codex plugins can call without packaging a signed `.app` bundle inside a hot-swappable plugin cache.

The first planned service is a desktop automation bridge for Socket's `codex-utilities` plugin. The app owns the stable macOS identity, permission flow, local transport, and runtime status UI. The Socket plugin owns the agent-facing MCP tools and skills.

## Goals

- Install and maintain the Socket marketplace in the user's Codex environment.
- Host stable local services for Codex utilities that need macOS trust surfaces.
- Keep Accessibility, automation permissions, signing, notarization, and service identity attached to one installed app.
- Let Socket plugins expose lightweight MCP and skill adapters instead of shipping relocatable `.app` bundles.

## Current Shape

- Native macOS SwiftUI app.
- XcodeGen-backed project with checked-in external `.xcconfig` build settings.
- Menu bar-oriented starter shell.
- Root roadmap in `ROADMAP.md`.
- Detailed architecture plan in `docs/plans/desktop-bridge-plan.md`.

## Development

Regenerate the Xcode project after editing `project.yml`:

```bash
xcodegen generate --spec project.yml
```

Run the repo-maintenance validation wrapper:

```bash
scripts/repo-maintenance/validate-all.sh
```

For normal build, run, and test work, use the Apple Dev Skills Xcode workflows named in `AGENTS.md`.
