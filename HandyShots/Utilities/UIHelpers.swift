import Foundation
import AppKit

class UIHelpers {
    static func openFolderPanel() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Screenshot Folder"
        panel.message = "Choose the folder where your screenshots are saved"
        
        if panel.runModal() == .OK {
            return panel.url
        }
        
        return nil
    }
    
    static func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
