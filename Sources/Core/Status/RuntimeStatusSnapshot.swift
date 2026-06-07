import Foundation

struct RuntimeStatusSnapshot: Equatable {
    let socketMarketplace: StatusItem
    let desktopBridge: StatusItem
    let accessibilityPermission: StatusItem
    let screenCapturePermission: StatusItem
    let agentTargets: [AgentTargetSnapshot]

    static let loading = RuntimeStatusSnapshot(
        socketMarketplace: StatusItem(
            id: "socket-marketplace",
            title: "Socket marketplace",
            value: "Checking",
            tone: .neutral
        ),
        desktopBridge: StatusItem(
            id: "desktop-bridge",
            title: "Desktop bridge",
            value: "Checking",
            tone: .neutral
        ),
        accessibilityPermission: StatusItem(
            id: "accessibility-permission",
            title: "Accessibility permission",
            value: "Checking",
            tone: .neutral
        ),
        screenCapturePermission: StatusItem(
            id: "screen-capture-permission",
            title: "Screen Capture permission",
            value: "Checking",
            tone: .neutral
        ),
        agentTargets: []
    )
}
