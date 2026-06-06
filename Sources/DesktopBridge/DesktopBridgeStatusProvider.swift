import Foundation

struct DesktopBridgeStatusProvider {
    func status() -> StatusItem {
        StatusItem(
            id: "desktop-bridge",
            title: "Desktop bridge",
            value: "Not running",
            detail: "The local bridge service has not been implemented yet.",
            tone: .neutral
        )
    }
}
