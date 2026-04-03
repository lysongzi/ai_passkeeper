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

            SidebarSettingsButton {
                showingSettings = true
            }
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
private struct SidebarInteractiveBackground: View {
    let isSelected: Bool
    let isHovered: Bool
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundFill)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: isSelected ? 1.5 : (isHovered ? 1 : 0))
            )
    }

    private var backgroundFill: Color {
        if isSelected {
            return AppColors.sidebarAccent
        }
        if isHovered {
            return AppColors.sidebarAccent.opacity(0.52)
        }
        return .clear
    }

    private var borderColor: Color {
        if isSelected {
            return AppColors.primary.opacity(0.64)
        }
        if isHovered {
            return AppColors.sidebarBorder.opacity(0.82)
        }
        return .clear
    }
}

private struct SidebarSettingsButton: View {
    let action: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "gearshape")
                    .font(.system(size: AppConstants.iconSizeMd, weight: .medium))
                Text("settings.title".localized)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(AppColors.sidebarForeground)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 42)
            .background(
                SidebarInteractiveBackground(
                    isSelected: false,
                    isHovered: isHovered || isPressed,
                    cornerRadius: AppConstants.radiusMd
                )
            )
            .scaleEffect(isPressed ? 0.985 : 1)
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
}

struct PasswordRowNew: View {
    let item: DecryptedPasswordItem
    let isSelected: Bool
    @State private var isHovered = false

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

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.sidebarForeground)
                    .lineLimit(1)

                Text(item.username)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.mutedForeground)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 11)
        .background(
            SidebarInteractiveBackground(
                isSelected: isSelected,
                isHovered: isHovered,
                cornerRadius: AppConstants.radiusLg
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
        .contentShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Category Row

/// Category row with icon.
struct CategoryRow: View {
    let category: String
    let isSelected: Bool
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: categoryIcon(for: category))
                .font(.system(size: AppConstants.iconSizeSm, weight: .medium))
                .foregroundColor(isSelected ? AppColors.sidebarPrimary : AppColors.mutedForeground)
                .frame(width: 20)

            Text(category)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? AppColors.sidebarPrimary : AppColors.sidebarForeground)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 38)
        .background(
            SidebarInteractiveBackground(
                isSelected: isSelected,
                isHovered: isHovered,
                cornerRadius: AppConstants.radiusMd
            )
        )
        .contentShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
