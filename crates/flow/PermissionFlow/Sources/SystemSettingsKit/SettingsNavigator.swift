#if os(macOS)
import AppKit

@available(macOS 12.0, *)
@MainActor
final class SettingsNavigator {
    private let bundleIdentifier = "com.apple.systempreferences"

    /// Installed locations of the settings application. macOS 13 renamed System
    /// Preferences to System Settings and moved it, so the older path is still
    /// needed for the macOS versions this package supports.
    private let applicationURLs = [
        URL(fileURLWithPath: "/System/Applications/System Settings.app"),
        URL(fileURLWithPath: "/System/Applications/System Preferences.app")
    ]

    /// Opens System Settings with a generic deeplink URL.
    @discardableResult
    func openSettings(at url: URL) -> Bool {
        if let applicationURL {
            NSWorkspace.shared.openApplication(
                at: applicationURL,
                configuration: NSWorkspace.OpenConfiguration()
            ) { _, _ in }
        }

        let didOpen = NSWorkspace.shared.open(url)
        activateSettings()
        return didOpen
    }

    /// Resolves the running settings application first so an unusual install
    /// location still works, then falls back to the known system paths.
    private var applicationURL: URL? {
        let running = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .compactMap(\.bundleURL)
        return (running + applicationURLs)
            .first { FileManager.default.fileExists(atPath: $0.path) }
    }

    /// Re-activates the running System Settings process if it already exists.
    func activateSettings() {
        NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
            .first?
            .activate(options: [.activateIgnoringOtherApps])
    }
}
#elseif os(iOS)
import UIKit

@available(iOS 16.0, *)
@MainActor
final class SettingsNavigator {
    /// Opens the destination URL through UIKit. iOS support is intentionally
    /// limited to URLs that the platform publicly allows.
    @discardableResult
    func openSettings(at url: URL) -> Bool {
        guard UIApplication.shared.canOpenURL(url) else { return false }
        UIApplication.shared.open(url)
        return true
    }
}
#endif
