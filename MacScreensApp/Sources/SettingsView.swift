import SwiftUI

struct SettingsView: View {
    @AppStorage("screenshotFolder") private var screenshotFolder = ""
    @AppStorage("monitorMinutes") private var monitorMinutes = 5
    @State private var tempFolder: String = ""
    @State private var showingFolderPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Impostazioni")
                .font(.title)
                .fontWeight(.bold)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("📁 Cartella Screenshot")
                    .font(.headline)

                HStack {
                    Text(screenshotFolder)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button("Cambia...") {
                        selectFolder()
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("⏱️ Minuti da Monitorare")
                    .font(.headline)

                HStack {
                    Stepper("\(monitorMinutes) minuti", value: $monitorMinutes, in: 1...60)

                    Spacer()
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("🔄 Reset")
                    .font(.headline)

                Button(action: {
                    resetApp()
                }) {
                    Text("Reset Configurazione")
                        .foregroundColor(.red)
                }
            }

            Spacer()

            Text("Screenshot Monitor v1.0")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 400, height: 300)
        .onAppear {
            tempFolder = screenshotFolder
        }
    }

    func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Seleziona la cartella degli screenshot"

        if panel.runModal() == .OK, let url = panel.url {
            screenshotFolder = url.path
        }
    }

    func resetApp() {
        let alert = NSAlert()
        alert.messageText = "Reset Configurazione"
        alert.informativeText = "Sei sicuro di voler resettare la configurazione? L'app tornerà allo stato iniziale."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Annulla")

        if alert.runModal() == .alertFirstButtonReturn {
            UserDefaults.standard.removeObject(forKey: "hasCompletedSetup")
            UserDefaults.standard.removeObject(forKey: "screenshotFolder")
            UserDefaults.standard.removeObject(forKey: "monitorMinutes")

            // Chiudi finestra settings
            NSApp.windows.first { $0.title == "Settings" }?.close()

            // Riavvia app flow
            if let appDelegate = NSApp.delegate as? AppDelegate {
                appDelegate.checkAppState()
            }
        }
    }
}
