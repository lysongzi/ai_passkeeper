import SwiftUI

// MARK: - Settings View New

/// Redesigned settings view with shadcn/ui styling
struct SettingsViewNew: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var i18nService: I18nService
    @State private var showingResetSheet = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Settings modal
            VStack(spacing: 0) {
                // Header
                headerView

                Divider()

                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // General section
                        generalSection

                        Divider()
                            .padding(.horizontal, 16)

                        // Security section
                        securitySection
                    }
                    .padding(.vertical, 16)
                }
            }
            .frame(width: 480, height: 500)
            .background(AppColors.popover)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
            .shadow(color: Color.black.opacity(0.2), radius: 20)
        }
        .sheet(isPresented: $showingResetSheet) {
            PasswordResetViewNew(viewModel: viewModel)
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerView: some View {
        HStack {
            Spacer()

            Text("settings.title".localized)
                .font(.headline)
                .foregroundColor(AppColors.foreground)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.mutedForeground)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
    }

    // MARK: - General Section

    @ViewBuilder
    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("settings.general".localized)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.mutedForeground)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                // Language
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("settings.language".localized)
                            .font(.subheadline)
                            .foregroundColor(AppColors.foreground)

                        Text(I18nService.Language.allCases.first { $0 == viewModel.selectedLanguage }?.displayName ?? "")
                            .font(.caption)
                            .foregroundColor(AppColors.mutedForeground)
                    }

                    Spacer()

                    Picker("settings.language".localized, selection: $viewModel.selectedLanguage) {
                        ForEach(I18nService.Language.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.selectedLanguage) { newValue in
                        viewModel.updateLanguage(newValue)
                    }
                }
                .padding(16)

                Divider()
                    .padding(.leading, 16)

                // Appearance
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("settings.appearance".localized)
                            .font(.subheadline)
                            .foregroundColor(AppColors.foreground)

                        Text(AppearanceMode.allCases.first { $0 == viewModel.selectedAppearance }?.displayName ?? "")
                            .font(.caption)
                            .foregroundColor(AppColors.mutedForeground)
                    }

                    Spacer()

                    Picker("settings.appearance".localized, selection: $viewModel.selectedAppearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.selectedAppearance) { newValue in
                        viewModel.updateAppearance(newValue)
                    }
                }
                .padding(16)
            }
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.radiusLg)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Security Section

    @ViewBuilder
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("settings.security".localized)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.mutedForeground)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                Button {
                    showingResetSheet = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("settings.resetPassword".localized)
                                .font(.subheadline)
                                .foregroundColor(AppColors.foreground)

                            Text("settings.resetPasswordDesc".localized)
                                .font(.caption)
                                .foregroundColor(AppColors.mutedForeground)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.mutedForeground)
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.radiusLg)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Password Reset View New

/// Redesigned password reset view
struct PasswordResetViewNew: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isResetting = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button("settings.cancel".localized) {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(AppColors.mutedForeground)

                Spacer()

                Text("settings.resetPassword".localized)
                    .font(.headline)
                    .foregroundColor(AppColors.foreground)

                Spacer()

                Button("settings.reset".localized) {
                    resetPassword()
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(width: 80)
                .disabled(!isValid || isResetting)
            }

            Divider()

            // Form
            VStack(spacing: 16) {
                // Current password
                FormField(
                    label: "settings.currentPassword".localized,
                    placeholder: "settings.currentPassword".localized,
                    text: $currentPassword,
                    icon: "lock",
                    isSecure: true
                )

                // New password
                FormField(
                    label: "settings.newPassword".localized,
                    placeholder: "settings.newPassword".localized,
                    text: $newPassword,
                    icon: "lock",
                    isSecure: true
                )

                // Confirm password
                FormField(
                    label: "settings.confirmPassword".localized,
                    placeholder: "settings.confirmPassword".localized,
                    text: $confirmPassword,
                    icon: "lock",
                    isSecure: true
                )

                if showError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(AppColors.destructive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text("settings.passwordMinLength".localized)
                    .font(.caption)
                    .foregroundColor(AppColors.mutedForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)

            Spacer()
        }
        .frame(width: 400, height: 450)
        .background(AppColors.popover)
    }

    private var isValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword.count >= 8 &&
        newPassword == confirmPassword
    }

    private func resetPassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "settings.passwordMismatch".localized
            showError = true
            return
        }

        guard newPassword.count >= 8 else {
            errorMessage = "settings.passwordTooShort".localized
            showError = true
            return
        }

        isResetting = true
        showError = false

        Task {
            do {
                try await AppState.shared.changePrimaryPassword(
                    currentPassword: currentPassword,
                    newPassword: newPassword
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isResetting = false
                }
            }
        }
    }
}