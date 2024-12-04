import Cocoa
import SwiftUI
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var settingsWindow: NSWindow?
    var keyboardMonitor: KeyboardMonitor!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusIcon")
            button.image?.isTemplate = true
            button.image?.size = NSSize(width: 16, height: 16)
            button.imagePosition = .imageLeft
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
        }

        constructMenu()
        keyboardMonitor = KeyboardMonitor()

        if !AXIsProcessTrusted() {
            NSApplication.shared.terminate(self)
        }
    }

    @objc func statusBarButtonClicked(_ sender: Any?) {
    }

    func constructMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit MacVRCRemote", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 302, height: 166),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false)
            settingsWindow?.center()
            settingsWindow?.title = "MacVRCRemote Settings"
            settingsWindow?.contentView = NSHostingView(rootView: SettingsView())
            settingsWindow?.delegate = self
            settingsWindow?.isReleasedWhenClosed = false
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindow {
            settingsWindow = nil
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
