import SwiftUI

@main
struct UtilitiesForCodex: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup("Utilities for Codex") {
            ContentView(model: appModel)
                .onAppear {
                    appModel.refresh()
                }
        }

        MenuBarExtra("Utilities for Codex", systemImage: "bolt.horizontal.circle") {
            Button("Open Utilities for Codex") {
                NSApp.activate(ignoringOtherApps: true)
            }

            Button("Refresh Status") {
                appModel.refresh()
            }

            Divider()

            MenuStatusRow(item: appModel.statusSnapshot.socketMarketplace)
            MenuStatusRow(item: appModel.statusSnapshot.desktopBridge)
            MenuStatusRow(item: appModel.statusSnapshot.accessibilityPermission)
        }
    }
}

private struct MenuStatusRow: View {
    let item: StatusItem

    var body: some View {
        Text("\(item.title): \(item.value)")
    }
}
