import Foundation

class FolderDetector {
    static func detectSystemFolder() -> String {
        print("📁 FolderDetector: Starting detection...")
        
        // 1. Try using defaults command to get actual system setting
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["read", "com.apple.screencapture", "location"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if var output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    // Expand tilde to full path
                    if output.hasPrefix("~") {
                        output = NSString(string: output).expandingTildeInPath
                    }
                    
                    // Verify folder exists
                    var isDirectory: ObjCBool = false
                    if FileManager.default.fileExists(atPath: output, isDirectory: &isDirectory) && isDirectory.boolValue {
                        print("✅ Detected folder: \(output)")
                        return output
                    } else {
                        print("⚠️ Path exists but is not a directory: \(output)")
                    }
                } else {
                    print("⚠️ No output from defaults command")
                }
            } else {
                print("⚠️ defaults command failed with status: \(task.terminationStatus)")
            }
        } catch {
            print("❌ Error running defaults command: \(error)")
        }
        
        // 2. Fallback to ~/Desktop (macOS default)
        let desktopPath = NSString(string: "~/Desktop").expandingTildeInPath
        print("📌 Falling back to Desktop: \(desktopPath)")
        if FileManager.default.fileExists(atPath: desktopPath) {
            return desktopPath
        }
        
        // 3. Last resort: home directory
        print("📌 Last resort: home directory")
        return NSHomeDirectory()
    }
    
    static func isValidFolder(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
