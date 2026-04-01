import SwiftUI
import AppKit

// MARK: - Unlock View

/// Redesigned unlock screen with gradient lock icon - matches prototype
struct UnlockView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 32) {
                Spacer()

                // Gradient lock icon - matches prototype
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

                // Unlock form - matches prototype styling
                VStack(spacing: 20) {
                    // Password input field - matches prototype (rounded-2xl, primary border on focus)
                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .foregroundColor(AppColors.mutedForeground)
                            .frame(width: AppConstants.iconSizeMd)

                        SecureField("auth.password".localized, text: $viewModel.primaryPassword)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .onSubmit {
                                Task {
                                    _ = await viewModel.unlockWithPassword()
                                }
                            }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .frame(height: 56)
                    .background(AppColors.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.primary.opacity(0.3), lineWidth: 2)
                    )

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(AppColors.destructive)
                    }

                    // Unlock button - matches prototype (rounded-2xl with shadow)
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
                        .font(.headline)
                        .foregroundColor(AppColors.primaryForeground)
                        .frame(height: AppConstants.buttonHeight)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
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
                .frame(maxWidth: 400)
                .padding(.horizontal, 32)

                Spacer()
            }

            // Theme toggle button (top-right) - matches prototype
            ThemeToggleButton()
                .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

// MARK: - Setup View

/// Redesigned setup screen for first-time users - matches prototype
struct SetupViewNew: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 32) {
                Spacer()

                // Gradient lock icon - matches prototype
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

                // Setup form - matches prototype styling
                VStack(spacing: 16) {
                    // Password input field - matches prototype (rounded-2xl)
                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .foregroundColor(AppColors.mutedForeground)
                            .frame(width: AppConstants.iconSizeMd)

                        SecureField("auth.password".localized, text: $viewModel.primaryPassword)
                            .textFieldStyle(.plain)
                            .font(.body)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .frame(height: 56)
                    .background(AppColors.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.primary.opacity(0.3), lineWidth: 2)
                    )

                    // Confirm password input field - matches prototype
                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .foregroundColor(AppColors.mutedForeground)
                            .frame(width: AppConstants.iconSizeMd)

                        SecureField("auth.confirmPassword".localized, text: $viewModel.confirmPassword)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .onSubmit {
                                Task {
                                    _ = await viewModel.setupPrimaryPassword()
                                }
                            }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .frame(height: 56)
                    .background(AppColors.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.border, lineWidth: 1)
                    )

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(AppColors.destructive)
                    }

                    Text("auth.passwordMinLength".localized)
                        .font(.caption)
                        .foregroundColor(AppColors.mutedForeground)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Create vault button - matches prototype (rounded-2xl with shadow)
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
                        .font(.headline)
                        .foregroundColor(AppColors.primaryForeground)
                        .frame(height: AppConstants.buttonHeight)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isLoading)
                }
                .frame(maxWidth: 400)
                .padding(.horizontal, 32)

                Spacer()
            }

            // Theme toggle button (top-right) - matches prototype
            ThemeToggleButton()
                .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}