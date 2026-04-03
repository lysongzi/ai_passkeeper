import SwiftUI

// MARK: - PK Modal Primitives

/// Reusable dimmed overlay modal container.
struct PKModalContainer<Content: View>: View {
    let onDismiss: () -> Void
    let dismissOnBackgroundTap: Bool
    let content: Content

    init(
        dismissOnBackgroundTap: Bool = true,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onDismiss = onDismiss
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppColors.foreground
                .opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    if dismissOnBackgroundTap {
                        onDismiss()
                    }
                }

            content
        }
    }
}

/// Modal header with left action / centered title / right action.
struct PKModalHeader<Left: View, Right: View>: View {
    let title: String
    let left: Left
    let right: Right

    init(
        title: String,
        @ViewBuilder left: () -> Left,
        @ViewBuilder right: () -> Right
    ) {
        self.title = title
        self.left = left()
        self.right = right()
    }

    var body: some View {
        ZStack {
            HStack {
                left
                Spacer(minLength: 0)
                right
            }

            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.foreground)
                .lineLimit(1)
                .truncationMode(.tail)
                .allowsHitTesting(false)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}

/// Icon-only button tuned for modal/tool areas.
struct PKIconButton: View {
    let systemName: String
    let action: () -> Void
    var size: CGFloat = AppConstants.iconSizeSm
    var tapArea: CGFloat = 32

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(AppColors.mutedForeground)
                .frame(width: tapArea, height: tapArea)
                .background(AppColors.accent.opacity(0.001))
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        }
        .buttonStyle(.plain)
    }
}
