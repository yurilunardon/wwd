import SwiftUI

struct WelcomeView: View {
    @State private var showAnimation = true
    @State private var showConfiguration = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.6)]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()

            if showAnimation {
                VStack {
                    Text("👋")
                        .font(.system(size: 120))
                        .scaleEffect(scale)
                        .opacity(opacity)

                    Text("Hello!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(opacity)
                }
                .onAppear {
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.6, blendDuration: 0)) {
                        scale = 1.0
                        opacity = 1.0
                    }

                    // Dopo 2.5 secondi passa alla configurazione
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            showAnimation = false
                            showConfiguration = true
                        }
                    }
                }
            } else if showConfiguration {
                ConfigurationView()
                    .transition(.move(edge: .trailing))
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct ConfigurationView: View {
    @State private var detectedFolder: String = ""
    @State private var selectedFolder: String = ""
    @State private var minutes: Int = 5
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @AppStorage("screenshotFolder") private var screenshotFolder = ""
    @AppStorage("monitorMinutes") private var monitorMinutes = 5

    var body: some View {
        VStack(spacing: 30) {
            Text("Configurazione")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 15) {
                Text("📁 Cartella rilevata:")
                    .font(.headline)
                    .foregroundColor(.white)

                Text(detectedFolder.isEmpty ? "Rilevamento..." : detectedFolder)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)

                HStack {
                    Text("⏱️ Minuti da monitorare:")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Stepper("\(minutes) min", value: $minutes, in: 1...60)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 40)

            Button(action: {
                // Salva configurazione
                screenshotFolder = selectedFolder.isEmpty ? detectedFolder : selectedFolder
                monitorMinutes = minutes
                hasCompletedSetup = true

                // Chiudi e riapri per mostrare main view
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.popover.performClose(nil)
                }
            }) {
                Text("Inizia")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 200)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .onAppear {
            detectScreenshotFolder()
        }
    }

    func detectScreenshotFolder() {
        // Leggi le impostazioni di sistema per la cartella screenshot
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
               !output.isEmpty {
                detectedFolder = output
                selectedFolder = output
            } else {
                // Default Desktop
                detectedFolder = NSString(string: "~/Desktop").expandingTildeInPath
                selectedFolder = detectedFolder
            }
        } catch {
            // Default Desktop
            detectedFolder = NSString(string: "~/Desktop").expandingTildeInPath
            selectedFolder = detectedFolder
        }
    }
}
