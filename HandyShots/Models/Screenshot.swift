import Foundation
import AppKit

struct Screenshot: Identifiable {
    let id = UUID()
    let filename: String
    let path: String
    let modificationDate: Date
    var thumbnail: NSImage?
    
    var url: URL {
        URL(fileURLWithPath: path)
    }
}
