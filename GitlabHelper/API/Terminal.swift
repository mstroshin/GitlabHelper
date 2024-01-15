import Foundation

final class Terminal {
    
    static func execute(cmd: String) throws -> String {
        let arguments = cmd.split(separator: " ").map(String.init)
        
        // Create a Pipe for capturing the command output
        let pipe = Pipe()
        
        // Create a Process for executing the git command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments
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
            throw "Terminal error: processing termination status: \(Int(process.terminationStatus))"
        }
        
        if let output {
            return output
        } else {
            throw "Terminal error: output is nil"
        }
    }
    
    static func openInBrowser(url: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = [url]
        try process.run()
    }
    
}
