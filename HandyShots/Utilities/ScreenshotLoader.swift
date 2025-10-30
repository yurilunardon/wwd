import Foundation
import AppKit

class ScreenshotLoader: ObservableObject {
    @Published var screenshots: [Screenshot] = []
    @Published var isLoading: Bool = false
    
    private let thumbnailSize = NSSize(width: 300, height: 300)
    
    func loadRecentScreenshots(from folder: String, minutes: Int) {
        guard !folder.isEmpty else { return }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fm = FileManager.default
            let now = Date()
            let cutoff = now.addingTimeInterval(-Double(minutes * 60))
            
            // 1. Get all files in folder
            guard let files = try? fm.contentsOfDirectory(atPath: folder) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // 2. Filter image files (.png, .jpg, .jpeg)
            let imageExtensions = ["png", "jpg", "jpeg"]
            let imageFiles = files.filter { filename in
                let ext = (filename as NSString).pathExtension.lowercased()
                return imageExtensions.contains(ext)
            }
            
            // 3. Filter by modification date and create models
            var recentScreenshots: [Screenshot] = []
            
            for filename in imageFiles {
                let path = (folder as NSString).appendingPathComponent(filename)
                
                guard let attrs = try? fm.attributesOfItem(atPath: path),
                      let date = attrs[.modificationDate] as? Date else {
                    continue
                }
                
                if date >= cutoff {
                    var screenshot = Screenshot(
                        filename: filename,
                        path: path,
                        modificationDate: date,
                        thumbnail: nil
                    )
                    
                    // Load thumbnail
                    if let image = NSImage(contentsOfFile: path) {
                        screenshot.thumbnail = self.createThumbnail(from: image)
                    }
                    
                    recentScreenshots.append(screenshot)
                }
            }
            
            // 4. Sort by date (newest first)
            recentScreenshots.sort { $0.modificationDate > $1.modificationDate }
            
            // 5. Update UI on main thread
            DispatchQueue.main.async {
                self.screenshots = recentScreenshots
                self.isLoading = false
            }
        }
    }
    
    private func createThumbnail(from image: NSImage) -> NSImage {
        let targetSize = thumbnailSize
        let imageSize = image.size
        
        // Calculate aspect ratio
        let widthRatio = targetSize.width / imageSize.width
        let heightRatio = targetSize.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        
        let newSize = NSSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
        
        let thumbnail = NSImage(size: newSize)
        thumbnail.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: imageSize),
                   operation: .copy,
                   fraction: 1.0)
        thumbnail.unlockFocus()
        
        return thumbnail
    }
}
