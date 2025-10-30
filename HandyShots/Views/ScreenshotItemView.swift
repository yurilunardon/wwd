import SwiftUI
import AppKit

struct ScreenshotItemView: View {
    let screenshot: Screenshot
    let isHovered: Bool
    
    var body: some View {
        ZStack {
            if let image = screenshot.thumbnail {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isHovered ? 200 : 160,
                           height: isHovered ? 150 : 120)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(isHovered ? 0.3 : 0.1),
                            radius: isHovered ? 12 : 4,
                            x: 0,
                            y: isHovered ? 6 : 2)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .zIndex(isHovered ? 1 : 0)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 160, height: 120)
            }
        }
        .onDrag {
            NSItemProvider(object: screenshot.url as NSURL)
        }
    }
}
