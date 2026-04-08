import SwiftUI
import AppKit

// MARK: - Gradient Icon

/// Icon with primary-to-orange gradient
struct GradientIcon: View {
    let systemName: String
    let size: CGFloat

    init(systemName: String, size: CGFloat = AppConstants.iconSizeXl) {
        self.systemName = systemName
        self.size = size
    }

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [AppColors.gradientPrimary, AppColors.gradientOrange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// MARK: - Styled Text Field

/// Styled text field with rounded corners and border - matches prototype
struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isFocused: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(AppColors.mutedForeground)
                    .frame(width: AppConstants.iconSizeMd)
            }

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.body)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(height: AppConstants.inputHeight)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusXl)
                .stroke(isFocused ? AppColors.primary : AppColors.border, lineWidth: isFocused ? 2 : 1)
        )
    }
}

// MARK: - Styled Secure Field

/// Styled secure field for password input - matches prototype
struct StyledSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    var isFocused: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .foregroundColor(AppColors.mutedForeground)
                .frame(width: AppConstants.iconSizeMd)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .font(.body)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .font(.body)
            }

            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(AppColors.mutedForeground)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(height: AppConstants.inputHeight)
        .background(AppColors.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.radiusXl)
                .stroke(isFocused ? AppColors.primary : AppColors.border, lineWidth: isFocused ? 2 : 1)
        )
    }
}

// MARK: - Form Field

/// Form field with label and input - matches prototype styling
struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.foreground)

            if isSecure {
                StyledSecureField(placeholder: placeholder, text: $text)
            } else {
                StyledTextField(placeholder: placeholder, text: $text, icon: icon)
            }
        }
    }
}

// MARK: - Right-aligned Form Field

/// Form field with right-aligned label (matches prototype)
struct FormFieldRightLabel: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    @State private var isFocused: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.foreground)
                .frame(width: 100, alignment: .trailing)

            if isSecure {
                HStack(spacing: 12) {
                    if isFocused {
                        TextField(placeholder, text: $text)
                            .textFieldStyle(.plain)
                    } else {
                        SecureField(placeholder, text: $text)
                            .textFieldStyle(.plain)
                    }

                    TogglePasswordButton(isSecure: $isFocused)
                }
                .frame(height: AppConstants.inputHeight)
                .background(AppColors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.radiusXl)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            } else {
                HStack(spacing: 12) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundColor(AppColors.mutedForeground)
                            .frame(width: AppConstants.iconSizeMd)
                    }

                    TextField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                }
                .frame(height: AppConstants.inputHeight)
                .background(AppColors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.radiusXl)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Copy Button

/// Button with copy functionality and feedback
struct CopyButton: View {
    let text: String
    @State private var showCopied: Bool = false

    var body: some View {
        Button {
            copyToClipboard()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 14))
                if showCopied {
                    Text("common.copied".localized)
                        .font(.caption)
                }
            }
            .foregroundColor(showCopied ? Color.green : AppColors.mutedForeground)
        }
        .buttonStyle(.plain)
    }

    private func copyToClipboard() {
        NSPasteboard.general.setString(text, forType: .string)
        showCopied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopied = false
        }
    }
}

// MARK: - Toggle Password Button

/// Button to toggle password visibility
struct TogglePasswordButton: View {
    @Binding var isSecure: Bool

    var body: some View {
        Button {
            isSecure.toggle()
        } label: {
            Image(systemName: isSecure ? "eye.slash" : "eye")
                .font(.system(size: AppConstants.iconSizeSm))
                .foregroundColor(AppColors.mutedForeground)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Icon

/// Get SF Symbol for category
func categoryIcon(for category: String) -> String {
    switch category {
    case "category.all".localized, "All": return "tray.full"
    case "category.general".localized, "General": return "key"
    case "category.social".localized, "Social": return "person.2"
    case "category.work".localized, "Work": return "briefcase"
    case "category.finance".localized, "Finance": return "creditcard"
    case "category.shopping".localized, "Shopping": return "cart"
    case "category.entertainment".localized, "Entertainment": return "tv"
    case "category.other".localized, "Other": return "folder"
    default: return "folder"
    }
}