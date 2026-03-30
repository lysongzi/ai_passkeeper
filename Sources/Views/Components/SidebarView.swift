import SwiftUI

// MARK: - Redesigned Sidebar View

/// Redesigned sidebar with shadcn/ui styling
struct SidebarViewNew: View {
    @ObservedObject var viewModel: PasswordListViewModel
    @Binding var selectedPasswordId: UUID?
    @Binding var showingSettings: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Search
            StyledTextField(
                placeholder: "main.search".localized,
                text: $viewModel.searchText,
                icon: "magnifyingglass"
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Password list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
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
            }
            .frame(maxHeight: .infinity)

            Divider()
                .padding(.horizontal, 16)

            // Category filter
            VStack(alignment: .leading, spacing: 4) {
                Text("main.categories".localized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.mutedForeground)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

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

            Divider()
                .padding(.horizontal, 16)
                .padding(.top, 8)

            // Settings button
            Button {
                showingSettings = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "gearshape")
                        .font(.system(size: AppConstants.iconSizeMd))
                    Text("settings.title".localized)
                        .font(.subheadline)
                }
                .foregroundColor(AppColors.sidebarForeground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.sidebarAccent)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            }
            .buttonStyle(.plain)
            .padding(16)
        }
        .frame(minWidth: AppConstants.sidebarMinWidth, idealWidth: AppConstants.sidebarWidth, maxWidth: AppConstants.sidebarMaxWidth)
        .background(AppColors.sidebar)
    }
}

// MARK: - Password Row New

/// Redesigned password row with selection state
struct PasswordRowNew: View {
    let item: DecryptedPasswordItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Category icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary.opacity(0.15), AppColors.gradientOrange.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: categoryIcon(for: item.category))
                    .font(.system(size: AppConstants.iconSizeSm))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary, AppColors.gradientOrange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Title and username
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.foreground)
                    .lineLimit(1)

                Text(item.username)
                    .font(.caption)
                    .foregroundColor(AppColors.mutedForeground)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isSelected ? AppColors.sidebarAccent : Color.clear)
        .contentShape(Rectangle())
    }
}

// MARK: - Category Row

/// Category row with icon
struct CategoryRow: View {
    let category: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: categoryIcon(for: category))
                .font(.system(size: AppConstants.iconSizeSm))
                .foregroundColor(isSelected ? AppColors.sidebarPrimary : AppColors.mutedForeground)
                .frame(width: 20)

            Text(category)
                .font(.subheadline)
                .foregroundColor(isSelected ? AppColors.sidebarPrimary : AppColors.sidebarForeground)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? AppColors.sidebarAccent : Color.clear)
        .contentShape(Rectangle())
    }
}