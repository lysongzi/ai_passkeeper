import SwiftUI

// MARK: - Redesigned Sidebar View

/// Rebuilt sidebar aligned to the RedesignUI prototype.
struct SidebarViewNew: View {
    @ObservedObject var viewModel: PasswordListViewModel
    @Binding var selectedPasswordId: UUID?
    @Binding var showingSettings: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            StyledTextField(
                placeholder: "main.search".localized,
                text: $viewModel.searchText,
                icon: "magnifyingglass"
            )
            .padding(.horizontal, AppSpacing.sm)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.md)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(viewModel.passwords, id: \.id) { item in
                        PasswordRowNew(
                            item: item,
                            isSelected: selectedPasswordId == item.id
                        )
                        .onTapGesture {
                            selectedPasswordId = item.id
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.bottom, AppSpacing.lg)
            }
            .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Divider()
                    .overlay(AppColors.sidebarBorder)
                    .padding(.horizontal, AppSpacing.sm)

                Text("main.categories".localized)
                    .font(.caption.weight(.medium))
                    .foregroundColor(AppColors.mutedForeground)
                    .padding(.horizontal, AppSpacing.md)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        CategoryRow(
                            category: category,
                            isSelected: viewModel.selectedCategory == category
                        )
                        .onTapGesture {
                            Task {
                                await viewModel.filterByCategory(category)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.sm)
            }
            .padding(.bottom, AppSpacing.sm)

            Divider()
                .overlay(AppColors.sidebarBorder)
                .padding(.horizontal, AppSpacing.sm)

            Button {
                showingSettings = true
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "gearshape")
                        .font(.system(size: AppConstants.iconSizeMd, weight: .medium))
                    Text("settings.title".localized)
                        .font(.subheadline.weight(.medium))
                }
                .foregroundColor(AppColors.sidebarForeground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.md)
                .frame(height: 44)
                .background(AppColors.sidebarAccent)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            }
            .buttonStyle(.plain)
            .padding(AppSpacing.sm)
        }
        .frame(minWidth: AppConstants.sidebarMinWidth, idealWidth: AppConstants.sidebarWidth, maxWidth: AppConstants.sidebarMaxWidth)
        .background(AppColors.sidebar)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(AppColors.sidebarBorder)
                .frame(width: 1)
        }
    }
}

// MARK: - Password Row New

/// Redesigned password row with prototype-like selected state.
struct PasswordRowNew: View {
    let item: DecryptedPasswordItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary.opacity(0.16), AppColors.gradientOrange.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: categoryIcon(for: item.category))
                    .font(.system(size: AppConstants.iconSizeSm, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary, AppColors.gradientOrange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(AppColors.sidebarForeground)
                    .lineLimit(1)

                Text(item.username)
                    .font(.caption)
                    .foregroundColor(AppColors.mutedForeground)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 10)
        .background(selectionBackground)
        .overlay(selectionBorder)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
        .contentShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
    }

    private var selectionBackground: some View {
        RoundedRectangle(cornerRadius: AppConstants.radiusLg)
            .fill(isSelected ? AppColors.sidebarAccent : Color.clear)
    }

    private var selectionBorder: some View {
        RoundedRectangle(cornerRadius: AppConstants.radiusLg)
            .stroke(isSelected ? AppColors.primary.opacity(0.55) : Color.clear, lineWidth: 1.5)
    }
}

// MARK: - Category Row

/// Category row with icon.
struct CategoryRow: View {
    let category: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: categoryIcon(for: category))
                .font(.system(size: AppConstants.iconSizeSm, weight: .medium))
                .foregroundColor(isSelected ? AppColors.sidebarPrimary : AppColors.mutedForeground)
                .frame(width: 20)

            Text(category)
                .font(.subheadline)
                .foregroundColor(isSelected ? AppColors.sidebarPrimary : AppColors.sidebarForeground)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                .fill(isSelected ? AppColors.sidebarAccent : Color.clear)
        )
        .contentShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
    }
}
