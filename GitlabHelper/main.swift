import Foundation

func run() async throws {
    let config = try readConfig()
    let sourceBranchName = try Terminal.execute(cmd: "git rev-parse --abbrev-ref HEAD")
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

func getCommitsTitles(for taskNumber: String) throws -> [String] {
    let commitsTitles = try Terminal.execute(cmd: "git log --oneline --format=%s --max-count=50")
    
    return commitsTitles
        .split(separator: "\n")
        .filter {
            $0.hasPrefix(taskNumber)
        }
        .map {
            $0.replacingOccurrences(of: #"MB-\d+:"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        .reversed()
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
