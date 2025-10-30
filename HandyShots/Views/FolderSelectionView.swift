import SwiftUI

struct FolderSelectionView: View {
    let onComplete: (String) -> Void
    
    @EnvironmentObject private var folderMonitor: FolderMonitor
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icona
            Image(systemName: "folder.fill.badge.gearshape")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            // Titolo
            Text("Choose Your Screenshot Folder")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("HandyShots will monitor this folder for new screenshots")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Cartella detectata
            VStack(alignment: .leading, spacing: 12) {
                Text("System default screenshot location:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    
                    Text(folderMonitor.systemScreenshotFolder)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(2)
                        .truncationMode(.middle)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 40)
            
            // Bottoni
            VStack(spacing: 12) {
                Button(action: {
                    onComplete(folderMonitor.systemScreenshotFolder)
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Use This Folder")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Choose Different Folder...") {
                    if let url = UIHelpers.openFolderPanel() {
                        onComplete(url.path)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
}
