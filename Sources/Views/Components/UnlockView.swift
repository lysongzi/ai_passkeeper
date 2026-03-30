import SwiftUI
import AppKit

// MARK: - Unlock View

/// Redesigned unlock screen with gradient lock icon
struct UnlockView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 32) {
                Spacer()

                // Gradient lock icon
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.gradientPrimary.opacity(0.2), AppColors.gradientOrange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)

                        GradientIcon(systemName: "lock.fill", size: 48)
                    }

                    VStack(spacing: 8) {
                        Text("app.title".localized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.foreground)

                        Text("auth.enterPassword".localized)
                            .font(.subheadline)
                            .foregroundColor(AppColors.mutedForeground)
                    }
                }

                // Unlock form
                VStack(spacing: 20) {
                    StyledSecureField(
                        placeholder: "auth.password".localized,
                        text: $viewModel.primaryPassword
                    )
                    .onSubmit {
                        Task {
                            _ = await viewModel.unlockWithPassword()
                        }
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(AppColors.destructive)
                    }

                    Button {
                        Task {
                            _ = await viewModel.unlockWithPassword()
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryForeground))
                            } else {
                                Text("auth.unlock".localized)
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isLoading)

                    // Biometric option
                    if viewModel.isBiometricAvailable {
                        Button {
                            Task {
                                _ = await viewModel.unlockWithBiometric()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.biometricType.icon)
                                Text(viewModel.biometricType.displayName)
                            }
                            .font(.subheadline)
                            .foregroundColor(AppColors.primary)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                }
                .frame(maxWidth: 360)

                Spacer()
            }

            // Theme toggle button (top-right)
            ThemeToggleButton()
                .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

// MARK: - Setup View

/// Redesigned setup screen for first-time users
struct SetupViewNew: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 32) {
                Spacer()

                // Gradient lock icon
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.gradientPrimary.opacity(0.2), AppColors.gradientOrange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)

                        GradientIcon(systemName: "lock.shield.fill", size: 48)
                    }

                    VStack(spacing: 8) {
                        Text("auth.welcome".localized)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.foreground)

                        Text("auth.createVaultDesc".localized)
                            .font(.subheadline)
                            .foregroundColor(AppColors.mutedForeground)
                            .multilineTextAlignment(.center)
                    }
                }

                // Setup form
                VStack(spacing: 16) {
                    StyledSecureField(
                        placeholder: "auth.password".localized,
                        text: $viewModel.primaryPassword
                    )

                    StyledSecureField(
                        placeholder: "auth.confirmPassword".localized,
                        text: $viewModel.confirmPassword
                    )
                    .onSubmit {
                        Task {
                            _ = await viewModel.setupPrimaryPassword()
                        }
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(AppColors.destructive)
                    }

                    Text("auth.passwordMinLength".localized)
                        .font(.caption)
                        .foregroundColor(AppColors.mutedForeground)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        Task {
                            _ = await viewModel.setupPrimaryPassword()
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryForeground))
                            } else {
                                Text("auth.createVault".localized)
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isLoading)
                }
                .frame(maxWidth: 360)

                Spacer()
            }

            // Theme toggle button (top-right)
            ThemeToggleButton()
                .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}