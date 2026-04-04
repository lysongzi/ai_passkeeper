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
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 14)
            .background(AppColors.background)

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
                        onSave: { updatedItem in
                            await viewModel.updatePassword(updatedItem)
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
        HStack(spacing: 10) {
            Button(action: onAddNew) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                    Text("main.addPassword".localized)
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.primaryForeground)
                .padding(.horizontal, 16)
                .frame(height: 34)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .shadow(color: AppElevation.buttonShadow, radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)

            PKToolbarIconButton(systemName: "gearshape", action: onSettings)
            PKToolbarIconButton(systemName: "lock", action: onLock)

            Spacer(minLength: 18)

            ThemeToggleButton()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: AppElevation.windowShadow.opacity(0.55), radius: 10, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
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
                .frame(width: 32, height: 32)
                .background(buttonBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                        .stroke(buttonBorder, lineWidth: isHovered ? 1 : 0.8)
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
            return AppColors.sidebarAccent.opacity(0.92)
        }
        return AppColors.accent
    }

    private var buttonBorder: Color {
        isHovered ? AppColors.border.opacity(0.95) : AppColors.border.opacity(0.5)
    }
}

// MARK: - Empty State

/// Redesigned empty state with centered composition.
struct EmptyStateViewNew: View {
    let onAddNew: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.radiusXxl)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary.opacity(0.13), AppColors.gradientOrange.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)

                GradientIcon(systemName: "key.fill", size: 32)
            }

            VStack(spacing: 10) {
                Text("main.noPasswordSelected".localized)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(AppColors.foreground)

                Text("main.noPasswordSelectedDesc".localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.mutedForeground)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
            }

            Button(action: onAddNew) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("main.addNewPassword".localized)
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryForeground)
                .padding(.horizontal, 18)
                .frame(height: 38)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: AppElevation.buttonShadow, radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 32)
        .padding(.top, 8)
        .padding(.bottom, 62)
        .background(AppColors.background)
    }
}
