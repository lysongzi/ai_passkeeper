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

    var body: some View {
        PKModalContainer(onDismiss: { dismiss() }) {
            VStack(spacing: 0) {
                PKModalHeader(
                    title: route.title,
                    left: {
                        if route == .general {
                            Button("settings.cancel".localized) {
                                dismiss()
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(AppColors.mutedForeground)
                        } else {
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
                            PKIconButton(systemName: "xmark") {
                                dismiss()
                            }
                        } else {
                            Button("settings.reset".localized) {
                                Task {
                                    await resetPassword()
                                }
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.primaryForeground)
                            .padding(.horizontal, 16)
                            .frame(height: 34)
                            .background(isResetValid ? AppColors.primary : AppColors.muted)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                            .opacity(isResetting ? 0.86 : 1)
                            .disabled(!isResetValid || isResetting)
                        }
                    }
                )

                Divider()
                    .overlay(AppColors.border)

                Group {
                    switch route {
                    case .general:
                        settingsContent
                    case .resetPassword:
                        resetPasswordContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 572, height: 596)
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
                settingsSection(
                    title: "settings.general".localized,
                    rows: {
                        PKFormRowRightLabel("settings.language".localized, labelWidth: 120) {
                            settingsPicker(selection: $viewModel.selectedLanguage) {
                                ForEach(I18nService.Language.allCases) { language in
                                    Text(language.displayName).tag(language)
                                }
                            }
                            .onChange(of: viewModel.selectedLanguage) { newValue in
                                viewModel.updateLanguage(newValue)
                            }
                        }

                        PKFormRowRightLabel("settings.appearance".localized, labelWidth: 120) {
                            settingsPicker(selection: $viewModel.selectedAppearance) {
                                ForEach(AppearanceMode.allCases) { mode in
                                    Text(mode.displayName).tag(mode)
                                }
                            }
                            .onChange(of: viewModel.selectedAppearance) { newValue in
                                viewModel.updateAppearance(newValue)
                            }
                        }
                    }
                )

                settingsSection(
                    title: "settings.security".localized,
                    rows: {
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
                )
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 24)
        }
    }

    private var resetPasswordContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let feedback = feedbackMessage {
                    feedbackBanner(message: feedback.message, color: feedback.color)
                }

                settingsSection(
                    title: "settings.resetPassword".localized,
                    rows: {
                        resetPasswordField(
                            label: "settings.currentPassword".localized,
                            text: $currentPassword,
                            icon: "lock"
                        )

                        resetPasswordField(
                            label: "settings.newPassword".localized,
                            text: $newPassword,
                            icon: "key"
                        )

                        resetPasswordField(
                            label: "settings.confirmPassword".localized,
                            text: $confirmPassword,
                            icon: "checkmark.shield"
                        )
                    }
                )
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
                VStack(alignment: .leading, spacing: 14) {
                    rows()
                }
            }
        }
    }

    private func settingsPicker<SelectionValue: Hashable, Content: View>(
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Picker("", selection: selection) {
            content()
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .frame(width: 196, alignment: .trailing)
        .padding(.horizontal, 14)
        .frame(height: AppConstants.inputHeight)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }

    private func resetPasswordField(label: String, text: Binding<String>, icon: String) -> some View {
        PKFormRowRightLabel(label, labelWidth: 140, spacing: 16) {
            PKFieldContainer {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.mutedForeground)
                        .frame(width: 18)

                    SecureField(label, text: text)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .medium))
                }
            }
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

        let success = await viewModel.resetPassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        )

        if success {
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        }
    }

    private var isResetValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
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
}

private enum SettingsModalRoute {
    case general
    case resetPassword

    var title: String {
        switch self {
        case .general:
            return "settings.title".localized
        case .resetPassword:
            return "settings.resetPassword".localized
        }
    }
}
