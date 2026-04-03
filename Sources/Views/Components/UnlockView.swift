import SwiftUI
import AppKit

// MARK: - Unlock View

/// Redesigned unlock screen with centered single-column composition.
struct UnlockView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        AuthScreenScaffold {
            AuthHero(
                systemName: "lock.fill",
                title: "app.title".localized,
                subtitle: "auth.enterPassword".localized
            )

            AuthFormColumn {
                AuthPasswordField(
                    placeholder: "auth.password".localized,
                    text: $viewModel.primaryPassword,
                    showsFocusRing: true,
                    onSubmit: {
                        Task {
                            _ = await viewModel.unlockWithPassword()
                        }
                    }
                )

                if let error = viewModel.errorMessage {
                    AuthInlineMessage(text: error, color: AppColors.destructive)
                }

                AuthPrimaryActionButton(
                    title: "auth.unlock".localized,
                    isLoading: viewModel.isLoading,
                    action: {
                        Task {
                            _ = await viewModel.unlockWithPassword()
                        }
                    }
                )
                .disabled(viewModel.isLoading)

                if viewModel.isBiometricAvailable {
                    Button {
                        Task {
                            _ = await viewModel.unlockWithBiometric()
                        }
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: viewModel.biometricType.icon)
                            Text(viewModel.biometricType.displayName)
                        }
                        .font(.subheadline)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, AppSpacing.xs)
                }
            }
        }
    }
}

// MARK: - Setup View

/// Redesigned setup screen for first-time users.
struct SetupViewNew: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        AuthScreenScaffold {
            AuthHero(
                systemName: "lock.shield.fill",
                title: "auth.welcome".localized,
                subtitle: "auth.createVaultDesc".localized,
                multilineSubtitle: true
            )

            AuthFormColumn {
                AuthPasswordField(
                    placeholder: "auth.password".localized,
                    text: $viewModel.primaryPassword,
                    showsFocusRing: true
                )

                AuthPasswordField(
                    placeholder: "auth.confirmPassword".localized,
                    text: $viewModel.confirmPassword,
                    onSubmit: {
                        Task {
                            _ = await viewModel.setupPrimaryPassword()
                        }
                    }
                )

                if let error = viewModel.errorMessage {
                    AuthInlineMessage(text: error, color: AppColors.destructive)
                }

                AuthInlineMessage(
                    text: "auth.passwordMinLength".localized,
                    color: AppColors.mutedForeground
                )

                AuthPrimaryActionButton(
                    title: "auth.createVault".localized,
                    isLoading: viewModel.isLoading,
                    action: {
                        Task {
                            _ = await viewModel.setupPrimaryPassword()
                        }
                    }
                )
                .disabled(viewModel.isLoading)
            }
        }
    }
}

// MARK: - Shared Auth Primitives

private struct AuthScreenScaffold<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                Spacer(minLength: AppSpacing.xxxl)

                VStack(spacing: AppSpacing.xxxl) {
                    content
                }
                .frame(maxWidth: 420)
                .padding(.horizontal, AppSpacing.xxl)

                Spacer(minLength: AppSpacing.xxxl)
            }

            ThemeToggleButton()
                .padding(AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

private struct AuthHero: View {
    let systemName: String
    let title: String
    let subtitle: String
    var multilineSubtitle: Bool = false

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.radiusXxl)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary, AppColors.gradientOrange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 108, height: 108)
                    .shadow(color: AppElevation.buttonShadow, radius: 14, x: 0, y: 8)

                Image(systemName: systemName)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(AppColors.primaryForeground)
            }

            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppColors.foreground)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(AppColors.mutedForeground)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(multilineSubtitle ? nil : 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct AuthFormColumn<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            content
        }
        .frame(maxWidth: .infinity)
    }
}

private struct AuthPasswordField: View {
    let placeholder: String
    @Binding var text: String
    var showsFocusRing: Bool = false
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "lock")
                .foregroundColor(AppColors.mutedForeground)
                .frame(width: AppConstants.iconSizeMd)

            SecureField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.body)
                .onSubmit {
                    onSubmit?()
                }
        }
        .padding(.horizontal, AppSpacing.xl)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusXl)
                .stroke(showsFocusRing ? AppColors.primary.opacity(0.35) : AppColors.border, lineWidth: showsFocusRing ? 2 : 1)
        )
    }
}

private struct AuthPrimaryActionButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryForeground))
                } else {
                    Text(title)
                }
            }
            .font(.headline)
            .foregroundColor(AppColors.primaryForeground)
            .frame(height: AppConstants.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
            .shadow(color: AppElevation.buttonShadow, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct AuthInlineMessage: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
