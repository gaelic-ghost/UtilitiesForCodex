# Utilities for Codex Desktop Bridge Plan

## Summary

Utilities for Codex is a stable macOS companion app for Codex utility workflows that need a real installed app identity. Its first planned runtime is a desktop automation bridge used by Socket's `codex-utilities` plugin.

The core split is deliberate:

- Utilities for Codex owns the macOS app, signing identity, permission prompts, local service runtime, and transport endpoint.
- Socket's `codex-utilities` plugin owns the agent-facing MCP tools, skills, metadata, and confirmation policy.
- Future SwiftASB or custom GUI work can become a richer control surface on top of the same stable runtime.

This avoids packaging a signed macOS automation app as a relocatable hot-swappable Codex plugin asset.

## Problem

Codex's first-party Computer Use plugin exposes a useful agent interface, but its macOS app packaging model appears fragile. Local inspection showed a full app bundle staged inside the Codex plugin cache and a second copy inside a temporary bundled marketplace tree.

That shape is risky for a desktop automation runtime because macOS trust surfaces are sensitive to process identity, code signing, notarization, Accessibility/TCC state, nested helper integrity, and sometimes path/provenance assessment.

A plugin cache is a reasonable home for skills, descriptors, scripts, and simple command-line tools. It is a poor home for the stable macOS-trusted automation runtime itself.

## Product Direction

The working product name is `Utilities for Codex`.

The app should be a small macOS menu bar or background app that can:

- Install or refresh the Socket marketplace in the user's Codex environment.
- Show the installed Socket and utility-service status.
- Own Accessibility and automation permission prompts.
- Host local services for Socket utilities.
- Expose clear logs and diagnostic status for local failures.

The app should stay useful even when Codex is not running. Codex plugins should be clients of the app, not owners of the app's trusted runtime.

## Architecture Classification

The stable macOS app is a durable building-block change. It defines the long-lived local trust identity and runtime boundary.

The Socket `codex-utilities` MCP server is an agent-facing adapter. It should be easy to update, replace, or extend without moving the macOS-trusted runtime.

The first desktop bridge implementation is allowed to be narrow, but it should not be a conscious stopgap that bakes in path churn, duplicate app copies, or plugin-cache ownership of the app bundle.

## Initial Repository Shape

This repository starts as:

- Native macOS app.
- SwiftUI-first shell.
- XcodeGen-backed project.
- External `.xcconfig` files for nontrivial build settings.
- Repo-maintenance baseline installed through the Socket Apple Dev Skills bootstrap workflow.

The generated project follows Apple's SwiftUI app model: an `App` entry point creates scenes, starting with a `WindowGroup`. The initial shell also exposes a `MenuBarExtra` so future runtime status can be reached without opening the main window first.

## Runtime Responsibilities

Utilities for Codex should eventually own:

- Stable bundle identifier and signing identity.
- Accessibility trust checks and permission prompts.
- Automation permission guidance where needed.
- Runtime process supervision for local utility services.
- Local transport endpoints.
- Version reporting and health checks.
- User-readable diagnostics for service failures.
- Install and update flows for the Socket marketplace.

It should not own:

- Agent prompt wording.
- Codex plugin metadata.
- Marketplace child-plugin packaging.
- The agent's confirmation policy.
- Codex-specific tool descriptions beyond local service capabilities.

## Socket Plugin Responsibilities

The `codex-utilities` plugin inside Socket should eventually own:

- A `computer-use`-shaped MCP tool surface for the desktop bridge.
- A skill that tells agents when to use the bridge.
- A confirmation policy for risky UI actions.
- Install and troubleshooting guidance for the Utilities for Codex app.
- A runtime health check that reports whether the app is installed and reachable.

The plugin should not bundle the app itself. If the app is missing, the plugin should return a clear diagnostic and point the user to install Utilities for Codex.

## Agent Interface Target

The first agent-facing interface should intentionally resemble the useful part of first-party Computer Use:

- `get_app_state(app)`: return app identity, focused window, compact Accessibility tree, focused element, and screenshot metadata.
- `click(app, element_index | x/y)`: click an indexed element or coordinates.
- `type_text(app, text)`: type literal text.
- `set_value(app, element_index, value)`: set a value through Accessibility when available.
- `select_text(app, element_index, text, prefix, suffix, selection)`: select or place the cursor around text.
- `perform_secondary_action(app, element_index, action)`: invoke named secondary Accessibility actions.
- `get_bridge_status()`: report app reachability, permission state, runtime version, and transport endpoint state.

The matching shape matters because agents already receive training and runtime guidance around small, explicit UI-action tools. Matching that surface lets Socket benefit from the same learned interaction pattern without copying the fragile packaging model.

## Transport Direction

Unix domain sockets are the preferred first transport to evaluate.

Reasons:

- They are local-only by construction.
- They avoid opening a TCP listener.
- They can live under a user-scoped runtime directory.
- They fit request/response MCP-style communication.
- They support a stable app-owned service endpoint while plugin code remains lightweight.

Open questions:

- Whether Codex plugin MCP command execution can reliably access the user's socket path across sandbox and launch contexts.
- Whether a small CLI shim should bridge stdio MCP to the Unix socket service.
- Whether XPC should replace or complement Unix sockets once the app and helper split becomes clearer.
- Whether a localhost fallback is useful for diagnostics or third-party integrations.

The likely first implementation is a lightweight MCP stdio shim inside Socket that speaks JSON-RPC to the app over a Unix domain socket.

## macOS Permission Model

The app should make permission state explicit before any UI action tool is used:

- Accessibility permission: needed for reading and acting on Accessibility elements.
- Screen capture permission: likely needed for screenshots on modern macOS.
- Automation permissions: may be needed for Apple Events or app-specific automation.

The bridge should fail closed when permission is missing and return a descriptive diagnostic that names the missing permission and the app surface where the user can grant it.

The bridge should not attempt to silently bypass macOS permission prompts.

## Install and Update Model

Utilities for Codex should install Socket using the documented marketplace command path:

```bash
codex plugin marketplace add gaelic-ghost/socket
```

For updates, it can drive or explain:

```bash
codex plugin marketplace upgrade socket
```

The app can later offer a GUI action for these operations, but early versions can simply expose status and copyable commands. Any command execution path should be explicit, logged, and reversible where practical.

## Security and Safety Rules

The runtime must keep logs human-readable and avoid storing sensitive UI content by default.

The plugin skill should require action-time confirmation for:

- Deleting data through a UI.
- Submitting forms or messages to third parties.
- Changing local security, privacy, or system settings.
- Installing or running newly acquired software through UI automation.
- Transmitting sensitive data into any third-party app or website.

The app should expose an emergency stop control that prevents further bridge actions until the user re-enables them.

## Implementation Slices

### Slice 1: App Baseline

- Bootstrap macOS SwiftUI app with XcodeGen.
- Keep nontrivial build settings in external `.xcconfig` files.
- Add menu bar starter shell and status UI.
- Publish public GitHub repository.

### Slice 2: Socket Planning

- Add a Socket `codex-utilities` planning document for the MCP and skill.
- Add roadmap items that keep the app runtime separate from the Socket plugin adapter.
- Keep plugin packaging lightweight and app-free.

### Slice 3: Local Service Skeleton

- Add an app-owned local service boundary.
- Add a health endpoint.
- Add version and permission-state reporting.
- Decide whether the first transport is Unix domain socket only or Unix socket plus CLI shim.

### Slice 4: MCP Adapter

- Add a small MCP server under Socket's `codex-utilities` plugin.
- Implement `get_bridge_status()` first.
- Return clear diagnostics when Utilities for Codex is not installed or not running.

### Slice 5: Read-Only App State

- Implement read-only app-state capture.
- Return compact Accessibility tree text and screenshot metadata.
- Avoid action tools until permission and safety policy are proven.

### Slice 6: Guarded UI Actions

- Add click, type, set-value, text selection, and secondary action tools.
- Enforce action confirmation policy in the skill.
- Add integration tests or manual verification notes for Finder and one non-Apple app.

### Slice 7: Socket Installer UX

- Detect Codex CLI availability.
- Detect whether Socket marketplace is configured.
- Offer guided install and upgrade actions.
- Keep command logs readable and specific.

## Open Questions

- Should the app be distributed as a signed direct download, a Homebrew cask, or both?
- Should the service launch only while the app is open, or should it use a login item/helper later?
- Should the first bridge avoid `SMAppService` until a helper is genuinely needed?
- Which screenshot representation should the MCP return to agents without leaking unnecessary local context?
- How should the app expose per-app allowlists or denylists?
- Should Socket include a placeholder MCP server first, or wait until the app service skeleton exists?

## Current Decision

Start with the stable standalone macOS app plus Socket plugin adapter.

Do not make SwiftASB own the low-level macOS trust boundary yet. SwiftASB or a future GUI can become a richer client once the stable runtime and MCP adapter are proven.
