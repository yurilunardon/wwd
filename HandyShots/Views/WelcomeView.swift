import SwiftUI

enum WelcomeStep {
    case checkingPermissions
    case needsPermissions
    case hello
    case selectFolder
}

struct WelcomeView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("screenshotFolder") private var screenshotFolder = ""
    @EnvironmentObject private var folderMonitor: FolderMonitor
    
    @State private var currentStep: WelcomeStep = .checkingPermissions
    
    var body: some View {
        VStack(spacing: 0) {
            switch currentStep {
            case .checkingPermissions:
                ProgressView()
                    .onAppear {
                        checkPermissions()
                    }
                
            case .needsPermissions:
                FullDiskAccessView(onPermissionGranted: {
                    // Verifica nuovamente i permessi
                    if PermissionManager.hasFullDiskAccess() {
                        withAnimation {
                            currentStep = .hello
                        }
                    }
                })
                
            case .hello:
                WelcomeAnimationView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        // Dopo 2.5 secondi passa alla selezione cartella
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                currentStep = .selectFolder
                            }
                        }
                    }
                
            case .selectFolder:
                FolderSelectionView(onComplete: { selectedFolder in
                    screenshotFolder = selectedFolder
                    isFirstLaunch = false
                    UserDefaults.standard.set(screenshotFolder, forKey: "screenshotFolder")
                })
                .environmentObject(folderMonitor)
            }
        }
        .frame(width: 500, height: 400)
    }
    
    private func checkPermissions() {
        // Mostra sempre la schermata di permessi al primo avvio
        // per assicurarci che l'utente conceda Full Disk Access
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentStep = .needsPermissions
        }
    }
}