import SwiftUI
import AppKit

struct MainScreenshotGridView: View {
    @StateObject private var monitor = ScreenshotMonitor()
    @State private var showFolderChangeAlert = false
    @State private var newDetectedFolder = ""
    @AppStorage("screenshotFolder") private var screenshotFolder = ""
    @AppStorage("monitorMinutes") private var monitorMinutes = 5

    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 10)
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("📸 Screenshots")
                        .font(.headline)

                    Spacer()

                    Text("Ultimi \(monitorMinutes) min")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        if let appDelegate = NSApp.delegate as? AppDelegate {
                            appDelegate.openSettings()
                        }
                    }) {
                        Image(systemName: "gear")
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        NSApp.terminate(nil)
                    }) {
                        Image(systemName: "xmark.circle")
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color(NSColor.windowBackgroundColor))

                Divider()

                // Grid
                if monitor.screenshots.isEmpty {
                    VStack {
                        Spacer()
                        Text("📭")
                            .font(.system(size: 60))
                        Text("Nessun screenshot trovato")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("negli ultimi \(monitorMinutes) minuti")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(monitor.screenshots) { screenshot in
                                ScreenshotThumbnail(screenshot: screenshot)
                            }
                        }
                        .padding()
                    }
                }
            }

            // Overlay per cambio cartella
            if showFolderChangeAlert {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("📁")
                        .font(.system(size: 60))

                    Text("Cartella Screenshot Cambiata")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Nuova cartella rilevata:")
                        .foregroundColor(.white.opacity(0.8))

                    Text(newDetectedFolder)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)

                    HStack(spacing: 15) {
                        Button(action: {
                            // Accetta nuova cartella
                            screenshotFolder = newDetectedFolder
                            monitor.updateFolder(newDetectedFolder)
                            showFolderChangeAlert = false
                        }) {
                            Text("Accetta")
                                .foregroundColor(.white)
                                .frame(width: 120)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            // Ignora
                            showFolderChangeAlert = false
                        }) {
                            Text("Ignora")
                                .foregroundColor(.white)
                                .frame(width: 120)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(40)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.95))
                .cornerRadius(16)
                .shadow(radius: 20)
            }
        }
        .frame(width: 600, height: 500)
        .onAppear {
            monitor.startMonitoring(folder: screenshotFolder, minutes: monitorMinutes)
            checkFolderChanges()
        }
        .onDisappear {
            monitor.stopMonitoring()
        }
    }

    func checkFolderChanges() {
        // Controlla periodicamente se la cartella di sistema è cambiata
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let task = Process()
            task.launchPath = "/usr/bin/defaults"
            task.arguments = ["read", "com.apple.screencapture", "location"]

            let pipe = Pipe()
            task.standardOutput = pipe

            do {
                try task.run()
                task.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !output.isEmpty,
                   output != screenshotFolder {
                    newDetectedFolder = output
                    showFolderChangeAlert = true
                }
            } catch {
                // Ignora errori
            }
        }
    }
}

struct ScreenshotThumbnail: View {
    let screenshot: Screenshot

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let image = screenshot.thumbnail {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 180, height: 120)
                    .clipped()
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .onTapGesture {
                        // Apri screenshot
                        NSWorkspace.shared.open(screenshot.url)
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 120)
                    .cornerRadius(8)
            }

            Text(screenshot.name)
                .font(.caption)
                .lineLimit(1)

            Text(screenshot.relativeTime)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// Model
struct Screenshot: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let date: Date
    var thumbnail: NSImage?

    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// Screenshot Monitor
class ScreenshotMonitor: ObservableObject {
    @Published var screenshots: [Screenshot] = []

    private var folderURL: URL?
    private var minutes: Int = 5
    private var fileSystemSource: DispatchSourceFileSystemObject?
    private var timer: Timer?

    func startMonitoring(folder: String, minutes: Int) {
        self.minutes = minutes
        let expandedPath = NSString(string: folder).expandingTildeInPath
        self.folderURL = URL(fileURLWithPath: expandedPath)

        loadScreenshots()

        // Timer per aggiornare periodicamente
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.loadScreenshots()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func updateFolder(_ newFolder: String) {
        stopMonitoring()
        startMonitoring(folder: newFolder, minutes: minutes)
    }

    private func loadScreenshots() {
        guard let folderURL = folderURL else { return }

        do {
            let fileManager = FileManager.default
            let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey], options: [.skipsHiddenFiles])

            let cutoffDate = Date().addingTimeInterval(-Double(minutes * 60))

            let recentScreenshots = contents.filter { url in
                // Filtra solo file immagine
                let ext = url.pathExtension.lowercased()
                guard ["png", "jpg", "jpeg", "gif", "tiff"].contains(ext) else { return false }

                // Controlla data
                if let attributes = try? fileManager.attributesOfItem(atPath: url.path),
                   let creationDate = attributes[.creationDate] as? Date {
                    return creationDate >= cutoffDate
                }
                return false
            }
            .sorted { url1, url2 in
                let date1 = (try? fileManager.attributesOfItem(atPath: url1.path))?[.creationDate] as? Date ?? Date.distantPast
                let date2 = (try? fileManager.attributesOfItem(atPath: url2.path))?[.creationDate] as? Date ?? Date.distantPast
                return date1 > date2
            }

            DispatchQueue.main.async {
                self.screenshots = recentScreenshots.map { url in
                    let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                    let date = attributes?[.creationDate] as? Date ?? Date()
                    let thumbnail = NSImage(contentsOf: url)

                    return Screenshot(url: url, name: url.lastPathComponent, date: date, thumbnail: thumbnail)
                }
            }
        } catch {
            print("Errore caricamento screenshot: \(error)")
        }
    }
}
