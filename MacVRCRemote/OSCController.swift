import OSCKit
import SwiftUI
import AppKit
import Foundation

class OSCController {
    static let shared = OSCController()

    private let client = OSCClient()
    private var host: String
    private var port: UInt16
    private var quickMenuHand: String

    private init() {
        host = UserDefaults.standard.string(forKey: "OSCHost") ?? "127.0.0.1"
        let savedPort = UserDefaults.standard.integer(forKey: "OSCPort")
        port = savedPort == 0 ? 9000 : UInt16(savedPort)
        quickMenuHand = UserDefaults.standard.string(forKey: "QuickMenuHand") ?? "Left"
    }

    func updateSettings(host: String, port: Int, quickMenuHand: String) {
        self.host = host
        self.port = UInt16(port)
        self.quickMenuHand = quickMenuHand

        UserDefaults.standard.set(host, forKey: "OSCHost")
        UserDefaults.standard.set(port, forKey: "OSCPort")
        UserDefaults.standard.set(quickMenuHand, forKey: "QuickMenuHand")
    }

    func handleKeyEvent(characters: String, isKeyDown: Bool) {
        let value = isKeyDown ? [1] : [0]

        let keyOSCMap: [String: String] = [
            "w": "/input/MoveForward",
            "s": "/input/MoveBackward",
            "a": "/input/MoveLeft",
            "d": "/input/MoveRight",
            "q": "/input/LookLeft",
            "e": "/input/LookRight",
            " ": "/input/Jump",
            "v": "/input/Voice"
        ]

        let character = characters.lowercased()

        if character == "y" && isKeyDown {
            openChatInputDialog()
        } else if let path = keyOSCMap[character] {
            sendOSCMessage(path: path, values: value)
        }
    }

    func handleKeyEvent(keyCode: Int64, isKeyDown: Bool) {
        let value = isKeyDown ? [1] : [0]

        let quickMenuTogglePath = quickMenuHand == "Left" ? "/input/QuickMenuToggleLeft" : "/input/QuickMenuToggleRight"

        if keyCode == 53 {
            sendOSCMessage(path: quickMenuTogglePath, values: value)
        }
    }

    func sendOSCMessage(path: String, values: OSCValues) {
        let message = OSCMessage(
            OSCAddressPattern(path),
            values: values
        )
        do {
            try client.send(message, to: host, port: port)
        } catch {
            print("Error sending OSC message: \(error)")
        }
    }

    private func openChatInputDialog() {
        DispatchQueue.main.async {
            let chatInputView = ChatInputView { [weak self] message in
                self?.sendOSCMessage(path: "/chatbox/input", values: [message, true, true])
            }

            let hostingController = NSHostingController(rootView: chatInputView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "Chatbox"
            window.styleMask = [.titled, .closable]
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.isReleasedWhenClosed = false
            window.center()

            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }}
