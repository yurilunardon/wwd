import SwiftUI

struct ScreenshotGridView: View {
    let screenshots: [Screenshot]
    @State private var hoveredID: UUID?
    
    var body: some View {
        ScrollView {
            if screenshots.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    
                    Text("No recent screenshots")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Take a screenshot to see it here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 12)
                ], spacing: 12) {
                    ForEach(screenshots) { screenshot in
                        ScreenshotItemView(
                            screenshot: screenshot,
                            isHovered: hoveredID == screenshot.id
                        )
                        .onHover { isHovered in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                hoveredID = isHovered ? screenshot.id : nil
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}
