//
//  UsageMenuView.swift
//  SparkBar
//
//  Copyright © 2026 Hokore. MIT License.
//

import AppKit
import SwiftUI

/// The custom content hosted inside the status-bar menu, sized and spaced to
/// sit alongside native menu items.
struct UsageMenuView: View {
    static let preferredWidth: CGFloat = 300

    @ObservedObject var usageManager: UsageManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let error = usageManager.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            usageSection

            Divider()
            updatedRow
        }
        .padding(.horizontal, 14)
        .padding(.top, 4)
        .padding(.bottom, 6)
        .frame(width: Self.preferredWidth, alignment: .leading)
    }

    // MARK: - Usage

    @ViewBuilder
    private var usageSection: some View {
        if usageManager.hasFetchedData {
            VStack(alignment: .leading, spacing: 10) {
                if let session = usageManager.session {
                    UsageGaugeRow(
                        title: "Session",
                        detail: "5-hour limit",
                        window: session,
                        includesDateInReset: false
                    )
                }
                if let weekly = usageManager.weekly {
                    UsageGaugeRow(
                        title: "Weekly",
                        detail: "All models",
                        window: weekly,
                        includesDateInReset: true
                    )
                }
                if let sonnet = usageManager.weeklySonnet {
                    UsageGaugeRow(
                        title: "Weekly",
                        detail: "Sonnet",
                        window: sonnet,
                        includesDateInReset: true
                    )
                }
            }
        } else {
            Label(
                "Reading usage from your Claude Code login. If this stays empty, run `claude login` in a terminal.",
                systemImage: "info.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Footer Row

    private var updatedRow: some View {
        HStack {
            if usageManager.hasFetchedData {
                Text("Updated \(Formatters.shortTime(usageManager.lastUpdated))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Button {
                usageManager.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .help("Refresh now")
        }
    }
}

// MARK: - Subviews

/// Battery-style gauge row: name and percent on the baseline, bar below,
/// reset deadline as a footnote.
struct UsageGaugeRow: View {
    let title: String
    let detail: String
    let window: UsageWindow
    let includesDateInReset: Bool

    var body: some View {
        let fraction = min(max(window.fraction, 0), 1)
        let level = UsageLevel(fraction: fraction)

        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(window.percentage)%")
                    .font(.system(size: 13, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(level.tint)
            }

            ProgressView(value: fraction)
                .tint(level.tint)
                .controlSize(.small)

            if let resetsAt = window.resetsAt {
                Text("Resets \(Formatters.resetTime(resetsAt, includeDate: includesDateInReset))")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
