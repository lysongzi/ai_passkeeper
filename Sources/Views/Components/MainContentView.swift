import SwiftUI

// MARK: - Main Content Area

/// Redesigned main content area with toolbar - matches prototype
struct MainContentView: View {
    @ObservedObject var viewModel: PasswordListViewModel
    @Binding var selectedPasswordId: UUID?
    let onAddNew: () -> Void
    let onSettings: () -> Void
    let onLock: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar - matches prototype styling
            HStack(spacing: 12) {
                // Add password button - matches prototype
                Button(action: onAddNew) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text("main.addPassword".localized)
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.primaryForeground)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                }
                .buttonStyle(.plain)

                // Settings button - matches prototype
                Button(action: onSettings) {
                    Image(systemName: "gearshape")
                        .font(.system(size: AppConstants.iconSizeMd))
                        .foregroundColor(AppColors.foreground)
                        .frame(width: 36, height: 36)
                        .background(AppColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                }
                .buttonStyle(.plain)

                // Lock button - matches prototype
                Button(action: onLock) {
                    Image(systemName: "lock")
                        .font(.system(size: AppConstants.iconSizeMd))
                        .foregroundColor(AppColors.foreground)
                        .frame(width: 36, height: 36)
                        .background(AppColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                }
                .buttonStyle(.plain)

                Spacer()

                // Theme toggle button - matches prototype
                ThemeToggleButton()
            }
            .padding(12)
            .background(AppColors.card)

            Divider()

            // Content area - matches prototype
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
}

// MARK: - Empty State New

/// Redesigned empty state with key icon - matches prototype
struct EmptyStateViewNew: View {
    let onAddNew: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Key icon with gradient - matches prototype
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary.opacity(0.15), AppColors.gradientOrange.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)

                GradientIcon(systemName: "key.fill", size: 40)
            }

            VStack(spacing: 8) {
                Text("main.noPasswordSelected".localized)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.foreground)

                Text("main.noPasswordSelectedDesc".localized)
                    .font(.subheadline)
                    .foregroundColor(AppColors.mutedForeground)
                    .multilineTextAlignment(.center)
            }

            // Add button - matches prototype styling
            Button {
                onAddNew()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("main.addNewPassword".localized)
                }
                .font(.headline)
                .foregroundColor(AppColors.primaryForeground)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .frame(width: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}