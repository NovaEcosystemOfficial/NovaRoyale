import Foundation
import Observation
import SwiftUI

enum AppLanguageCode: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case italian = "it"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .italian: return "Italiano"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }
}

@MainActor
@Observable
final class AppLanguage {
    static let shared = AppLanguage()

    private let storageKey = "royalcompanion.language"

    var code: AppLanguageCode {
        didSet {
            UserDefaults.standard.set(code.rawValue, forKey: storageKey)
        }
    }

    var locale: Locale { code.locale }

    private init() {
        if let stored = UserDefaults.standard.string(forKey: storageKey),
           let code = AppLanguageCode(rawValue: stored) {
            self.code = code
        } else {
            let preferred = Locale.current.language.languageCode?.identifier ?? "en"
            self.code = preferred.hasPrefix("it") ? .italian : .english
        }
    }

    func text(_ key: String) -> String {
        Self.localized(key, language: code)
    }

    static func localized(_ key: String, language: AppLanguageCode) -> String {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
    }
}

extension View {
    func royalLocalized(_ language: AppLanguage) -> some View {
        self.environment(\.locale, language.locale)
            .id(language.code.rawValue)
    }
}

@MainActor
enum L10n {
    static func t(_ key: String, _ language: AppLanguage) -> String {
        language.text(key)
    }

    static func format(_ key: String, _ language: AppLanguage, _ args: CVarArg...) -> String {
        let format = language.text(key)
        return String(format: format, locale: language.locale, arguments: args)
    }
}
