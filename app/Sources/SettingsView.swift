//
//  SettingsView.swift
//  SparkBar
//
//  Copyright © 2026 Hokore. MIT License.
//

import AppKit
import SwiftUI

/// Settings window content, following the System Settings convention of
/// titled groups with right-aligned switches and explanatory footnotes.
struct SettingsView: View {
    @ObservedObject var usageManager: UsageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            generalSection
            notificationsSection
            aboutFooter
        }
        .padding(16)
        .frame(width: 420)
    }

    // MARK: - General

    private var generalSection: some View {
        SettingsGroup("General") {
            if usageManager.canManageLoginItem {
                SettingsToggleRow(
                    title: "Open at Login",
                    subtitle: "Launch SparkBar automatically when you log in.",
                    isOn: $usageManager.isOpenAtLoginEnabled
                )
                Divider()
            }

            SettingsToggleRow(
                title: "Keyboard Shortcut (⌘U)",
                subtitle: "Toggle the popover from anywhere. Disable if it conflicts with other apps.",
                isOn: Binding(
                    get: { usageManager.isShortcutEnabled },
                    set: { enabled in
                        usageManager.isShortcutEnabled = enabled
                        appDelegate?.setShortcutEnabled(enabled)
                    }
                )
            )

            if usageManager.isShortcutEnabled && !usageManager.isAccessibilityEnabled {
                HStack(spacing: 8) {
                    Button("Grant Accessibility Permission") {
                        NSWorkspace.shared.open(ExternalLink.accessibilitySettings)
                    }
                    .controlSize(.small)

                    Text("May be needed for the shortcut to work in all apps.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        SettingsGroup("Notifications") {
            SettingsToggleRow(
                title: "Usage Alerts",
                subtitle: "Notify at 25%, 50%, 75%, and 90% of the session limit.",
                isOn: $usageManager.isUsageNotificationsEnabled
            )

            Button("Send Test Notification") {
                usageManager.sendTestNotification()
            }
            .controlSize(.small)
        }
    }

    // MARK: - About

    private var aboutFooter: some View {
        Text("SparkBar \(appVersion) · © 2026 Hokore")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var appDelegate: AppDelegate? {
        NSApplication.shared.delegate as? AppDelegate
    }
}

// MARK: - Building Blocks

/// A titled, grouped box mirroring System Settings sections.
private struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 10) {
                content
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )
        }
    }
}

/// A row with a title, a secondary explanation, and a right-aligned switch —
/// the System Settings layout.
private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
    }
}
