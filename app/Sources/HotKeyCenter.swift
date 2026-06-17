//
//  HotKeyCenter.swift
//  SparkBar
//
//  Copyright © 2026 Hokore. MIT License.
//

import Carbon
import Foundation

/// Registers the global ⌘U hotkey via the Carbon hotkey API, which is the
/// only mechanism that works system-wide without a privileged event tap.
final class HotKeyCenter {
    private enum Key {
        static let uKeyCode: UInt32 = 32
        static let signature: OSType = 0x436C_5542 // 'ClUB'
    }

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var onPress: (@MainActor () -> Void)?

    deinit {
        unregister()
    }

    /// Registers ⌘U. Safe to call repeatedly; re-registration is a no-op.
    func register(onPress: @escaping @MainActor () -> Void) {
        guard hotKeyRef == nil else { return }
        self.onPress = onPress

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )

        let callback: EventHandlerUPP = { _, _, userData in
            guard let userData = userData else { return noErr }
            let center = Unmanaged<HotKeyCenter>.fromOpaque(userData).takeUnretainedValue()
            let handler = center.onPress
            Task { @MainActor in
                handler?()
            }
            return noErr
        }

        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(GetApplicationEventTarget(), callback, 1, &eventType, selfPointer, &eventHandlerRef)

        let hotKeyID = EventHotKeyID(signature: Key.signature, id: 1)
        let status = RegisterEventHotKey(
            Key.uKeyCode,
            UInt32(cmdKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            NSLog("HotKeyCenter: failed to register ⌘U (status \(status))")
        }
    }

    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandlerRef = eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
        onPress = nil
    }
}
