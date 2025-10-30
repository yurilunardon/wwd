import SwiftUI
import AVKit

struct FullDiskAccessView: View {
    let onPermissionGranted: () -> Void
    
    @State private var showDeniedMessage = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Video o placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Full Disk Access Required")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 40)
            
            // Testo esplicativo
            VStack(spacing: 12) {
                Text("HandyShots needs Full Disk Access")
                    .font(.headline)
                
                Text("This allows the app to read screenshots from any folder on your Mac.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            // Bottoni
            if !showDeniedMessage {
                VStack(spacing: 12) {
                    Button(action: {
                        PermissionManager.openFullDiskAccessSettings()
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Open System Settings")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("I've Allowed Access") {
                        checkPermissions()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.horizontal, 40)
            } else {
                // Messaggio di rifiuto
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("The app cannot function without Full Disk Access")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        PermissionManager.openFullDiskAccessSettings()
                        showDeniedMessage = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal, 40)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 20)
    }
    
    private func checkPermissions() {
        if PermissionManager.hasFullDiskAccess() {
            onPermissionGranted()
        } else {
            withAnimation {
                showDeniedMessage = true
            }
        }
    }
}