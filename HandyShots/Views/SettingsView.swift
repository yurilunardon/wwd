import SwiftUI

struct SettingsView: View {
    @AppStorage("timeFilterMinutes") private var timeFilter = 5
    @AppStorage("screenshotFolder") private var screenshotFolder = ""
    
    var body: some View {
        Form {
            Section("Display Settings") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Show screenshots from last:")
                        Spacer()
                        Text("\(timeFilter) minutes")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(timeFilter) },
                        set: { timeFilter = Int($0) }
                    ), in: 1...60, step: 1)
                }
            }
            
            Section("Screenshot Folder") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(screenshotFolder.isEmpty ? "Not set" : screenshotFolder)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Change Folder...") {
                        if let url = UIHelpers.openFolderPanel() {
                            screenshotFolder = url.path
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 300)
    }
}
