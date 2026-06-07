import Foundation

struct DiagnosticMessage: Equatable {
    enum Severity: String, Equatable {
        case ok
        case notice
        case warning
        case blocked
    }

    let severity: Severity
    let summary: String
    let detail: String?

    static func ok(_ summary: String, detail: String? = nil) -> DiagnosticMessage {
        DiagnosticMessage(severity: .ok, summary: summary, detail: detail)
    }

    static func notice(_ summary: String, detail: String? = nil) -> DiagnosticMessage {
        DiagnosticMessage(severity: .notice, summary: summary, detail: detail)
    }

    static func warning(_ summary: String, detail: String? = nil) -> DiagnosticMessage {
        DiagnosticMessage(severity: .warning, summary: summary, detail: detail)
    }

    static func blocked(_ summary: String, detail: String? = nil) -> DiagnosticMessage {
        DiagnosticMessage(severity: .blocked, summary: summary, detail: detail)
    }
}
