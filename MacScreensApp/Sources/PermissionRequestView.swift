import SwiftUI

struct PermissionRequestView: View {
    @State private var showAnimation = true
    @State private var showButton = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.red.opacity(0.6), .orange.opacity(0.6)]),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                if showAnimation {
                    Text("🔒")
                        .font(.system(size: 100))
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                                scale = 1.0
                                opacity = 1.0
                            }
                        }
                }

                Text("Permessi Necessari")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(opacity)

                Text("Quest'app ha bisogno di accesso completo\nal disco per funzionare correttamente")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .opacity(opacity)

                if showButton {
                    VStack(spacing: 15) {
                        Button(action: {
                            openSystemPreferences()
                        }) {
                            Text("Apri Preferenze di Sistema")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .frame(width: 280)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            checkAndProceed()
                        }) {
                            Text("Ho Concesso i Permessi")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .underline()
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .padding()
        }
        .frame(width: 600, height: 500)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showButton = true
                }
            }
        }
    }

    func openSystemPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
        NSWorkspace.shared.open(url)
    }

    func checkAndProceed() {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            if appDelegate.hasFullDiskAccess() {
                // Chiudi popover e mostra onboarding o main view
                appDelegate.popover.performClose(nil)

                let defaults = UserDefaults.standard
                let hasCompletedSetup = defaults.bool(forKey: "hasCompletedSetup")

                if !hasCompletedSetup {
                    // Mostra welcome
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appDelegate.showOnboarding()
                        appDelegate.togglePopover()
                    }
                } else {
                    // Mostra main view
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appDelegate.showMainView()
                        appDelegate.togglePopover()
                    }
                }
            } else {
                // Mostra alert
                let alert = NSAlert()
                alert.messageText = "Permessi non concessi"
                alert.informativeText = "Per favore concedi l'accesso completo al disco nelle Preferenze di Sistema"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
}
