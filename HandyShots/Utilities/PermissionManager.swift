import Foundation
import AppKit

class PermissionManager {
    /// Verifica se l'app ha Full Disk Access
    static func hasFullDiskAccess() -> Bool {
        // Prova a leggere cartelle protette
        let testPaths = [
            NSHomeDirectory() + "/Library/Safari",
            NSHomeDirectory() + "/Library/Messages",
            NSHomeDirectory() + "/Library/Mail"
        ]
        
        for path in testPaths {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue {
                do {
                    _ = try FileManager.default.contentsOfDirectory(atPath: path)
                    // Se riesce a leggere, ha i permessi
                    return true
                } catch let error as NSError {
                    if error.code == 257 { // Operation not permitted
                        return false
                    }
                }
            }
        }
        
        // Se nessun test è conclusivo, prova con Desktop
        let desktopPath = NSHomeDirectory() + "/Desktop"
        do {
            _ = try FileManager.default.contentsOfDirectory(atPath: desktopPath)
            return true
        } catch {
            return false
        }
    }
    
    /// Apre le impostazioni di sistema per Full Disk Access
    static func openFullDiskAccessSettings() {
        // macOS 13+ (Ventura e successivi)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
            NSWorkspace.shared.open(url)
        }
    }
}