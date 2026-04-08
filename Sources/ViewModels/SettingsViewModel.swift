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
    @Published var customCategories: [CustomCategory] = []
    @Published var customCategoryName: String = ""
    @Published var editingCategoryId: UUID?
    @Published var categoryErrorMessage: String?
    @Published var categorySuccessMessage: String?

    private let i18nService = I18nService.shared
    private let themeManager = ThemeManager.shared
    private let repository = PasswordRepository()

    init() {
        self.selectedLanguage = i18nService.currentLanguage
        self.selectedAppearance = themeManager.appearanceMode
        loadCustomCategories()
    }

    func updateLanguage(_ language: I18nService.Language) {
        i18nService.setLanguage(language)
        selectedLanguage = language
    }

    func updateAppearance(_ mode: AppearanceMode) {
        selectedAppearance = mode
        themeManager.setAppearance(mode)
    }

    func loadCustomCategories() {
        do {
            customCategories = try repository.fetchCustomCategories()
        } catch {
            categoryErrorMessage = error.localizedDescription
        }
    }

    func beginEditingCategory(_ category: CustomCategory) {
        editingCategoryId = category.id
        customCategoryName = category.name
        clearCategoryFeedback()
    }

    func cancelCategoryEditing() {
        editingCategoryId = nil
        customCategoryName = ""
        clearCategoryFeedback()
    }

    func saveCustomCategory() {
        clearCategoryFeedback()

        do {
            if let editingCategoryId {
                _ = try repository.updateCustomCategory(id: editingCategoryId, name: customCategoryName)
                categorySuccessMessage = "settings.category.feedback.updated".localized
            } else {
                _ = try repository.createCustomCategory(name: customCategoryName)
                categorySuccessMessage = "settings.category.feedback.created".localized
            }
            customCategoryName = ""
            self.editingCategoryId = nil
            loadCustomCategories()
        } catch {
            categoryErrorMessage = error.localizedDescription
        }
    }

    func deleteCustomCategory(_ category: CustomCategory) {
        clearCategoryFeedback()

        do {
            try repository.deleteCustomCategory(id: category.id)
            categorySuccessMessage = "settings.category.feedback.deleted".localized
            if editingCategoryId == category.id {
                editingCategoryId = nil
                customCategoryName = ""
            }
            loadCustomCategories()
        } catch {
            categoryErrorMessage = error.localizedDescription
        }
    }

    func clearCategoryFeedback() {
        categoryErrorMessage = nil
        categorySuccessMessage = nil
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
