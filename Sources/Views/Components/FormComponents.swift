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
