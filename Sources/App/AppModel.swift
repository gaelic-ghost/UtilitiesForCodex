import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var statusSnapshot: RuntimeStatusSnapshot = .loading

    private let statusProvider: RuntimeStatusProvider

    init(statusProvider: RuntimeStatusProvider = RuntimeStatusProvider()) {
        self.statusProvider = statusProvider
    }

    func refresh() {
        statusSnapshot = statusProvider.snapshot()
    }
}
