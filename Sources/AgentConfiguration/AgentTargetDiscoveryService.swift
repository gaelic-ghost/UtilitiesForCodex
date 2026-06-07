import Foundation

struct AgentTargetDiscoveryService {
    private let fileManager: FileManager
    private let processRunner: ProcessRunning
    private let homeDirectory: URL
    private let targetDescriptors: [AgentTargetDescriptor]?

    init(
        fileManager: FileManager = .default,
        processRunner: ProcessRunning = SystemProcessRunner(),
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser,
        targetDescriptors: [AgentTargetDescriptor]? = nil
    ) {
        self.fileManager = fileManager
        self.processRunner = processRunner
        self.homeDirectory = homeDirectory
        self.targetDescriptors = targetDescriptors
    }

    func discoverTargets() -> [AgentTargetSnapshot] {
        descriptors().map(snapshot(for:))
    }

    private func descriptors() -> [AgentTargetDescriptor] {
        if let targetDescriptors {
            return targetDescriptors
        }

        return [
            AgentTargetDescriptor(
                kind: .codexCLI,
                homeDirectory: homeDirectory.appendingPathComponent(".codex"),
                configFile: homeDirectory.appendingPathComponent(".codex/config.toml"),
                guidanceFile: homeDirectory.appendingPathComponent(".codex/AGENTS.md"),
                versionProbe: codexCLIVersionProbe()
            ),
            AgentTargetDescriptor(
                kind: .xcodeCodex,
                homeDirectory: homeDirectory.appendingPathComponent("Library/Developer/Xcode/CodingAssistant/codex"),
                configFile: homeDirectory.appendingPathComponent("Library/Developer/Xcode/CodingAssistant/codex/config.toml"),
                guidanceFile: homeDirectory.appendingPathComponent("Library/Developer/Xcode/CodingAssistant/codex/AGENTS.md"),
                versionProbe: xcodeCodexVersionProbe()
            ),
            AgentTargetDescriptor(
                kind: .xcodeClaude,
                homeDirectory: homeDirectory.appendingPathComponent("Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig"),
                configFile: nil,
                guidanceFile: nil,
                versionProbe: nil
            )
        ]
    }

    private func snapshot(for descriptor: AgentTargetDescriptor) -> AgentTargetSnapshot {
        let availability = availability(for: descriptor.homeDirectory)

        guard availability == .available else {
            return AgentTargetSnapshot(
                descriptor: descriptor,
                availability: availability,
                version: nil,
                diagnostic: missingOrUnreadableDiagnostic(for: descriptor, availability: availability)
            )
        }

        let version = descriptor.versionProbe.flatMap(versionString)
        let diagnostic = availableDiagnostic(for: descriptor, version: version)

        return AgentTargetSnapshot(
            descriptor: descriptor,
            availability: availability,
            version: version,
            diagnostic: diagnostic
        )
    }

    private func availability(for directory: URL) -> AgentTargetSnapshot.Availability {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            return .missing
        }

        guard fileManager.isReadableFile(atPath: directory.path) else {
            return .unreadable
        }

        return .available
    }

    private func versionString(from probe: VersionProbe) -> String? {
        guard let result = try? processRunner.run(executableURL: probe.executableURL, arguments: probe.arguments),
              result.exitCode == 0
        else {
            return nil
        }

        let output = result.trimmedOutput
        return output.isEmpty ? nil : output
    }

    private func availableDiagnostic(for descriptor: AgentTargetDescriptor, version: String?) -> DiagnosticMessage {
        if let version {
            return .ok(
                "\(descriptor.kind.displayName) is available.",
                detail: "Detected version: \(version)."
            )
        }

        if descriptor.versionProbe == nil {
            return .notice(
                "\(descriptor.kind.displayName) is available.",
                detail: "No version probe is configured for this target yet."
            )
        }

        return .warning(
            "\(descriptor.kind.displayName) is available, but its version could not be checked.",
            detail: "The target home exists, but the configured version probe did not return a usable version string."
        )
    }

    private func missingOrUnreadableDiagnostic(
        for descriptor: AgentTargetDescriptor,
        availability: AgentTargetSnapshot.Availability
    ) -> DiagnosticMessage {
        switch availability {
        case .available:
            return .ok("\(descriptor.kind.displayName) is available.")
        case .missing:
            return .notice(
                "\(descriptor.kind.displayName) was not found.",
                detail: "Expected a configuration home at \(descriptor.homeDirectory.path)."
            )
        case .unreadable:
            return .blocked(
                "\(descriptor.kind.displayName) cannot be inspected.",
                detail: "The configuration home exists but is not readable at \(descriptor.homeDirectory.path)."
            )
        }
    }

    private func codexCLIVersionProbe() -> VersionProbe? {
        [
            "/opt/homebrew/bin/codex",
            "/usr/local/bin/codex"
        ]
        .map(URL.init(fileURLWithPath:))
        .first { fileManager.isExecutableFile(atPath: $0.path) }
        .map { VersionProbe(executableURL: $0, arguments: ["--version"]) }
    }

    private func xcodeCodexVersionProbe() -> VersionProbe? {
        let agentsDirectory = homeDirectory.appendingPathComponent("Library/Developer/Xcode/CodingAssistant/Agents/codex")

        guard let entries = try? fileManager.contentsOfDirectory(
            at: agentsDirectory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        return entries
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedDescending }
            .map { $0.appendingPathComponent("codex") }
            .first { fileManager.isExecutableFile(atPath: $0.path) }
            .map { VersionProbe(executableURL: $0, arguments: ["--version"]) }
    }
}
