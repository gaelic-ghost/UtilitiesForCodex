import SwiftUI

@main
struct UtilitiesForCodex: App {
    var body: some Scene {
        WindowGroup("Utilities for Codex") {
            ContentView()
        }

        MenuBarExtra("Utilities for Codex", systemImage: "bolt.horizontal.circle") {
            Button("Open Utilities for Codex") {
                NSApp.activate(ignoringOtherApps: true)
            }

            Divider()

            Text("Desktop bridge: planned")
            Text("Socket installer: planned")
        }
    }
}
