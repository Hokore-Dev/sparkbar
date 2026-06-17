//
//  AppMain.swift
//  SparkBar
//
//  Copyright © 2026 Hokore. MIT License.
//

import AppKit
import Combine
import SwiftUI

@main
struct SparkBarApp {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

/// Owns the status item, its drop-down menu, and the usage poll timer.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Usage is time-sensitive but the endpoint is cheap; poll every 5 minutes.
    private static let pollInterval: TimeInterval = 5 * 60

    private var statusItem: NSStatusItem!
    private var usageHostingView: NSHostingView<UsageMenuView>!
    private var settingsWindow: NSWindow?

    private(set) var usageManager: UsageManager!
    private let hotKey = HotKeyCenter()
    private var contentResizeSubscription: AnyCancellable?

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        usageManager = UsageManager(iconDelegate: self)

        updateStatusIcon(percentage: 0)
        statusItem.menu = makeMenu()

        usageManager.refresh()

        Timer.scheduledTimer(withTimeInterval: Self.pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.usageManager.refresh() }
        }

        if usageManager.isShortcutEnabled {
            registerShortcut()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKey.unregister()
    }

    // MARK: - Menu

    /// A standard status-bar menu: the usage gauges live in a custom view item;
    /// everything else is a native menu item so highlight, font, and spacing
    /// match AppKit.
    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        // Accessory apps fail NSMenu's automatic target/action validation while
        // the app is inactive, which grays the items out — manage it ourselves.
        menu.autoenablesItems = false

        usageHostingView = NSHostingView(rootView: UsageMenuView(usageManager: usageManager))
        resizeMenuContent()

        // The gauges change height as data arrives (e.g. the Sonnet row
        // appears) — refit the menu item whenever the manager publishes.
        contentResizeSubscription = usageManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.resizeMenuContent() }

        let usageItem = NSMenuItem()
        usageItem.view = usageHostingView
        menu.addItem(usageItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        settingsItem.isEnabled = true
        menu.addItem(settingsItem)

        let quitItem = NSMenuItem(title: "Quit SparkBar", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        quitItem.isEnabled = true
        menu.addItem(quitItem)

        return menu
    }

    /// Sizes the custom menu item to its SwiftUI content. NSMenu only honors
    /// the view's frame — autolayout-based sizing collapses the item to zero
    /// height — so measure explicitly and set it.
    private func resizeMenuContent() {
        guard let hostingView = usageHostingView else { return }
        hostingView.layoutSubtreeIfNeeded()
        var size = hostingView.fittingSize
        size.width = UsageMenuView.preferredWidth
        size.height = max(size.height, 40)
        hostingView.setFrameSize(size)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Keyboard Shortcut

    func setShortcutEnabled(_ enabled: Bool) {
        if enabled {
            registerShortcut()
        } else {
            hotKey.unregister()
        }
    }

    private func registerShortcut() {
        promptForAccessibilityIfNeeded()
        hotKey.register { [weak self] in
            // Clicking the status item with a menu attached opens the menu,
            // exactly as if the user clicked it.
            self?.statusItem.button?.performClick(nil)
        }
    }

    private func promptForAccessibilityIfNeeded() {
        guard !AXIsProcessTrusted() else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Task { @MainActor in
                Self.presentAccessibilityAlert()
            }
        }
    }

    private static func presentAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = """
            SparkBar needs Accessibility permission to use the ⌘U keyboard shortcut.

            Enable it in System Settings → Privacy & Security → Accessibility.
            """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Skip for Now")
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(ExternalLink.accessibilitySettings)
        }
    }

    // MARK: - Settings Window

    @objc func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hosting = NSHostingController(rootView: SettingsView(usageManager: usageManager))
        let window = NSWindow(contentViewController: hosting)
        window.title = "SparkBar Settings"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()

        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - NSMenuDelegate

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        usageManager.refresh()
        resizeMenuContent()
    }
}

// MARK: - Status Icon

extension AppDelegate: StatusIconUpdating {
    /// Mirrors the system battery item: a template (monochrome) glyph that
    /// adapts to the menu bar, switching to a warning color only when usage
    /// is high enough to need attention.
    func updateStatusIcon(percentage: Int) {
        guard let button = statusItem.button else { return }
        button.image = SparkIcon.image(percentage: percentage,
                                       level: UsageLevel(percentage: percentage))
        button.title = " \(percentage)%"
    }
}

/// Severity buckets shared by the menu bar icon and the menu gauges.
enum UsageLevel {
    case normal
    case elevated
    case critical

    init(percentage: Int) {
        switch percentage {
        case ..<70: self = .normal
        case ..<90: self = .elevated
        default: self = .critical
        }
    }

    init(fraction: Double) {
        self.init(percentage: Int(fraction * 100))
    }

    var tint: Color {
        switch self {
        case .normal: return .green
        case .elevated: return .orange
        case .critical: return .red
        }
    }
}

/// Draws the menu-bar glyph: a usage ring whose filled arc tracks the
/// percentage, wrapping the Claude spark. Mirrors the app icon's
/// ring + spark identity, simplified (4-point spark) so it stays legible at
/// menu-bar sizes where a detailed sunburst would blur into a blob.
enum SparkIcon {
    private static let side: CGFloat = 18
    private static let radius: CGFloat = 7
    private static let lineWidth: CGFloat = 1.8

    static func image(percentage: Int, level: UsageLevel) -> NSImage {
        let image = NSImage(size: NSSize(width: side, height: side))
        image.lockFocus()

        let center = NSPoint(x: side / 2, y: side / 2)
        let color = fillColor(for: level)
        let fraction = CGFloat(max(0, min(100, percentage))) / 100

        // Faint full track ring.
        let track = NSBezierPath()
        track.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
        track.lineWidth = lineWidth
        color.withAlphaComponent(0.30).setStroke()
        track.stroke()

        // Progress arc: starts at the top and sweeps clockwise by `fraction`.
        if fraction > 0 {
            let progress = NSBezierPath()
            progress.appendArc(withCenter: center, radius: radius,
                               startAngle: 90, endAngle: 90 - 360 * fraction,
                               clockwise: true)
            progress.lineWidth = lineWidth
            progress.lineCapStyle = .round
            color.setStroke()
            progress.stroke()
        }

        // Claude spark (4-point) at the center.
        color.setFill()
        sparkPath(center: center, outer: 3.4, inner: 1.2).fill()

        image.unlockFocus()
        // Template images adapt to light/dark menu bars; warning states keep
        // their explicit color, matching the system battery icon's behavior.
        image.isTemplate = (level == .normal)
        return image
    }

    /// An n-pointed star (4 long tips + 4 valleys) centered at `center`,
    /// with the first tip pointing up.
    private static func sparkPath(center: NSPoint, outer: CGFloat, inner: CGFloat) -> NSBezierPath {
        let path = NSBezierPath()
        let vertices = 8
        for i in 0..<vertices {
            let angle = CGFloat.pi / 2 - CGFloat(i) * (.pi * 2 / CGFloat(vertices))
            let r = (i % 2 == 0) ? outer : inner
            let point = NSPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 { path.move(to: point) } else { path.line(to: point) }
        }
        path.close()
        return path
    }

    private static func fillColor(for level: UsageLevel) -> NSColor {
        switch level {
        case .normal: return .black // ignored — template rendering recolors it
        case .elevated: return .systemOrange
        case .critical: return .systemRed
        }
    }
}
