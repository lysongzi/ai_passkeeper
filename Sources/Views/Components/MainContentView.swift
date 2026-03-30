import SwiftUI

// MARK: - Main Content Area

/// Redesigned main content area with toolbar
struct MainContentView: View {
    @ObservedObject var viewModel: PasswordListViewModel
    @Binding var selectedPasswordId: UUID?
    let onAddNew: () -> Void
    let onSettings: () -> Void
    let onLock: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 12) {
                // Add password button
                Button(action: onAddNew) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("main.addPassword".localized)
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .buttonStyle(PrimaryButtonStyle())

                // Settings button
                Button(action: onSettings) {
                    Image(systemName: "gearshape")
                        .font(.system(size: AppConstants.iconSizeMd))
                }
                .buttonStyle(SecondaryButtonStyle())

                // Lock button
                Button(action: onLock) {
                    Image(systemName: "lock")
                        .font(.system(size: AppConstants.iconSizeMd))
                }
                .buttonStyle(SecondaryButtonStyle())

                Spacer()

                // Theme toggle button
                ThemeToggleButton()
            }
            .padding(16)

            Divider()

            // Content area
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

/// Redesigned empty state with key icon
struct EmptyStateViewNew: View {
    let onAddNew: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Key icon with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary.opacity(0.15), AppColors.gradientOrange.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

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

            Button {
                onAddNew()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("main.addNewPassword".localized)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}