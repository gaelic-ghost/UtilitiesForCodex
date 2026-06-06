import Foundation

struct RuntimeStatusProvider {
    private let socketMarketplaceStatusProvider: SocketMarketplaceStatusProvider
    private let desktopBridgeStatusProvider: DesktopBridgeStatusProvider
    private let permissionStatusProvider: PermissionStatusProvider
    private let agentTargetDiscoveryService: AgentTargetDiscoveryService

    init(
        socketMarketplaceStatusProvider: SocketMarketplaceStatusProvider = SocketMarketplaceStatusProvider(),
        desktopBridgeStatusProvider: DesktopBridgeStatusProvider = DesktopBridgeStatusProvider(),
        permissionStatusProvider: PermissionStatusProvider = PermissionStatusProvider(),
        agentTargetDiscoveryService: AgentTargetDiscoveryService = AgentTargetDiscoveryService()
    ) {
        self.socketMarketplaceStatusProvider = socketMarketplaceStatusProvider
        self.desktopBridgeStatusProvider = desktopBridgeStatusProvider
        self.permissionStatusProvider = permissionStatusProvider
        self.agentTargetDiscoveryService = agentTargetDiscoveryService
    }

    func snapshot() -> RuntimeStatusSnapshot {
        RuntimeStatusSnapshot(
            socketMarketplace: socketMarketplaceStatusProvider.status(),
            desktopBridge: desktopBridgeStatusProvider.status(),
            accessibilityPermission: permissionStatusProvider.accessibilityStatus(),
            screenCapturePermission: permissionStatusProvider.screenCaptureStatus(),
            agentTargets: agentTargetDiscoveryService.discoverTargets()
        )
    }
}
