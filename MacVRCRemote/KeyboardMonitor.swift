import Cocoa
import CoreGraphics

extension CGEventFlags {
    static let rightCommand = CGEventFlags(rawValue: 0x00008000)
    static let leftCommand = CGEventFlags(rawValue: 0x00000008)
}

class KeyboardMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: eventTapCallback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        } else {
            print("Failed to create event tap, check Accessibility permission")
        }
    }

    private func stopMonitoring() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private let eventTapCallback: CGEventTapCallBack = { (proxy, type, event, refcon) in
        let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(refcon!).takeUnretainedValue()
        return monitor.handle(event: event, type: type)
    }

    private func handle(event: CGEvent, type: CGEventType) -> Unmanaged<CGEvent>? {
        let flags = event.flags

        if flags.contains(.maskCommand) && !flags.contains(.leftCommand) {
            let isKeyDown = type == .keyDown

            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

            if keyCode == 53 {
                OSCController.shared.handleKeyEvent(keyCode: keyCode, isKeyDown: isKeyDown)
                return nil
            }

            var length: Int = 0
            var buffer = [UniChar](repeating: 0, count: 4)
            event.keyboardGetUnicodeString(maxStringLength: 4, actualStringLength: &length, unicodeString: &buffer)
            let characters = String(utf16CodeUnits: buffer, count: length)

            if !characters.isEmpty {
                OSCController.shared.handleKeyEvent(characters: characters, isKeyDown: isKeyDown)
                return nil
            }
        }

        return Unmanaged.passRetained(event)
    }}
