import SwiftUI

struct WelcomeView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("screenshotFolder") private var screenshotFolder = ""
    @EnvironmentObject private var folderMonitor: FolderMonitor
    @State private var showFolderSelection = false

    var body: some View {
        VStack(spacing: 20) {
            // Animated "Hello"
            if !showFolderSelection {
                WelcomeAnimationView()
                    .frame(width: 400, height: 300)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showFolderSelection = true
                            }
                        }
                    }
            } else {
                Text("Welcome to HandyShots!")
                    .font(.title).bold()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Detected screenshot folder:")
                        .font(.caption).foregroundColor(.secondary)

                    Text(folderMonitor.systemScreenshotFolder)
                        .font(.callout)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }

                HStack(spacing: 16) {
                    Button("Use This Folder") {
                        screenshotFolder = folderMonitor.systemScreenshotFolder
                        isFirstLaunch = false
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Choose Different...") {
                        if let url = UIHelpers.openFolderPanel() {
                            screenshotFolder = url.path
                            isFirstLaunch = false
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(24)
        .frame(width: 500, height: 400)
    }
}