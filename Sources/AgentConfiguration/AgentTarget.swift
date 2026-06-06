import Foundation

enum AgentTargetKind: String, CaseIterable, Equatable {
    case codexCLI
    case xcodeCodex
    case xcodeClaude

    var displayName: String {
        switch self {
        case .codexCLI:
            return "Codex CLI"
        case .xcodeCodex:
            return "Xcode Codex"
        case .xcodeClaude:
            return "Xcode Claude"
        }
    }
}

struct AgentTargetDescriptor: Equatable {
    let kind: AgentTargetKind
    let homeDirectory: URL
    let configFile: URL?
    let guidanceFile: URL?
    let versionProbe: VersionProbe?
}

struct VersionProbe: Equatable {
    let executableURL: URL
    let arguments: [String]
}

struct AgentTargetSnapshot: Identifiable, Equatable {
    enum Availability: String, Equatable {
        case available
        case missing
        case unreadable
    }

    var id: String { descriptor.kind.rawValue }

    let descriptor: AgentTargetDescriptor
    let availability: Availability
    let version: String?
    let diagnostic: DiagnosticMessage
}
