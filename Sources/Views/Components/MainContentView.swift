import SwiftUI

// MARK: - Main Content Area

/// Rebuilt main content shell aligned to the RedesignUI prototype.
struct MainContentView: View {
    @ObservedObject var viewModel: PasswordListViewModel
    @Binding var selectedPasswordId: UUID?
    let onAddNew: () -> Void
    let onSettings: () -> Void
    let onLock: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            PKVaultToolbar(
                onAddNew: onAddNew,
                onSettings: onSettings,
                onLock: onLock
            )

            Divider()
                .overlay(AppColors.border)

            Group {
                if let selectedId = selectedPasswordId,
                   let selected = viewModel.passwords.first(where: { $0.id == selectedId }) {
                    PasswordDetailViewNew(
                        item: selected,
                        onDelete: {
                            Task {
                                await viewModel.deletePassword(selected)
                                selectedPasswordId = nil
                            }
                        },
                        onSave: {
                            Task {
                                await viewModel.loadPasswords()
                            }
                        }
                    )
                } else {
                    EmptyStateViewNew(onAddNew: onAddNew)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

// MARK: - Toolbar

private struct PKVaultToolbar: View {
    let onAddNew: () -> Void
    let onSettings: () -> Void
    let onLock: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Button(action: onAddNew) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "plus")
                    Text("main.addPassword".localized)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.primaryForeground)
                .padding(.horizontal, AppSpacing.lg)
                .frame(height: 34)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                .shadow(color: AppElevation.buttonShadow, radius: 3, x: 0, y: 1)
            }
            .buttonStyle(.plain)

            PKToolbarIconButton(systemName: "gearshape", action: onSettings)
            PKToolbarIconButton(systemName: "lock", action: onLock)

            Spacer()

            ThemeToggleButton()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, 10)
        .background(AppColors.card)
    }
}

private struct PKToolbarIconButton: View {
    let systemName: String
    let action: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: AppConstants.iconSizeMd, weight: .medium))
                .foregroundColor(AppColors.foreground)
                .frame(width: 34, height: 34)
                .background(buttonBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                        .stroke(buttonBorder, lineWidth: isHovered ? 1 : 0)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                .scaleEffect(isPressed ? 0.97 : 1)
                .animation(.easeOut(duration: 0.14), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var buttonBackground: Color {
        if isPressed {
            return AppColors.sidebarAccent
        }
        if isHovered {
            return AppColors.accent.opacity(0.92)
        }
        return AppColors.accent
    }

    private var buttonBorder: Color {
        isHovered ? AppColors.border.opacity(0.95) : .clear
    }
}

// MARK: - Empty State

/// Redesigned empty state with centered composition.
struct EmptyStateViewNew: View {
    let onAddNew: () -> Void

    var body: some View {
        VStack(spacing: 26) {
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.radiusXxl)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary.opacity(0.18), AppColors.gradientOrange.opacity(0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                GradientIcon(systemName: "key.fill", size: 34)
            }

            VStack(spacing: 10) {
                Text("main.noPasswordSelected".localized)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(AppColors.foreground)

                Text("main.noPasswordSelectedDesc".localized)
                    .font(.subheadline)
                    .foregroundColor(AppColors.mutedForeground)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 336)
            }

            Button(action: onAddNew) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "plus")
                    Text("main.addNewPassword".localized)
                }
                .font(.headline)
                .foregroundColor(AppColors.primaryForeground)
                .padding(.horizontal, 26)
                .frame(height: AppConstants.buttonHeight)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
                .shadow(color: AppElevation.buttonShadow, radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 32)
        .padding(.top, 12)
        .padding(.bottom, 54)
        .background(AppColors.background)
    }
}
