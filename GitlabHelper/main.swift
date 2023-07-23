import Foundation

func run() async throws {
    let config = try readConfig()
    let sourceBranchName = try getSourceBranchName()
    let targetBranchName = getTargetBranchName()
    let taskNumber = getTaskNumber(from: sourceBranchName)
    
    var taskTitle: String?
    if let config = config.jira, let taskNumber = taskNumber {
        taskTitle = try? await JiraAPI(config: config).getTaskTitle(taskNumber: taskNumber)
    }
    
    let mrTitle = makeMRTitle(with: taskNumber, taskTitle: taskTitle)
    
    try await GitlabAPI(config: config.gitlab)
        .createMergeRequest(
            with: sourceBranchName,
            targetBranch: targetBranchName,
            title: mrTitle
        )
}

func readConfig() throws -> Config {
    guard CommandLine.arguments.count > 0 else {
        throw "Didn't find executable url"
    }
    
    let executableURL = URL(filePath: CommandLine.arguments[0])
    let folderURL = executableURL.deletingLastPathComponent()
    let configURL = folderURL.appending(path: "config.json")
    let jsonData = try Data(contentsOf: configURL)
    
    return try JSONDecoder().decode(Config.self, from: jsonData)
}

func getSourceBranchName() throws -> String {
    // Create a Pipe for capturing the command output
    let pipe = Pipe()
    
    // Create a Process for executing the git command
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["git", "rev-parse", "--abbrev-ref", "HEAD"]
    process.standardOutput = pipe
    
    // Launch the process
    try process.run()
    
    // Read the command output
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .newlines)
    
    // Wait until the process finishes
    process.waitUntilExit()
    
    // Check the exit status
    if process.terminationStatus != 0 {
        throw "Process termination status: \(Int(process.terminationStatus))"
    }
    
    if let output {
        return output
    } else {
        throw "Can't parse current branch name"
    }
}

func getTargetBranchName() -> String {
    var targetBranchName = "develop"
    let arguments = CommandLine.arguments
    
    if arguments.count > 1 {
        targetBranchName = arguments[1]
    }
    
    return targetBranchName
}

func getTaskNumber(from branchName: String) -> String? {
    let pattern = #"MB-\d+"#
    guard let range = branchName.range(of: pattern, options: .regularExpression) else {
        return nil
    }
    
    return String(branchName[range])
}

func makeMRTitle(with taskNumber: String?, taskTitle: String?) -> String {
    guard let taskNumber else {
        return "Title"
    }
    guard let taskTitle else {
        return taskNumber
    }
    
    let processedTitle = taskTitle.replacingOccurrences(
        of: #"^\[iOS\]\s*"#,
        with: "",
        options: .regularExpression
    )
    
    return "\(taskNumber): \(processedTitle)"
}

Task {
    do {
        try await run()
        exit(EXIT_SUCCESS)
    } catch {
        exit(EXIT_FAILURE)
    }
}

RunLoop.current.run()
