# Utilities for Codex Roadmap

This roadmap summarizes the active plans in `docs/plans/desktop-bridge-plan.md` and `docs/plans/agent-configuration-sync-plan.md`.

## Current Direction

Utilities for Codex is a stable macOS companion app for Codex-connected utilities that need an installed app identity, local helper surface, permission flow, or long-lived runtime boundary.

The first two planned capability tracks are:

- Desktop bridge: a local app-owned runtime for guarded desktop automation used by Socket's `codex-utilities` plugin.
- Agent configuration sync: a local inventory, diff, and safe-sync surface for Codex CLI, Xcode Codex, Xcode Claude, and future agent hosts.

The shared product principle is: stable app-owned runtime, lightweight plugin adapter.

## Recommended Next Slice

Start with a read-only inventory and status core.

This is the smallest durable building-block change that helps both plans:

- Desktop bridge needs app reachability, permission state, service status, and human-readable diagnostics before action tools exist.
- Agent configuration sync needs target discovery, version reporting, config-home paths, compatibility labels, and dry-run output before writes exist.
- The current SwiftUI shell already has planned status rows, so the first useful implementation can replace placeholder strings with real model state without committing to a helper process or UI automation contract yet.

## Architecture Shape

Keep the app simple and feature-oriented:

- `Sources/App`: SwiftUI app entry point, scene composition, and view wiring.
- `Sources/Core`: small shared value types, diagnostics, path handling, process execution, and file-reading utilities.
- `Sources/AgentConfiguration`: target discovery, config parsing, compatibility profiles, diff previews, backups, and apply planning.
- `Sources/DesktopBridge`: permission state, bridge health, transport status, and later guarded UI action service boundaries.
- `Sources/SocketMarketplace`: Socket marketplace detection, install or upgrade command planning, and operator-readable command logs.

This is a durable building-block change, not a stopgap. The practical effect is that views can render real app state while writes, service hosting, and automation actions remain behind explicit model and service boundaries.

## Persistence Direction

Use Core Data for app persistence once the app has state worth saving.

Initial persistence use cases are expected to be backup records, sync history, target-specific compatibility decisions, user-approved apply plans, service logs, and allowlist or denylist settings. Until one of those exists, keep read-only discovery and status state in memory so the app does not carry idle persistence code.

## First Implementation Milestones

1. App state model
   - Add typed status values for Socket marketplace, desktop bridge, Accessibility, Screen Capture, and agent target discovery.
   - Replace placeholder `ContentView` strings with a read-only state object.
   - Add tests for status display mapping and diagnostic wording.

2. Agent target discovery
   - Detect Codex CLI, Xcode Codex, and Xcode Claude homes without writing anything.
   - Parse version output where a binary is available.
   - Return explicit states such as `available`, `missing`, `unreadable`, and `unsupported`.

3. Config dry-run preview
   - Parse selected TOML config files with a real parser.
   - Render a compatibility report with allowed, omitted, unknown, and high-risk keys.
   - Keep writes blocked until backup and validation behavior is tested.

4. Desktop bridge status skeleton
   - Add bridge reachability and permission-state reporting.
   - Choose the first transport experiment, likely a Unix domain socket plus a lightweight CLI or MCP shim.
   - Do not add UI action tools until read-only app-state capture and permission diagnostics are proven.

5. Safe apply and service hosting
   - Add timestamped backups before config writes.
   - Add explicit apply controls and readable operation logs.
   - Add a service emergency stop before guarded desktop actions ship.

## Open Decisions

- Whether the first shippable feature should be agent configuration inventory or desktop bridge health.
- Whether the desktop bridge starts with Unix domain sockets only or includes a CLI shim immediately.
- Whether Socket install and upgrade should be command-copy guidance first or app-executed commands with logs.
- Whether app distribution starts as a signed direct download, Homebrew cask, or both.
- Whether a login item or helper is needed before the bridge has real background-service requirements.

## Guardrails

- Default to read-only and dry-run behavior.
- Never sync credentials, plugin caches, session history, browser state, or temporary host-owned folders.
- Never silently widen sandbox, network, approval, Accessibility, Screen Capture, or automation behavior.
- Keep agent-facing MCP tools in Socket; keep the trusted macOS runtime in this app.
- Keep operator-facing diagnostics specific enough to explain what broke, where it broke, and the most likely fix.
