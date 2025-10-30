import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 HandyShots sta partendo...")

        // Nasconde l'icona dock
        NSApp.setActivationPolicy(.accessory)
        print("✓ Activation policy impostata")

        // Crea status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        print("✓ Status item creato")

        if let button = statusItem.button {
            // Prova prima con SF Symbol, poi con fallback
            if let sfImage = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "HandyShots") {
                button.image = sfImage
                print("✓ Icona SF Symbol caricata")
            } else {
                // Fallback: usa emoji come testo
                button.title = "📸"
                print("✓ Fallback icona emoji usato")
            }
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            print("✓ Button configurato")
        } else {
            print("❌ ERRORE: impossibile ottenere button da statusItem!")
        }

        // Crea popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 600, height: 500)
        popover.behavior = .transient
        print("✓ Popover creato")

        // Verifica stato app
        print("→ Controllo stato app...")
        checkAppState()
        print("✓ HandyShots pronta!")
    }

    func checkAppState() {
        let defaults = UserDefaults.standard
        let hasCompletedSetup = defaults.bool(forKey: "hasCompletedSetup")
        print("   Setup completato: \(hasCompletedSetup)")

        if !hasCompletedSetup {
            // Mostra onboarding
            print("   → Mostrando onboarding")
            showOnboarding()
        } else {
            // Verifica permessi
            let hasAccess = hasFullDiskAccess()
            print("   Full Disk Access: \(hasAccess)")
            if hasAccess {
                // Mostra griglia screenshot
                print("   → Mostrando griglia screenshot")
                showMainView()
            } else {
                // Mostra richiesta permessi
                print("   → Mostrando richiesta permessi")
                showPermissionRequest()
            }
        }
    }

    func hasFullDiskAccess() -> Bool {
        let screenshotPath = NSString(string: "~/Desktop").expandingTildeInPath
        let testPath = (screenshotPath as NSString).appendingPathComponent(".test_access")

        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            return false
        }
    }

    func showOnboarding() {
        if hasFullDiskAccess() {
            popover.contentViewController = NSHostingController(rootView: WelcomeView())
        } else {
            popover.contentViewController = NSHostingController(rootView: PermissionRequestView())
        }
    }

    func showPermissionRequest() {
        popover.contentViewController = NSHostingController(rootView: PermissionRequestView())
    }

    func showMainView() {
        popover.contentViewController = NSHostingController(rootView: MainScreenshotGridView())
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            let event = NSApp.currentEvent

            // Tasto destro -> mostra menu
            if event?.type == .rightMouseUp {
                showMenu()
                return
            }

            // Tasto sinistro -> toggle popover
            if popover.isShown {
                popover.performClose(nil)
            } else {
                // Ricontrolla stato prima di mostrare
                checkAppState()
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func showMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit HandyShots", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "Settings"
            settingsWindow?.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            settingsWindow?.setContentSize(NSSize(width: 400, height: 300))
            settingsWindow?.center()
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
