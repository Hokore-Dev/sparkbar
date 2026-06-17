//
//  CredentialStore.swift
//  SparkBar
//
//  Copyright © 2026 Hokore. MIT License.
//

import Foundation

/// Reads the OAuth token that `claude login` stores in the login keychain
/// (service "Claude Code-credentials") and refreshes it when needed.
///
/// The token is the same credential Claude Code itself uses; it never leaves
/// this Mac except to call Anthropic's API. Refreshed tokens are written back
/// so Claude Code and this app stay in sync.
struct CredentialStore {
    private enum OAuth {
        static let clientID = "9d1c250a-e61b-44d9-88ed-5944d1962f5e"
        static let userAgent = "claude-code/2.1.105 (SparkBar)"
        static let betaHeader = "oauth-2025-04-20"
        static let tokenEndpoint = URL(string: "https://api.anthropic.com/v1/oauth/token")!
        static let keychainService = "Claude Code-credentials"
        /// Refresh ahead of expiry so in-flight requests never race the deadline.
        static let expiryLeeway: TimeInterval = 60
    }

    static let userAgent = OAuth.userAgent
    static let betaHeader = OAuth.betaHeader

    private struct Credentials {
        var accessToken: String
        var refreshToken: String
        var expiresAtMilliseconds: Double
        var keychainAccount: String
        /// The entire keychain blob, preserved verbatim on write-back.
        var fullPayload: [String: Any]
    }

    // MARK: - Public API

    /// Returns a valid access token, refreshing it first if it expires soon.
    func validAccessToken() async -> String? {
        guard let credentials = readCredentials() else { return nil }

        let nowMilliseconds = Date().timeIntervalSince1970 * 1000
        let leewayMilliseconds = OAuth.expiryLeeway * 1000
        if credentials.expiresAtMilliseconds > nowMilliseconds + leewayMilliseconds {
            return credentials.accessToken
        }
        return await refreshAccessToken(credentials)
    }

    // MARK: - Keychain

    /// Runs /usr/bin/security and returns (exit status, stdout).
    private func runSecurityTool(_ arguments: [String]) -> (status: Int32, output: Data) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = arguments
        let stdout = Pipe()
        process.standardOutput = stdout
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            return (-1, Data())
        }
        let output = stdout.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (process.terminationStatus, output)
    }

    /// Parses the `"acct"<blob>="…"` line from the keychain metadata dump.
    private func keychainAccountName() -> String? {
        let (status, data) = runSecurityTool(["find-generic-password", "-s", OAuth.keychainService])
        guard status == 0, let text = String(data: data, encoding: .utf8) else { return nil }

        for line in text.split(separator: "\n") where line.contains("\"acct\"") {
            guard let valueStart = line.range(of: "=\"") else { continue }
            let rest = line[valueStart.upperBound...]
            if let valueEnd = rest.firstIndex(of: "\"") {
                return String(rest[..<valueEnd])
            }
        }
        return nil
    }

    private func readCredentials() -> Credentials? {
        let (status, data) = runSecurityTool(["find-generic-password", "-s", OAuth.keychainService, "-w"])
        guard status == 0,
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let oauth = payload["claudeAiOauth"] as? [String: Any],
              let accessToken = oauth["accessToken"] as? String,
              let refreshToken = oauth["refreshToken"] as? String else {
            return nil
        }

        return Credentials(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAtMilliseconds: (oauth["expiresAt"] as? NSNumber)?.doubleValue ?? 0,
            keychainAccount: keychainAccountName() ?? NSUserName(),
            fullPayload: payload
        )
    }

    private func writeCredentials(
        _ credentials: Credentials,
        accessToken: String,
        refreshToken: String,
        expiresAtMilliseconds: Double
    ) {
        var payload = credentials.fullPayload
        var oauth = (payload["claudeAiOauth"] as? [String: Any]) ?? [:]
        oauth["accessToken"] = accessToken
        oauth["refreshToken"] = refreshToken
        oauth["expiresAt"] = expiresAtMilliseconds
        payload["claudeAiOauth"] = oauth

        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        _ = runSecurityTool([
            "add-generic-password", "-U",
            "-s", OAuth.keychainService,
            "-a", credentials.keychainAccount,
            "-w", json,
        ])
    }

    // MARK: - Token Refresh

    private func refreshAccessToken(_ credentials: Credentials) async -> String? {
        var request = URLRequest(url: OAuth.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(OAuth.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(OAuth.betaHeader, forHTTPHeaderField: "anthropic-beta")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "grant_type": "refresh_token",
            "refresh_token": credentials.refreshToken,
            "client_id": OAuth.clientID,
        ])

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let newAccessToken = json["access_token"] as? String else {
            NSLog("CredentialStore: OAuth token refresh failed")
            return nil
        }

        let newRefreshToken = (json["refresh_token"] as? String) ?? credentials.refreshToken
        let expiresInSeconds = (json["expires_in"] as? Double) ?? 3600
        let newExpiry = Date().timeIntervalSince1970 * 1000 + expiresInSeconds * 1000

        writeCredentials(
            credentials,
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            expiresAtMilliseconds: newExpiry
        )
        return newAccessToken
    }
}
