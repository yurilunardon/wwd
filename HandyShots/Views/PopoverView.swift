import SwiftUI

struct PopoverView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("screenshotFolder") private var screenshotFolder = ""
    @AppStorage("timeFilterMinutes") private var timeFilterMinutes = 5
    
    @EnvironmentObject var folderMonitor: FolderMonitor
    @EnvironmentObject var screenshotLoader: ScreenshotLoader
    
    var body: some View {
        ZStack {
            if isFirstLaunch {
                WelcomeView()
                    .environmentObject(folderMonitor)
            } else {
                VStack(spacing: 0) {
                    // Header con info e bottone cambia cartella
                    VStack(spacing: 8) {
                        HStack {
                            Text("Recent Screenshots")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("Last \(timeFilterMinutes) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Cartella monitorata
                        HStack(spacing: 6) {
                            Image(systemName: "folder.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            
                            Text(currentFolder)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            Spacer()
                            
                            // Bottone per cambiare cartella
                            Button(action: {
                                if let url = UIHelpers.openFolderPanel() {
                                    screenshotFolder = url.path
                                    UserDefaults.standard.set(screenshotFolder, forKey: "screenshotFolder")
                                    loadScreenshots()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.caption2)
                                    Text("Change")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.mini)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue.opacity(0.06))
                        )
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color(NSColor.windowBackgroundColor))
                    
                    Divider()
                    
                    // Griglia screenshots
                    if screenshotLoader.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScreenshotGridView(screenshots: screenshotLoader.screenshots)
                    }
                }
                .onAppear {
                    folderMonitor.start()
                    loadScreenshots()
                }
                .onChange(of: timeFilterMinutes) { _ in
                    loadScreenshots()
                }
                .onChange(of: screenshotFolder) { _ in
                    loadScreenshots()
                }
                // Alert quando cambia la cartella di sistema
                .alert("Screenshot Folder Changed", isPresented: $folderMonitor.showFolderChangeAlert) {
                    Button("Update to New Folder") {
                        screenshotFolder = folderMonitor.systemScreenshotFolder
                        UserDefaults.standard.set(screenshotFolder, forKey: "screenshotFolder")
                        loadScreenshots()
                    }
                    Button("Keep Current Folder", role: .cancel) { }
                } message: {
                    Text("macOS screenshot location changed to:\n\n\(folderMonitor.systemScreenshotFolder)\n\nWould you like HandyShots to follow this change?")
                }
            }
        }
        .frame(width: 600, height: 500)
    }
    
    private var currentFolder: String {
        let folder = screenshotFolder.isEmpty ? folderMonitor.systemScreenshotFolder : screenshotFolder
        // Mostra solo il nome della cartella se è troppo lungo
        return (folder as NSString).lastPathComponent.isEmpty ? folder : folder
    }
    
    private func loadScreenshots() {
        let folder = screenshotFolder.isEmpty ? folderMonitor.systemScreenshotFolder : screenshotFolder
        screenshotLoader.loadRecentScreenshots(from: folder, minutes: timeFilterMinutes)
    }
}