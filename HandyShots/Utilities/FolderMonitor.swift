import Foundation
import Combine

class FolderMonitor: ObservableObject {
    @Published var systemScreenshotFolder: String
    @Published var showFolderChangeAlert: Bool = false
    
    private var previousFolder: String
    
    init() {
        let detected = FolderDetector.detectSystemFolder()
        self.systemScreenshotFolder = detected
        self.previousFolder = detected
        setupNotificationObserver()
    }
    
    func start() {
        // Initial detection
        checkForFolderChange()
    }
    
    private func setupNotificationObserver() {
        // Listen for system screenshot location changes (primary method)
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.apple.screencapture.location"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Wait a bit for the system to finish updating
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.checkForFolderChange()
            }
        }
        
        // Also try listening to defaults changes
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkForFolderChange()
        }
        
        // Check periodically as backup (every 5 seconds for better responsiveness)
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.checkForFolderChange()
        }
    }
    
    private func checkForFolderChange() {
        let currentFolder = FolderDetector.detectSystemFolder()
        
        print("🔍 FolderMonitor: Checking folder...")
        print("   Current: \(currentFolder)")
        print("   Previous: \(previousFolder)")
        
        if currentFolder != previousFolder {
            print("⚠️ FOLDER CHANGED! Updating...")
            DispatchQueue.main.async { [weak self] in
                self?.systemScreenshotFolder = currentFolder
                self?.showFolderChangeAlert = true
                self?.previousFolder = currentFolder
                print("✅ Alert flag set: \(self?.showFolderChangeAlert ?? false)")
            }
        } else {
            print("✓ No change detected")
        }
    }
    
    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }
}
