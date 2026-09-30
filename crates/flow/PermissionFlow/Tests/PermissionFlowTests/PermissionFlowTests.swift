import Foundation
import Testing
@testable import PermissionFlow
@testable import SystemSettingsKit

@Test
func paneURLsUseSecuritySettingsDeepLink() {
    #expect(
        PermissionFlowPane.fullDiskAccess.settingsURL.absoluteString ==
        "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AllFiles"
    )
}

@Test
func typedDisplaysAnchorBuildsDeepLink() {
    #expect(
        SystemSettingsDestination.displays(anchor: .resolutionSection).url.absoluteString ==
        "x-apple.systempreferences:com.apple.Displays-Settings.extension?resolutionSection"
    )
}

@Test
func localizerResolvesScriptSpecificCatalogues() {
    let key = "permission_flow.pane.input_monitoring"

    #expect(
        PermissionFlowLocalizer.string(key, defaultValue: "Input Monitoring", localeIdentifier: "zh-CN") ==
        "输入监控"
    )
    #expect(
        PermissionFlowLocalizer.string(key, defaultValue: "Input Monitoring", localeIdentifier: "zh-TW") ==
        "輸入監控"
    )
}

@Test
func chineseRegionsCarryTheirScriptBeforeTheLocaleLanguageAPI() {
    // `Locale.Language` is macOS 13+, so the macOS 12 path has to recover the
    // script from the region on its own or `zh-CN` and `zh-TW` would collapse
    // onto the same catalogue.
    #expect(PermissionFlowLocalizer.inferredScriptCode(for: Locale(identifier: "zh-CN")) == "Hans")
    #expect(PermissionFlowLocalizer.inferredScriptCode(for: Locale(identifier: "zh-SG")) == "Hans")
    #expect(PermissionFlowLocalizer.inferredScriptCode(for: Locale(identifier: "zh-TW")) == "Hant")
    #expect(PermissionFlowLocalizer.inferredScriptCode(for: Locale(identifier: "zh-HK")) == "Hant")
    #expect(PermissionFlowLocalizer.inferredScriptCode(for: Locale(identifier: "en-US")) == nil)
}

@Test
func thePrivacyPaneIdentifierFollowsTheRunningSystem() {
    // macOS 12 does not recognise the `com.apple.settings.*` privacy pane, and
    // a deeplink carrying it opens System Preferences at its root pane instead
    // of the permission, so the identifier is versioned.
    #expect(
        SystemSettingsDestination.privacyPaneIdentifier(isVenturaOrLater: true) ==
            "com.apple.settings.PrivacySecurity.extension"
    )
    #expect(
        SystemSettingsDestination.privacyPaneIdentifier(isVenturaOrLater: false) ==
            "com.apple.preference.security"
    )
}

@Test
func thePrivacyAnchorIsUnchangedAcrossSystems() {
    // Only the pane identifier moved in macOS 13; the anchors did not, so a
    // destination carries the same anchor on both.
    let anchor = SystemSettingsDestination.privacy(anchor: .privacyListenEvent)

    #expect(anchor.anchor == "Privacy_ListenEvent")
    #expect(
        anchor.url.absoluteString ==
            "x-apple.systempreferences:\(anchor.paneIdentifier ?? "")?Privacy_ListenEvent"
    )

    let monterey = SystemSettingsDestination(
        paneIdentifier: SystemSettingsDestination.privacyPaneIdentifier(isVenturaOrLater: false),
        anchor: PrivacySecurityAnchor.privacyListenEvent.rawValue
    )
    #expect(
        monterey.url.absoluteString ==
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
    )
}

@Test
@MainActor
func controllerAcceptsOnlyUniqueAppBundles() {
    let controller = PermissionFlowController()
    let appURL = URL(fileURLWithPath: "/Applications/Test.app")

    controller.registerDroppedApp(appURL)
    controller.registerDroppedApp(appURL)
    controller.registerDroppedApp(URL(fileURLWithPath: "/tmp/not-an-app.txt"))

    #expect(controller.droppedApps == [appURL])
}
