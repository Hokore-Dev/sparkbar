//
//  UsageManager.swift
//  SparkBar
//
//  Copyright © 2026 Hokore. MIT License.
//

import AppKit
import ServiceManagement
import SwiftUI

/// Receives menu bar icon updates when usage changes.
@MainActor
protocol StatusIconUpdating: AnyObject {
    func updateStatusIcon(percentage: Int)
}

/// One usage window (session, weekly, weekly Sonnet) as reported by the API.
struct UsageWindow: Equatable {
    /// 0.0 ... 1.0
    var fraction: Double
    var resetsAt: Date?

    var percentage: Int { Int((fraction * 100).rounded()) }
}

/// Fetches usage from Anthropic's OAuth usage endpoint — the same data shown
/// on claude.ai's usage panel — and owns the user-facing app settings.
@MainActor
final class UsageManager: ObservableObject {

    // MARK: - Published State

    @Published private(set) var session: UsageWindow?
    @Published private(set) var weekly: UsageWindow?
    @Published private(set) var weeklySonnet: UsageWindow?
    @Published private(set) var lastUpdated = Date()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasFetchedData = false
    @Published private(set) var isAccessibilityEnabled = false

    @Published var isUsageNotificationsEnabled = true { didSet { saveSettings() } }
    @Published var isShortcutEnabled = true { didSet { saveSettings() } }
    @Published var isOpenAtLoginEnabled = false {
        didSet {
            saveSettings()
            applyLoginItem(isOpenAtLoginEnabled)
        }
    }

    // MARK: - Private State

    private weak var iconDelegate: StatusIconUpdating?
    private let credentialStore = CredentialStore()
    private var lastNotifiedThreshold = 0
    private var isLoadingSettings = false

    private enum DefaultsKey {
        static let usageNotifications = "usage_notifications_enabled"
        static let openAtLogin = "open_at_login"
        static let shortcut = "shortcut_enabled"
        static let lastNotifiedThreshold = "last_notified_threshold"
    }

    private static let usageEndpoint = URL(string: "https://api.anthropic.com/api/oauth/usage")!
    private static let notificationThresholds = [25, 50, 75, 90]

    // MARK: - Lifecycle

    init(iconDelegate: StatusIconUpdating?) {
        self.iconDelegate = iconDelegate
        loadSettings()
        refreshAccessibilityStatus()
    }

    func refreshAccessibilityStatus() {
        isAccessibilityEnabled = AXIsProcessTrusted()
    }

    // MARK: - Fetching

    func refresh() {
        Task { await fetchUsage() }
    }

    private func fetchUsage() async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            updateStatusBar()
        }

        guard let token = await credentialStore.validAccessToken() else {
            errorMessage = "No Claude Code login — run `claude login` in a terminal."
            return
        }

        var request = URLRequest(url: Self.usageEndpoint)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(CredentialStore.betaHeader, forHTTPHeaderField: "anthropic-beta")
        request.setValue(CredentialStore.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response"
                return
            }
            guard httpResponse.statusCode == 200 else {
                errorMessage = "HTTP \(httpResponse.statusCode)"
                return
            }
            parseUsage(data)
        } catch {
            NSLog("UsageManager: network error — \(error.localizedDescription)")
            errorMessage = "Network error"
        }
    }

    private func parseUsage(_ data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            errorMessage = "Unexpected response format"
            return
        }

        session = Self.window(from: json["five_hour"])
        weekly = Self.window(from: json["seven_day"])
        weeklySonnet = Self.window(from: json["seven_day_sonnet"])

        lastUpdated = Date()
        errorMessage = nil
        hasFetchedData = true
    }

    private static func window(from value: Any?) -> UsageWindow? {
        guard let dict = value as? [String: Any],
              let utilization = dict["utilization"] as? Double else {
            return nil
        }
        let resetsAt = (dict["resets_at"] as? String).flatMap(Formatters.iso8601Date(from:))
        return UsageWindow(fraction: utilization / 100, resetsAt: resetsAt)
    }

    // MARK: - Status Bar & Notifications

    private func updateStatusBar() {
        let percentage = session?.percentage ?? 0
        iconDelegate?.updateStatusIcon(percentage: percentage)
        checkNotificationThresholds(percentage: percentage)
    }

    private func checkNotificationThresholds(percentage: Int) {
        guard isUsageNotificationsEnabled else { return }

        for threshold in Self.notificationThresholds
        where percentage >= threshold && lastNotifiedThreshold < threshold {
            Notifier.deliver(
                title: "Claude Usage Alert",
                body: "You've reached \(percentage)% of your 5-hour session limit"
            )
            setLastNotifiedThreshold(threshold)
        }

        // A new session window started — re-arm the passed thresholds.
        if percentage < lastNotifiedThreshold {
            let rearmed = Self.notificationThresholds.last(where: { $0 <= percentage }) ?? 0
            setLastNotifiedThreshold(rearmed)
        }
    }

    private func setLastNotifiedThreshold(_ value: Int) {
        lastNotifiedThreshold = value
        UserDefaults.standard.set(value, forKey: DefaultsKey.lastNotifiedThreshold)
    }

    func sendTestNotification() {
        Notifier.deliver(
            title: "Claude Usage Alert",
            body: "Test notification — you've reached 75% of your 5-hour session limit"
        )
    }

    // MARK: - Settings Persistence

    private func loadSettings() {
        isLoadingSettings = true
        defer { isLoadingSettings = false }

        let defaults = UserDefaults.standard
        if defaults.object(forKey: DefaultsKey.usageNotifications) != nil {
            isUsageNotificationsEnabled = defaults.bool(forKey: DefaultsKey.usageNotifications)
        }
        if defaults.object(forKey: DefaultsKey.shortcut) != nil {
            isShortcutEnabled = defaults.bool(forKey: DefaultsKey.shortcut)
        }
        isOpenAtLoginEnabled = defaults.bool(forKey: DefaultsKey.openAtLogin)
        lastNotifiedThreshold = defaults.integer(forKey: DefaultsKey.lastNotifiedThreshold)
    }

    private func saveSettings() {
        guard !isLoadingSettings else { return }
        let defaults = UserDefaults.standard
        defaults.set(isUsageNotificationsEnabled, forKey: DefaultsKey.usageNotifications)
        defaults.set(isOpenAtLoginEnabled, forKey: DefaultsKey.openAtLogin)
        defaults.set(isShortcutEnabled, forKey: DefaultsKey.shortcut)
    }

    // MARK: - Login Item

    /// Login item registration requires SMAppService (macOS 13+).
    var canManageLoginItem: Bool {
        if #available(macOS 13.0, *) { return true }
        return false
    }

    private func applyLoginItem(_ enabled: Bool) {
        guard !isLoadingSettings else { return }
        guard #available(macOS 13.0, *) else { return }
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("UsageManager: failed to update login item — \(error.localizedDescription)")
        }
    }
}
