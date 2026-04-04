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
                .opacity(0.36)
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
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, 17)
    }
}

/// Icon-only button tuned for modal/tool areas.
struct PKIconButton: View {
    let systemName: String
    let action: () -> Void
    var size: CGFloat = AppConstants.iconSizeSm
    var tapArea: CGFloat = 32
    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(AppColors.mutedForeground)
                .frame(width: tapArea, height: tapArea)
                .background(isPressed ? AppColors.accent.opacity(0.9) : (isHovered ? AppColors.accent.opacity(0.72) : AppColors.accent.opacity(0.001)))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                        .stroke(isHovered ? AppColors.border : .clear, lineWidth: isHovered ? 1 : 0)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                .scaleEffect(isPressed ? 0.97 : 1)
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
