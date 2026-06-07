import Foundation

struct SocketMarketplaceStatusProvider {
    private let fileManager: FileManager
    private let homeDirectory: URL

    init(
        fileManager: FileManager = .default,
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
    ) {
        self.fileManager = fileManager
        self.homeDirectory = homeDirectory
    }

    func status() -> StatusItem {
        let codexHome = homeDirectory.appendingPathComponent(".codex")

        guard fileManager.fileExists(atPath: codexHome.path) else {
            return StatusItem(
                id: "socket-marketplace",
                title: "Socket marketplace",
                value: "Codex home missing",
                detail: "Expected Codex configuration at \(codexHome.path) before checking Socket marketplace state.",
                tone: .warning
            )
        }

        return StatusItem(
            id: "socket-marketplace",
            title: "Socket marketplace",
            value: "Codex home found",
            detail: "Socket marketplace detection is planned after target inventory is in place.",
            tone: .neutral
        )
    }
}
