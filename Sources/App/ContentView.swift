import SwiftUI

struct ContentView: View {
    private let plannedCapabilities = [
        "Install and refresh the Socket marketplace",
        "Host a stable local desktop bridge service",
        "Expose status for Accessibility and automation permissions",
        "Serve Socket MCP adapters over a local transport"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            VStack(alignment: .leading, spacing: 12) {
                ForEach(plannedCapabilities, id: \.self) { capability in
                    Label(capability, systemImage: "checkmark.circle")
                        .labelStyle(.titleAndIcon)
                }
            }
            .font(.callout)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Runtime Status")
                    .font(.headline)

                StatusRow(title: "Socket marketplace", value: "Not connected")
                StatusRow(title: "Desktop bridge", value: "Not running")
                StatusRow(title: "Accessibility permission", value: "Not requested")
            }
        }
        .padding(28)
        .frame(minWidth: 520, minHeight: 360)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Utilities for Codex")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text("A stable macOS companion app for Socket-backed Codex utilities.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

private struct StatusRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.body)
        .padding(.vertical, 4)
    }
}
