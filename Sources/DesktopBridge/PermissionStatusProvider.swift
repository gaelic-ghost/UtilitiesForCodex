import ApplicationServices
import Foundation

struct PermissionStatusProvider {
    func accessibilityStatus() -> StatusItem {
        if AXIsProcessTrusted() {
            return StatusItem(
                id: "accessibility-permission",
                title: "Accessibility permission",
                value: "Granted",
                detail: "macOS Accessibility trust is available for this app process.",
                tone: .ready
            )
        }

        return StatusItem(
            id: "accessibility-permission",
            title: "Accessibility permission",
            value: "Not granted",
            detail: "Desktop automation actions will stay blocked until macOS Accessibility permission is granted.",
            tone: .warning
        )
    }

    func screenCaptureStatus() -> StatusItem {
        StatusItem(
            id: "screen-capture-permission",
            title: "Screen Capture permission",
            value: "Not checked",
            detail: "Screen Capture probing is deferred until screenshot capture is implemented.",
            tone: .neutral
        )
    }
}
