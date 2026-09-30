#if os(macOS)
import Foundation

@available(macOS 12.0, *)
enum PermissionFlowLocalizer {
    /// Resolves a localized string from the best matching `.lproj` bundle for
    /// the injected locale. This keeps all custom locale selection in one
    /// place, while still letting the rest of the UI use plain localization
    /// keys and format strings.
    static func string(
        _ key: String,
        defaultValue: String,
        localeIdentifier: String?
    ) -> String {
        localizedBundle(for: localeIdentifier)?
            .localizedString(forKey: key, value: defaultValue, table: nil)
            ?? Bundle.module.localizedString(forKey: key, value: defaultValue, table: nil)
    }

    private static func localizedBundle(for localeIdentifier: String?) -> Bundle? {
        guard let localeIdentifier, localeIdentifier.isEmpty == false else {
            return nil
        }

        let preferences = localizationPreferences(for: localeIdentifier)
        guard let localization = Bundle.preferredLocalizations(
            from: Bundle.module.localizations,
            forPreferences: preferences
        ).first,
        let path = Bundle.module.path(forResource: localization, ofType: "lproj") else {
            return nil
        }

        return Bundle(path: path)
    }

    private static func localizationPreferences(for localeIdentifier: String) -> [String] {
        let normalizedIdentifier = localeIdentifier.replacingOccurrences(of: "_", with: "-")
        let locale = Locale(identifier: normalizedIdentifier)

        var preferences = [normalizedIdentifier]
        if let identifier = languageCode(of: locale) {
            if let script = scriptCode(of: locale) {
                preferences.append("\(identifier)-\(script)")
            }
            preferences.append(identifier)
        }

        return Array(NSOrderedSet(array: preferences)) as? [String] ?? preferences
    }

    @available(macOS 13, *)
    private static func modernLanguageCode(of locale: Locale) -> String? {
        locale.language.languageCode?.identifier
    }

    @available(macOS 13, *)
    private static func modernScriptCode(of locale: Locale) -> String? {
        locale.language.script?.identifier
    }

    private static func languageCode(of locale: Locale) -> String? {
        if #available(macOS 13, *) {
            return modernLanguageCode(of: locale)
        }
        return locale.languageCode
    }

    private static func scriptCode(of locale: Locale) -> String? {
        if #available(macOS 13, *) {
            return modernScriptCode(of: locale)
        }
        return locale.scriptCode ?? inferredScriptCode(for: locale)
    }

    /// `Locale.Language` is macOS 13+, and before it the script is only known
    /// when the identifier names one. The Chinese catalogues are the only ones
    /// in this package that are split by script, so their regions are mapped
    /// here to keep `zh-CN` and `zh-TW` on the matching catalogue.
    static func inferredScriptCode(for locale: Locale) -> String? {
        switch locale.regionCode {
        case "CN", "SG": "Hans"
        case "TW", "HK", "MO": "Hant"
        default: nil
        }
    }
}
#endif
