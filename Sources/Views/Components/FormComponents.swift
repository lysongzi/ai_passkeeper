import SwiftUI

// MARK: - PK Form Primitives

/// Form row with a right-aligned fixed-width label and custom trailing field content.
struct PKFormRowRightLabel<Field: View>: View {
    let label: String
    let labelWidth: CGFloat
    let spacing: CGFloat
    let verticalAlignment: VerticalAlignment
    let field: Field

    init(
        _ label: String,
        labelWidth: CGFloat = 110,
        spacing: CGFloat = AppSpacing.md,
        verticalAlignment: VerticalAlignment = .center,
        @ViewBuilder field: () -> Field
    ) {
        self.label = label
        self.labelWidth = labelWidth
        self.spacing = spacing
        self.verticalAlignment = verticalAlignment
        self.field = field()
    }

    var body: some View {
        HStack(alignment: verticalAlignment, spacing: spacing) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.mutedForeground)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: labelWidth, alignment: .trailing)

            field
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Static/dynamic field surface container usable for detail display and embedded controls.
struct PKFieldContainer<Content: View>: View {
    let minHeight: CGFloat
    let content: Content

    init(minHeight: CGFloat = AppConstants.inputHeight, @ViewBuilder content: () -> Content) {
        self.minHeight = minHeight
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
            .padding(.horizontal, 14)
            .background(AppColors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}

/// Full-width picker with styled input appearance (background + border + rounded corners).
/// Uses a custom Button + popover so the dropdown width matches the button width.
/// Set `showIcons: false` for plain text options (e.g. language, appearance settings).
struct PKCategoryPicker: View {
    let categories: [String]
    @Binding var selection: String
    var showIcons: Bool = true

    @State private var isExpanded = false
    @State private var buttonWidth: CGFloat = 0

    var body: some View {
        Button {
            isExpanded.toggle()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                if showIcons {
                    Image(systemName: categoryIcon(for: selection))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.sidebarPrimary)
                }

                Text(selection)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.foreground)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.mutedForeground)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: AppConstants.inputHeight, alignment: .leading)
            .background(AppColors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: PKPickerWidthKey.self, value: geo.size.width)
                }
            )
        }
        .buttonStyle(.plain)
        .onPreferenceChange(PKPickerWidthKey.self) { buttonWidth = $0 }
        .popover(isPresented: $isExpanded, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selection = category
                        isExpanded = false
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            if showIcons {
                                Image(systemName: categoryIcon(for: category))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(category == selection ? AppColors.sidebarPrimary : AppColors.mutedForeground)
                                    .frame(width: 18)
                            }

                            Text(category)
                                .font(.system(size: 14, weight: category == selection ? .semibold : .medium))
                                .foregroundColor(AppColors.foreground)

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                        .background(category == selection ? AppColors.sidebarAccent : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusSm))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 6)
                }
            }
            .padding(.vertical, 6)
            .frame(minWidth: buttonWidth)
        }
    }
}

private struct PKPickerWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/// Primary action button for modal headers (Save / Reset / Confirm).
/// Active: `AppColors.primary` background. Inactive: subtle white-tinted surface visible in both themes.
struct PKModalActionButton: View {
    let title: String
    let isEnabled: Bool
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryForeground))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                }
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(isEnabled ? AppColors.primaryForeground : AppColors.mutedForeground)
            .padding(.horizontal, 16)
            .frame(height: 34)
            .background(isEnabled ? AppColors.primary : Color.primary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .buttonStyle(.plain)
        .opacity(isLoading ? 0.86 : 1)
        .disabled(!isEnabled || isLoading)
    }
}

/// Metadata panel that groups key/value style info in a bordered card.
struct PKMetadataPanel<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = title {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.mutedForeground)
            }

            VStack(alignment: .leading, spacing: 6) {
                content
            }
        }
        .padding(18)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusLg)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}
