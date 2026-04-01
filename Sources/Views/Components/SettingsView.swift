import SwiftUI

// MARK: - Settings View New

/// Redesigned settings view with shadcn/ui styling - matches prototype
struct SettingsViewNew: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var i18nService: I18nService
    @State private var showingResetSheet = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
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
                        generalSection
                        Divider().padding(.horizontal, 16)
                        securitySection
                    }
                    .padding(.vertical, 16)
                }
            }
            .frame(width: 520, height: 540)
            .background(AppColors.popover)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.foreground)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
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

            // Card container
            VStack(spacing: 0) {
                languageRow
                Divider().padding(.leading, 16)
                appearanceRow
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

    @ViewBuilder
    private var languageRow: some View {
        HStack {
            Text("settings.language".localized)
                .font(.subheadline)
                .foregroundColor(AppColors.foreground)
            Spacer()
            languagePicker
        }
        .padding(16)
    }

    @ViewBuilder
    private var languagePicker: some View {
        Picker("", selection: $viewModel.selectedLanguage) {
            ForEach(I18nService.Language.allCases) { language in
                Text(language.displayName).tag(language)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: viewModel.selectedLanguage) { newValue in
            viewModel.updateLanguage(newValue)
        }
    }

    @ViewBuilder
    private var appearanceRow: some View {
        HStack {
            Text("settings.appearance".localized)
                .font(.subheadline)
                .foregroundColor(AppColors.foreground)
            Spacer()
            appearancePicker
        }
        .padding(16)
    }

    @ViewBuilder
    private var appearancePicker: some View {
        Picker("", selection: $viewModel.selectedAppearance) {
            ForEach(AppearanceMode.allCases) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: viewModel.selectedAppearance) { newValue in
            viewModel.updateAppearance(newValue)
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
                        Text("settings.resetPassword".localized)
                            .font(.subheadline)
                            .foregroundColor(AppColors.foreground)
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
        VStack(spacing: 0) {
            // Header
            resetHeader
            Divider()

            // Form
            resetForm
            Spacer()
        }
        .frame(width: 440, height: 480)
        .background(AppColors.popover)
    }

    @ViewBuilder
    private var resetHeader: some View {
        HStack {
            Button("settings.cancel".localized) {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundColor(AppColors.mutedForeground)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.accent)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Spacer()

            Text("settings.resetPassword".localized)
                .font(.headline)
                .foregroundColor(AppColors.foreground)

            Spacer()

            Button("settings.reset".localized) {
                resetPassword()
            }
            .font(.headline)
            .foregroundColor(AppColors.primaryForeground)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isValid ? AppColors.primary : AppColors.muted)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(!isValid || isResetting)
        }
        .padding(16)
    }

    @ViewBuilder
    private var resetForm: some View {
        VStack(spacing: 16) {
            // Current password
            passwordField(
                label: "settings.currentPassword".localized,
                text: $currentPassword
            )

            // New password
            passwordField(
                label: "settings.newPassword".localized,
                text: $newPassword
            )

            // Confirm password
            passwordField(
                label: "settings.confirmPassword".localized,
                text: $confirmPassword
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
    }

    @ViewBuilder
    private func passwordField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.foreground)

            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundColor(AppColors.mutedForeground)
                    .frame(width: AppConstants.iconSizeMd)

                SecureField(label, text: text)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(height: AppConstants.inputHeight)
            .background(AppColors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(label == "settings.currentPassword".localized ? AppColors.primary.opacity(0.3) : AppColors.border, lineWidth: label == "settings.currentPassword".localized ? 2 : 1)
            )
        }
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