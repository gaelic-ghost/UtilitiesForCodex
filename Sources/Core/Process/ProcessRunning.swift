import Foundation

struct ProcessRunResult: Equatable {
    let exitCode: Int32
    let standardOutput: String
    let standardError: String

    var trimmedOutput: String {
        let output = standardOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        if output.isEmpty {
            return standardError.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return output
    }
}

protocol ProcessRunning {
    func run(executableURL: URL, arguments: [String]) throws -> ProcessRunResult
}

enum ProcessRunError: Error, Equatable, LocalizedError {
    case missingExecutable(String)

    var errorDescription: String? {
        switch self {
        case let .missingExecutable(path):
            return "The executable at \(path) is missing or is not runnable."
        }
    }
}

struct SystemProcessRunner: ProcessRunning {
    func run(executableURL: URL, arguments: [String]) throws -> ProcessRunResult {
        guard FileManager.default.isExecutableFile(atPath: executableURL.path) else {
            throw ProcessRunError.missingExecutable(executableURL.path)
        }

        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let error = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        return ProcessRunResult(
            exitCode: process.terminationStatus,
            standardOutput: output,
            standardError: error
        )
    }
}
