import SwiftUI
import AppKit

// MARK: - Re-export common types for convenience

/// Re-exports from Theme.swift and CommonComponents.swift for easy access
typealias GradientIconView = GradientIcon

// MARK: - Gradient Lock Icon Container

/// Large gradient icon container used on unlock/setup screens
struct GradientLockIcon: View {
    let systemName: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.gradientPrimary.opacity(0.2), AppColors.gradientOrange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)

            GradientIcon(systemName: systemName, size: size / 2)
        }
    }
}

// MARK: - Modal Container

/// Modal overlay with semi-transparent background
struct ModalContainer<Content: View>: View {
    let content: Content
    let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onDismiss = onDismiss
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Modal content
            content
        }
    }
}

// MARK: - Modal Card

/// Card container for modal content
struct ModalCard<Content: View>: View {
    let title: String
    let width: CGFloat
    let height: CGFloat?
    let content: Content

    init(
        title: String,
        width: CGFloat = 480,
        height: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.width = width
        self.height = height
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()

                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.foreground)

                Spacer()
            }
            .padding(16)

            Divider()

            // Content
            if let height = height {
                content
                    .frame(height: height)
            } else {
                content
            }
        }
        .frame(width: width)
        .background(AppColors.popover)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
        .shadow(color: Color.black.opacity(0.2), radius: 20)
    }
}

// MARK: - Modal Header

/// Header for modals with cancel/save buttons
struct ModalHeader: View {
    let title: String
    let cancelAction: () -> Void
    let saveAction: () -> Void
    var isSaveEnabled: Bool = true

    var body: some View {
        HStack {
            Button {
                cancelAction()
            } label: {
                Text("common.cancel".localized)
            }
            .buttonStyle(.plain)
            .foregroundColor(AppColors.mutedForeground)

            Spacer()

            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.foreground)

            Spacer()

            Button {
                saveAction()
            } label: {
                Text("common.save".localized)
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 80)
            .disabled(!isSaveEnabled)
        }
        .padding(16)
    }
}

// MARK: - Section Card

/// Card container for settings sections
struct SectionCard<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = title {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.mutedForeground)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }

            content
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusLg)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Setting Row

/// Setting row with label and control
struct SettingRow<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content

    init(
        _ title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.foreground)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppColors.mutedForeground)
                }
            }

            Spacer()

            content
        }
        .padding(16)
    }
}

// MARK: - Setting Picker

/// Styled picker for settings
struct SettingPicker<SelectionValue: Hashable, Content: View>: View {
    let selection: Binding<SelectionValue>
    let content: Content

    init(
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) {
        self.selection = selection
        self.content = content()
    }

    var body: some View {
        Picker("", selection: selection) {
            content
        }
        .pickerStyle(.menu)
    }
}

// MARK: - Section Divider

/// Divider with proper spacing for settings sections
struct SectionDivider: View {
    var body: some View {
        Divider()
            .padding(.horizontal, 16)
    }
}

// MARK: - Input Row

/// Input field row with label for forms
struct InputRow: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var isEditing: Binding<Bool>? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.foreground)

            if isSecure {
                HStack(spacing: 12) {
                    if let isEditing = isEditing {
                        Group {
                            if isEditing.wrappedValue {
                                TextField(placeholder, text: $text)
                            } else {
                                SecureField(placeholder, text: $text)
                            }
                        }
                        .textFieldStyle(.plain)
                    } else {
                        SecureField(placeholder, text: $text)
                            .textFieldStyle(.plain)
                    }

                    if let isEditing = isEditing {
                        TogglePasswordButton(isSecure: isEditing)
                    }
                }
            } else if let icon = icon {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.mutedForeground)
                        .frame(width: AppConstants.iconSizeMd)

                    TextField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                }
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
            }

            inputFieldStyle
        }
    }

    private var inputFieldStyle: some View {
        Group {
            if let isEditing = isEditing, !isEditing.wrappedValue {
                Text(text.isEmpty ? "••••••••••••" : String(repeating: "•", count: min(text.count, 20)))
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .frame(height: AppConstants.inputHeight)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Category Picker

/// Category picker menu for forms
struct CategoryPicker: View {
    @Binding var selectedCategory: String
    let categories: [String]

    var body: some View {
        Menu {
            ForEach(categories, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    HStack {
                        Image(systemName: categoryIcon(for: category))
                        Text(category)
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: categoryIcon(for: selectedCategory))
                    .foregroundColor(AppColors.sidebarPrimary)
                Text(selectedCategory)
                    .foregroundColor(AppColors.foreground)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.mutedForeground)
            }
            .padding(.horizontal, 16)
            .frame(height: AppConstants.inputHeight)
            .background(AppColors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        }
        .menuStyle(.borderlessButton)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Form Section

/// Form section container
struct FormSection<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.mutedForeground)
            }

            VStack(spacing: 0) {
                content
            }
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.radiusLg)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }
}

// MARK: - Action Button Row

/// Horizontal action button row (e.g., Cancel + Save)
struct ActionButtonRow: View {
    let primaryTitle: String
    let secondaryTitle: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    var isPrimaryEnabled: Bool = true
    var isPrimaryDestructive: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                secondaryAction()
            } label: {
                Text(secondaryTitle)
            }
            .buttonStyle(SecondaryButtonStyle())

            Button {
                primaryAction()
            } label: {
                Text(primaryTitle)
            }
            .buttonStyle(isPrimaryDestructive ? DestructiveButtonStyle() : PrimaryButtonStyle())
            .disabled(!isPrimaryEnabled)
        }
    }
}

// MARK: - Toolbar Button

/// Toolbar button with icon
struct ToolbarButton: View {
    let icon: String
    let label: String?
    let action: () -> Void

    init(_ icon: String, label: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: label != nil ? 6 : 0) {
                Image(systemName: icon)
                if let label = label {
                    Text(label)
                }
            }
        }
        .buttonStyle(.plain)
        .foregroundColor(AppColors.foreground)
        .padding(8)
        .background(AppColors.accent)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
    }
}

// MARK: - Empty State View

/// Empty state with icon and action
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let buttonTitle: String
    let buttonAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.radiusXl)
                    .fill(AppColors.muted)
                    .frame(width: 96, height: 96)

                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundColor(AppColors.mutedForeground)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.foreground)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(AppColors.mutedForeground)
            }

            Button {
                buttonAction()
            } label: {
                Text(buttonTitle)
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 160)
        }
    }
}