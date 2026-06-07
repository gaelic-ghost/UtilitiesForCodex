import Foundation

struct StatusItem: Identifiable, Equatable {
    enum Tone: String, Equatable {
        case ready
        case neutral
        case warning
        case blocked
    }

    let id: String
    let title: String
    let value: String
    let detail: String?
    let tone: Tone

    init(
        id: String,
        title: String,
        value: String,
        detail: String? = nil,
        tone: Tone
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.detail = detail
        self.tone = tone
    }
}
