//
//  Support.swift
//  SparkBar
//
//  Copyright © 2026 Hokore. MIT License.
//

import AppKit

/// Every URL the app opens, in one place.
enum ExternalLink {
    static let accessibilitySettings = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    )!
}

/// Thin wrapper over user notifications.
///
/// Intentionally uses the deprecated `NSUserNotification` API: it delivers
/// without a permission prompt, which keeps notifications working for users
/// who never see (or decline) the UserNotifications authorization dialog.
enum Notifier {
    static func deliver(title: String, body: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}

/// Shared date formatting for the UI.
enum Formatters {
    static func shortTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// "at 7:59 AM" or "on 31 Jan 2026 at 7:59 AM" for reset deadlines.
    static func resetTime(_ date: Date, includeDate: Bool = false) -> String {
        let formatter = DateFormatter()
        if includeDate {
            formatter.dateFormat = "d MMM yyyy 'at' h:mm a"
            return "on \(formatter.string(from: date))"
        }
        formatter.timeStyle = .short
        return "at \(formatter.string(from: date))"
    }

    /// Parses ISO 8601 timestamps with or without fractional seconds.
    static func iso8601Date(from string: String) -> Date? {
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFractional.date(from: string) { return date }

        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: string)
    }
}
