import SwiftUI
import AppKit

// MARK: - macOS Window Controls

/// macOS-style window traffic light buttons
struct WindowControls: View {
    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(Color(hex: "FF5F57"))
                .frame(width: 11.5, height: 11.5)

            Circle()
                .fill(Color(hex: "FEBC2E"))
                .frame(width: 11.5, height: 11.5)

            Circle()
                .fill(Color(hex: "28C840"))
                .frame(width: 11.5, height: 11.5)
        }
    }
}

// MARK: - Window Title Bar

/// Window title bar with traffic lights and optional title
struct WindowTitleBar: View {
    var title: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            WindowControls()

            if let title = title {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.sidebarForeground.opacity(0.9))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .background(AppColors.sidebar)
    }
}

// MARK: - Window Container

/// Container that simulates a macOS window with title bar
struct WindowContainer<Content: View>: View {
    let title: String?
    let width: CGFloat
    let height: CGFloat
    let content: Content

    init(
        title: String? = nil,
        width: CGFloat = 1000,
        height: CGFloat = 700,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.width = width
        self.height = height
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            WindowTitleBar(title: title)
                .background(AppColors.sidebar)

            Rectangle()
                .fill(AppColors.border)
                .frame(height: 1)

            content
        }
        .frame(width: width, height: height)
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .shadow(color: AppElevation.windowShadow, radius: 24, x: 0, y: 16)
    }
}

// MARK: - Toolbar Buttons Row

/// Toolbar with action buttons - matches prototype styling
struct ToolbarButtonsRow: View {
    let onAdd: () -> Void
    let onSettings: () -> Void
    let onLock: () -> Void
    let onThemeToggle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            ToolbarButton("plus", label: nil) { onAdd() }
            ToolbarButton("gearshape", label: nil) { onSettings() }
            ToolbarButton("lock", label: nil) { onLock() }

            Spacer(minLength: 0)

            ToolbarButton("sun.max", label: nil) { onThemeToggle() }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(AppColors.card)
    }
}

// MARK: - Compact Toolbar Button

/// Compact icon-only toolbar button
struct ToolbarIconButton: View {
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
            Group {
                if let label = label {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                        Text(label)
                    }
                } else {
                    Image(systemName: icon)
                }
            }
            .font(.system(size: 14, weight: .medium))
        }
        .buttonStyle(.plain)
        .foregroundColor(AppColors.foreground)
        .frame(width: 34, height: 34)
        .background(AppColors.accent)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppColors.border.opacity(0.7), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Icon Card

/// Card with centered icon - used in empty states
struct IconCard: View {
    let icon: String
    let size: CGFloat
    let backgroundColor: Color

    init(icon: String, size: CGFloat = 96, backgroundColor: Color = AppColors.muted) {
        self.icon = icon
        self.size = size
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AppColors.border.opacity(0.75), lineWidth: 1)
                )

            Image(systemName: icon)
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundColor(AppColors.mutedForeground)
        }
    }
}

// MARK: - Content Field Display

/// Display field for viewing content (password, username, etc.)
struct ContentFieldDisplay: View {
    let value: String
    let isSecure: Bool
    @Binding var isRevealed: Bool

    var body: some View {
        PKFieldContainer {
            HStack(spacing: 12) {
                if isSecure && !isRevealed {
                    Text(String(repeating: "•", count: min(value.count, 20)))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(AppColors.foreground)
                } else {
                    Text(value)
                        .font(.body)
                        .foregroundColor(AppColors.foreground)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Field Row

/// Row with label and content display
struct FieldRow: View {
    let label: String
    let value: String
    let isSecure: Bool
    @State private var isRevealed: Bool = false
    var onCopy: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.mutedForeground)

            HStack(spacing: 12) {
                Group {
                    if isSecure && !isRevealed {
                        Text(String(repeating: "•", count: min(value.count, 20)))
                            .font(.system(.body, design: .monospaced))
                    } else {
                        Text(value)
                            .font(.body)
                    }
                }
                .foregroundColor(AppColors.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .foregroundColor(AppColors.mutedForeground)
                    }
                    .buttonStyle(.plain)
                }

                if let onCopy = onCopy {
                    Button {
                        onCopy()
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(AppColors.mutedForeground)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(AppColors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        }
    }
}

// MARK: - Metadata Display

/// Key-value display for metadata
struct MetadataDisplay: View {
    let items: [(String, String)]

    var body: some View {
        PKMetadataPanel {
            ForEach(items, id: \.0) { item in
                HStack(spacing: 12) {
                    Text(item.0)
                        .foregroundColor(AppColors.mutedForeground)
                    Spacer(minLength: 0)
                    Text(item.1)
                        .foregroundColor(AppColors.foreground)
                }
                .font(.caption)
            }
        }
    }
}

// MARK: - Form Input Row

/// Right-aligned label form input - matches prototype
struct FormInputRow: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil
    var isSecure: Bool = false

    var body: some View {
        PKFormRowRightLabel(label) {
            PKFieldContainer {
                HStack(spacing: 12) {
                    if let icon = icon, !isSecure {
                        Image(systemName: icon)
                            .foregroundColor(AppColors.mutedForeground)
                            .frame(width: AppConstants.iconSizeMd)
                    }

                    if isSecure {
                        SecureField(placeholder.isEmpty ? label : placeholder, text: $text)
                            .textFieldStyle(.plain)

                        Image(systemName: "eye")
                            .foregroundColor(AppColors.mutedForeground)
                    } else {
                        TextField(placeholder.isEmpty ? label : placeholder, text: $text)
                            .textFieldStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Delete Button

/// Destructive delete button with icon
struct DeleteButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                Text(label)
            }
        }
        .buttonStyle(DestructiveButtonStyle())
    }
}