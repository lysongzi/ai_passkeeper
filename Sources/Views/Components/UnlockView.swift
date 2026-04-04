import SwiftUI
import AppKit

// MARK: - Auth Visual Metrics

struct AuthScreenVisualMetrics: Equatable {
    let panelWidth: CGFloat
    let setupPanelWidth: CGFloat
    let heroSize: CGFloat
    let heroCornerRadius: CGFloat
    let heroIconSize: CGFloat
    let titleSize: CGFloat
    let subtitleSize: CGFloat
    let fieldHeight: CGFloat
    let buttonHeight: CGFloat
    let fieldCornerRadius: CGFloat
    let buttonCornerRadius: CGFloat
    let fieldHorizontalPadding: CGFloat
    let titleTopSpacing: CGFloat
    let subtitleTopSpacing: CGFloat
    let formTopSpacing: CGFloat
    let formSpacing: CGFloat
    let supportingSpacing: CGFloat
    let contentOffsetY: CGFloat

    static let prototype = AuthScreenVisualMetrics(
        panelWidth: 412,
        setupPanelWidth: 432,
        heroSize: 100,
        heroCornerRadius: 20,
        heroIconSize: 42,
        titleSize: 27,
        subtitleSize: 14,
        fieldHeight: 58,
        buttonHeight: 58,
        fieldCornerRadius: 17,
        buttonCornerRadius: 17,
        fieldHorizontalPadding: 20,
        titleTopSpacing: 22,
        subtitleTopSpacing: 9,
        formTopSpacing: 28,
        formSpacing: 13,
        supportingSpacing: 10,
        contentOffsetY: -34
    )
}

// MARK: - Unlock View

/// High-fidelity unlock screen aligned to prototype screenshots.
struct UnlockView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState

    private let metrics = AuthScreenVisualMetrics.prototype

    var body: some View {
        AuthScreenScaffold(metrics: metrics, panelWidth: metrics.panelWidth) {
            AuthHero(
                systemName: "lock.shield",
                title: "app.title".localized,
                subtitle: "auth.enterPassword".localized,
                metrics: metrics
            )

            AuthFormColumn(metrics: metrics) {
                AuthPasswordField(
                    placeholder: "auth.password".localized,
                    text: $viewModel.primaryPassword,
                    showsFocusRing: true,
                    metrics: metrics,
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
                    metrics: metrics,
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
                        HStack(spacing: 9) {
                            Image(systemName: viewModel.biometricType.icon)
                            Text(viewModel.biometricType.displayName)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.authSecondaryAction)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
            }
        }
    }
}

// MARK: - Setup View

/// High-fidelity setup screen sharing the same visual system as unlock.
struct SetupViewNew: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appState: AppState

    private let metrics = AuthScreenVisualMetrics.prototype

    var body: some View {
        AuthScreenScaffold(metrics: metrics, panelWidth: metrics.setupPanelWidth) {
            AuthHero(
                systemName: "lock.shield",
                title: "auth.welcome".localized,
                subtitle: "auth.createVaultDesc".localized,
                multilineSubtitle: true,
                metrics: metrics
            )

            AuthFormColumn(metrics: metrics) {
                AuthPasswordField(
                    placeholder: "auth.password".localized,
                    text: $viewModel.primaryPassword,
                    showsFocusRing: true,
                    metrics: metrics
                )

                AuthPasswordField(
                    placeholder: "auth.confirmPassword".localized,
                    text: $viewModel.confirmPassword,
                    metrics: metrics,
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
                    metrics: metrics,
                    action: {
                        Task {
                            _ = await viewModel.setupPrimaryPassword()
                        }
                    }
                )
                .disabled(viewModel.isLoading)

#if DEBUG
                AuthDebugShortcut(
                    title: "返回 Unlock",
                    helpText: "仅调试用：返回 Unlock 页面",
                    action: {
                        AppState.shared.isFirstLaunch = false
                        AppState.shared.isLocked = true
                    }
                )
                .padding(.top, 8)
#endif
            }
        }
    }
}

// MARK: - Shared Auth Primitives

private struct AuthScreenScaffold<Content: View>: View {
    let metrics: AuthScreenVisualMetrics
    let panelWidth: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 0) {
                    content
                }
                .frame(width: panelWidth)
                .frame(maxWidth: .infinity)
                .offset(y: metrics.contentOffsetY)

                Spacer(minLength: 0)
            }

#if DEBUG
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AuthDebugShortcut(
                        title: "调试 Setup",
                        helpText: "仅调试用：切换到 Setup 页面",
                        action: {
                            AppState.shared.lock()
                            AppState.shared.isFirstLaunch = true
                        }
                    )
                    .padding(.trailing, 18)
                    .padding(.bottom, 18)
                }
            }
#endif

            ThemeToggleButton()
                .padding(.top, 22)
                .padding(.trailing, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
private struct AuthDebugShortcut: View {
    let title: String
    let helpText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppColors.authSecondaryAction.opacity(0.92))
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(AppColors.card.opacity(0.58))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(AppColors.authFieldBorder.opacity(0.85), lineWidth: 0.9)
                )
        }
        .buttonStyle(.plain)
        .help(helpText)
    }
}
#endif

private struct AuthHero: View {
    let systemName: String
    let title: String
    let subtitle: String
    var multilineSubtitle: Bool = false
    let metrics: AuthScreenVisualMetrics

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: metrics.heroCornerRadius, style: .continuous)
                 .fill(
                    LinearGradient(
                        colors: [AppColors.gradientPrimary, AppColors.gradientOrange.opacity(0.96)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: metrics.heroSize, height: metrics.heroSize)
                .overlay {
                    Image(systemName: systemName)
                        .font(.system(size: metrics.heroIconSize, weight: .regular))
                        .foregroundColor(AppColors.primaryForeground)
                }
                .shadow(color: AppElevation.authHeroShadow, radius: 18, x: 0, y: 10)

            Text(title)
                .font(.system(size: metrics.titleSize, weight: .bold))
                .foregroundColor(AppColors.foreground)
                .kerning(-0.2)
                .padding(.top, metrics.titleTopSpacing)

            Text(subtitle)
                .font(.system(size: metrics.subtitleSize, weight: .semibold))
                .foregroundColor(AppColors.authSubtitle)
                .lineSpacing(1.5)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 312)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(multilineSubtitle ? nil : 2)
                .padding(.top, metrics.subtitleTopSpacing)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct AuthFormColumn<Content: View>: View {
    let metrics: AuthScreenVisualMetrics
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: metrics.formSpacing) {
            content
        }
        .padding(.top, metrics.formTopSpacing)
        .frame(maxWidth: .infinity)
    }
}

private struct AuthPasswordField: View {
    let placeholder: String
    @Binding var text: String
    var showsFocusRing: Bool = false
    let metrics: AuthScreenVisualMetrics
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        SecureField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(AppColors.foreground)
            .padding(.horizontal, metrics.fieldHorizontalPadding)
            .frame(height: metrics.fieldHeight)
            .frame(maxWidth: .infinity)
            .background(AppColors.authFieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: metrics.fieldCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: metrics.fieldCornerRadius, style: .continuous)
                    .stroke(showsFocusRing ? AppColors.authFieldBorderFocused : AppColors.authFieldBorder, lineWidth: showsFocusRing ? 1.8 : 1.3)
            )
            .shadow(color: AppElevation.authFieldShadow, radius: 6, x: 0, y: 2)
            .onSubmit {
                onSubmit?()
            }
    }
}

private struct AuthPrimaryActionButton: View {
    let title: String
    let isLoading: Bool
    let metrics: AuthScreenVisualMetrics
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryForeground))
                } else {
                    Text(title)
                }
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(AppColors.primaryForeground)
            .frame(height: metrics.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: metrics.buttonCornerRadius, style: .continuous)
                     .fill(
                    LinearGradient(
                        colors: [AppColors.gradientPrimary, AppColors.gradientOrange.opacity(0.96)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            )
            .shadow(color: AppElevation.authButtonShadow, radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .opacity(isLoading ? 0.92 : 1)
        .scaleEffect(isLoading ? 0.998 : 1)
    }
}

private struct AuthInlineMessage: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, -6)
    }
}
