import SwiftUI

struct ContentView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            statusSection
            targetSection

            HStack {
                Spacer()
                Button("Refresh") {
                    model.refresh()
                }
            }
        }
        .padding(28)
        .frame(minWidth: 640, minHeight: 460)
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

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Runtime Status")
                .font(.headline)

            VStack(spacing: 1) {
                StatusRow(item: model.statusSnapshot.socketMarketplace)
                StatusRow(item: model.statusSnapshot.desktopBridge)
                StatusRow(item: model.statusSnapshot.accessibilityPermission)
                StatusRow(item: model.statusSnapshot.screenCapturePermission)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Agent Targets")
                .font(.headline)

            VStack(spacing: 1) {
                if model.statusSnapshot.agentTargets.isEmpty {
                    StatusRow(
                        item: StatusItem(
                            id: "agent-targets-empty",
                            title: "Target inventory",
                            value: "Checking",
                            detail: "Agent target discovery has not run yet.",
                            tone: .neutral
                        )
                    )
                } else {
                    ForEach(model.statusSnapshot.agentTargets) { target in
                        AgentTargetRow(snapshot: target)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct StatusRow: View {
    let item: StatusItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            StatusToneView(tone: item.tone)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.title)
                        .fontWeight(.medium)

                    Spacer(minLength: 16)

                    Text(item.value)
                        .foregroundStyle(.secondary)
                }

                if let detail = item.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .font(.body)
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

private struct AgentTargetRow: View {
    let snapshot: AgentTargetSnapshot

    var body: some View {
        StatusRow(
            item: StatusItem(
                id: snapshot.id,
                title: snapshot.descriptor.kind.displayName,
                value: value,
                detail: snapshot.diagnostic.detail,
                tone: tone
            )
        )
    }

    private var value: String {
        switch snapshot.availability {
        case .available:
            return snapshot.version ?? "Available"
        case .missing:
            return "Missing"
        case .unreadable:
            return "Unreadable"
        }
    }

    private var tone: StatusItem.Tone {
        switch snapshot.diagnostic.severity {
        case .ok:
            return .ready
        case .notice:
            return .neutral
        case .warning:
            return .warning
        case .blocked:
            return .blocked
        }
    }
}

private struct StatusToneView: View {
    let tone: StatusItem.Tone

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .padding(.top, 5)
    }

    private var color: Color {
        switch tone {
        case .ready:
            return .green
        case .neutral:
            return .blue
        case .warning:
            return .yellow
        case .blocked:
            return .red
        }
    }
}
