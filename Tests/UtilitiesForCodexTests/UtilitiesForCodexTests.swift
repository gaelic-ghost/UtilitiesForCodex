import XCTest
@testable import UtilitiesForCodex

final class UtilitiesForCodexTests: XCTestCase {
    func testRuntimeStatusLoadingSnapshotUsesCheckingValues() {
        let snapshot = RuntimeStatusSnapshot.loading

        XCTAssertEqual(snapshot.socketMarketplace.value, "Checking")
        XCTAssertEqual(snapshot.desktopBridge.value, "Checking")
        XCTAssertEqual(snapshot.accessibilityPermission.value, "Checking")
        XCTAssertEqual(snapshot.screenCapturePermission.value, "Checking")
        XCTAssertTrue(snapshot.agentTargets.isEmpty)
    }

    func testAgentTargetDiscoveryReportsMissingTargetWithReadableDiagnostic() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }

        let descriptor = AgentTargetDescriptor(
            kind: .codexCLI,
            homeDirectory: root.appendingPathComponent(".codex"),
            configFile: nil,
            guidanceFile: nil,
            versionProbe: nil
        )
        let discovery = AgentTargetDiscoveryService(
            processRunner: StubProcessRunner(result: .success(ProcessRunResult(exitCode: 0, standardOutput: "", standardError: ""))),
            homeDirectory: root,
            targetDescriptors: [descriptor]
        )

        let target = try XCTUnwrap(discovery.discoverTargets().first)

        XCTAssertEqual(target.availability, .missing)
        XCTAssertEqual(target.diagnostic.severity, .notice)
        XCTAssertEqual(target.diagnostic.summary, "Codex CLI was not found.")
        XCTAssertTrue(target.diagnostic.detail?.contains(root.path) == true)
    }

    func testAgentTargetDiscoveryReportsVersionWhenProbeSucceeds() throws {
        let root = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let codexHome = root.appendingPathComponent(".codex")
        try FileManager.default.createDirectory(at: codexHome, withIntermediateDirectories: true)

        let descriptor = AgentTargetDescriptor(
            kind: .codexCLI,
            homeDirectory: codexHome,
            configFile: codexHome.appendingPathComponent("config.toml"),
            guidanceFile: codexHome.appendingPathComponent("AGENTS.md"),
            versionProbe: VersionProbe(executableURL: URL(fileURLWithPath: "/tmp/codex"), arguments: ["--version"])
        )
        let discovery = AgentTargetDiscoveryService(
            processRunner: StubProcessRunner(result: .success(ProcessRunResult(exitCode: 0, standardOutput: "codex-cli 0.137.0\n", standardError: ""))),
            homeDirectory: root,
            targetDescriptors: [descriptor]
        )

        let target = try XCTUnwrap(discovery.discoverTargets().first)

        XCTAssertEqual(target.availability, .available)
        XCTAssertEqual(target.version, "codex-cli 0.137.0")
        XCTAssertEqual(target.diagnostic.severity, .ok)
        XCTAssertEqual(target.diagnostic.detail, "Detected version: codex-cli 0.137.0.")
    }

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("UtilitiesForCodexTests")
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

private struct StubProcessRunner: ProcessRunning {
    let result: Result<ProcessRunResult, Error>

    func run(executableURL: URL, arguments: [String]) throws -> ProcessRunResult {
        try result.get()
    }
}
