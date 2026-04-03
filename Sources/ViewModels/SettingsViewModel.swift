import Foundation
import SwiftUI
import AppKit

/// ViewModel for Settings screen
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var selectedLanguage: I18nService.Language
    @Published var selectedAppearance: AppearanceMode
    @Published var showingPasswordReset = false
    @Published var passwordResetError: String?
    @Published var passwordResetSuccess = false

    private let i18nService = I18nService.shared
    private let themeManager = ThemeManager.shared

    init() {
        self.selectedLanguage = i18nService.currentLanguage
        self.selectedAppearance = themeManager.appearanceMode
    }

    func updateLanguage(_ language: I18nService.Language) {
        i18nService.setLanguage(language)
        selectedLanguage = language
    }

    func updateAppearance(_ mode: AppearanceMode) {
        selectedAppearance = mode
        themeManager.setAppearance(mode)
    }

    func resetPassword(currentPassword: String, newPassword: String) async -> Bool {
        do {
            try await AppState.shared.changePrimaryPassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            passwordResetSuccess = true
            return true
        } catch {
            passwordResetError = error.localizedDescription
            return false
        }
    }
}

/// Appearance mode enum
@MainActor
enum AppearanceMode: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2

    nonisolated var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .system: return "settings.appearance.system".localized
        case .light: return "settings.appearance.light".localized
        case .dark: return "settings.appearance.dark".localized
        }
    }
}
