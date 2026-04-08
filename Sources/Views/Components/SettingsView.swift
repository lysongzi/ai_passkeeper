import SwiftUI

// MARK: - Settings View New

/// Redesigned settings modal aligned to the RedesignUI prototype.
struct SettingsViewNew: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var i18nService: I18nService
    @Environment(\.dismiss) private var dismiss
    @State private var route: SettingsModalRoute = .general
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isResetting = false
    let onCategoriesChanged: (() async -> Void)?

    init(onCategoriesChanged: (() async -> Void)? = nil) {
        self.onCategoriesChanged = onCategoriesChanged
    }

    private var languageOptions: [String] {
        I18nService.Language.allCases.map { $0.displayName }
    }
    private var appearanceOptions: [String] {
        AppearanceMode.allCases.map { $0.displayName }
    }
    private var languageSelection: Binding<String> {
        Binding(
            get: { viewModel.selectedLanguage.displayName },
            set: { name in
                if let lang = I18nService.Language.allCases.first(where: { $0.displayName == name }) {
                    viewModel.updateLanguage(lang)
                }
            }
        )
    }
    private var appearanceSelection: Binding<String> {
        Binding(
            get: { viewModel.selectedAppearance.displayName },
            set: { name in
                if let mode = AppearanceMode.allCases.first(where: { $0.displayName == name }) {
                    viewModel.updateAppearance(mode)
                }
            }
        )
    }

    var body: some View {
        PKModalContainer(onDismiss: { dismiss() }) {
            VStack(spacing: 0) {
                PKModalHeader(
                    title: route.title,
                    left: {
                        if route == .resetPassword {
                            Button {
                                withAnimation(.easeInOut(duration: 0.18)) {
                                    clearResetFeedback()
                                    route = .general
                                }
                            } label: {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: "chevron.left")
                                    Text("settings.back".localized)
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppColors.mutedForeground)
                            }
                            .buttonStyle(.plain)
                        }
                    },
                    right: {
                        if route == .general {
                            PKIconButton(systemName: "xmark") { dismiss() }
                        } else {
                            PKModalActionButton(
                                title: "settings.reset".localized,
                                isEnabled: isResetValid,
                                isLoading: isResetting
                            ) { Task { await resetPassword() } }
                        }
                    }
                )

                Divider().overlay(AppColors.border)

                Group {
                    switch route {
                    case .general: settingsContent
                    case .resetPassword: resetPasswordContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 572, height: 640)
            .background(AppColors.popover)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: AppElevation.modalShadow, radius: 22, x: 0, y: 10)
        }
    }

    private var settingsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                settingsSection(title: "settings.general".localized) {
                    settingsFieldSection(title: "settings.language".localized) {
                        PKCategoryPicker(categories: languageOptions, selection: languageSelection, showIcons: false)
                    }
                    settingsFieldSection(title: "settings.appearance".localized) {
                        PKCategoryPicker(categories: appearanceOptions, selection: appearanceSelection, showIcons: false)
                    }
                }

                settingsSection(title: "settings.category.section".localized) {
                    if let feedback = categoryFeedbackMessage {
                        feedbackBanner(message: feedback.message, color: feedback.color)
                    }

                    settingsFieldSection(title: "settings.category.field".localized) {
                        VStack(alignment: .leading, spacing: 10) {
                            PKFieldContainer {
                                TextField(text: $viewModel.customCategoryName, prompt: Text("settings.category.placeholder".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 14, weight: .medium))
                            }

                            HStack(spacing: AppSpacing.sm) {
                                Button(viewModel.editingCategoryId == nil ? "settings.category.add".localized : "settings.category.save".localized) {
                                    viewModel.saveCustomCategory()
                                    Task { await onCategoriesChanged?() }
                                }
                                .buttonStyle(PrimaryButtonStyle())

                                if viewModel.editingCategoryId != nil {
                                    Button("settings.category.cancel".localized) {
                                        viewModel.cancelCategoryEditing()
                                    }
                                    .buttonStyle(DetailActionButtonStyle())
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.customCategories) { category in
                            HStack(spacing: 12) {
                                PKFieldContainer {
                                    Text(category.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppColors.foreground)
                                }
                                Button("settings.category.edit".localized) {
                                    viewModel.beginEditingCategory(category)
                                }
                                .buttonStyle(DetailActionButtonStyle())

                                Button("settings.category.delete".localized) {
                                    viewModel.deleteCustomCategory(category)
                                    Task { await onCategoriesChanged?() }
                                }
                                .buttonStyle(DestructiveButtonStyle())
                            }
                        }
                    }
                }

                settingsSection(title: "settings.security".localized) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            clearResetFeedback()
                            route = .resetPassword
                        }
                    } label: {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("settings.resetPassword".localized)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.foreground)
                                Text("settings.resetPasswordDesc".localized)
                                    .font(.caption)
                                    .foregroundColor(AppColors.mutedForeground)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.mutedForeground)
                        }
                        .padding(.horizontal, 14)
                        .frame(minHeight: AppConstants.inputHeight)
                        .background(AppColors.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 24)
        }
    }

    private var resetPasswordContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let feedback = feedbackMessage {
                    feedbackBanner(message: feedback.message, color: feedback.color)
                }

                settingsFieldSection(title: "settings.currentPassword".localized) {
                    PKFieldContainer {
                        SecureField(text: $currentPassword, prompt: Text("settings.placeholder.currentPassword".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                settingsFieldSection(title: "settings.newPassword".localized) {
                    PKFieldContainer {
                        SecureField(text: $newPassword, prompt: Text("settings.placeholder.newPassword".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                settingsFieldSection(title: "settings.confirmPassword".localized) {
                    PKFieldContainer {
                        SecureField(text: $confirmPassword, prompt: Text("settings.placeholder.confirmPassword".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 24)
        }
    }

    private func settingsSection<Rows: View>(title: String, @ViewBuilder rows: () -> Rows) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.2)
                .foregroundColor(AppColors.mutedForeground)

            PKMetadataPanel {
                VStack(alignment: .leading, spacing: 14) { rows() }
            }
        }
    }

    private func settingsFieldSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.2)
                .foregroundColor(AppColors.mutedForeground)
            content()
        }
    }

    private func feedbackBanner(message: String, color: Color) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                    .stroke(color.opacity(0.22), lineWidth: 1)
            )
    }

    private func clearResetFeedback() {
        viewModel.passwordResetError = nil
        viewModel.passwordResetSuccess = false
    }

    private func resetPassword() async {
        clearResetFeedback()
        isResetting = true
        defer { isResetting = false }

        let success = await viewModel.resetPassword(currentPassword: currentPassword, newPassword: newPassword)
        if success {
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        }
    }

    private var isResetValid: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && newPassword == confirmPassword && newPassword.count >= 6
    }

    private var feedbackMessage: (message: String, color: Color)? {
        if let error = viewModel.passwordResetError, !error.isEmpty {
            return (error, AppColors.destructive)
        }
        if viewModel.passwordResetSuccess {
            return ("settings.resetSuccess".localized, AppColors.primary)
        }
        if !confirmPassword.isEmpty && confirmPassword != newPassword {
            return ("settings.passwordMismatch".localized, AppColors.destructive)
        }
        return nil
    }

    private var categoryFeedbackMessage: (message: String, color: Color)? {
        if let error = viewModel.categoryErrorMessage, !error.isEmpty {
            return (error, AppColors.destructive)
        }
        if let success = viewModel.categorySuccessMessage, !success.isEmpty {
            return (success, AppColors.primary)
        }
        return nil
    }
}

private enum SettingsModalRoute {
    case general
    case resetPassword

    var title: String {
        switch self {
        case .general: return "settings.title".localized
        case .resetPassword: return "settings.resetPassword".localized
        }
    }
}
