import SwiftUI
import AppKit

// MARK: - Adaptive Color

/// A view that adapts its color based on color scheme
struct AdaptiveColor: View {
    let light: Color
    let dark: Color

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        colorScheme == .dark ? dark : light
    }
}

/// Helper to get color based on appearance
func adaptiveColor(light: Color, dark: Color) -> Color {
    Color(nsColor: NSColor(name: nil) { appearance in
        if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return NSColor(dark)
        } else {
            return NSColor(light)
        }
    })
}

/// shadcn/ui color palette for SwiftUI
struct AppColors {
    // MARK: - Base Colors

    /// Main background color
    static let background = adaptiveColor(light: Color(hex: "ffffff"), dark: Color(hex: "1a1a1a"))

    /// Main foreground/text color
    static let foreground = adaptiveColor(light: Color(hex: "030213"), dark: Color(hex: "fafafa"))

    /// Card background color
    static let card = adaptiveColor(light: Color(hex: "ffffff"), dark: Color(hex: "1a1a1a"))

    /// Card foreground color
    static let cardForeground = adaptiveColor(light: Color(hex: "030213"), dark: Color(hex: "fafafa"))

    /// Popover background color
    static let popover = adaptiveColor(light: Color(hex: "ffffff"), dark: Color(hex: "1a1a1a"))

    /// Popover foreground color
    static let popoverForeground = adaptiveColor(light: Color(hex: "030213"), dark: Color(hex: "fafafa"))

    /// Primary color (main accent)
    static let primary = adaptiveColor(light: Color(hex: "030213"), dark: Color(hex: "fafafa"))

    /// Primary foreground (text on primary)
    static let primaryForeground = adaptiveColor(light: Color(hex: "ffffff"), dark: Color(hex: "1a1a1a"))

    /// Secondary color
    static let secondary = adaptiveColor(light: Color(hex: "f2f2f7"), dark: Color(hex: "2d2d2d"))

    /// Secondary foreground
    static let secondaryForeground = adaptiveColor(light: Color(hex: "030213"), dark: Color(hex: "fafafa"))

    /// Muted background
    static let muted = adaptiveColor(light: Color(hex: "ececf0"), dark: Color(hex: "2d2d2d"))

    /// Muted foreground
    static let mutedForeground = adaptiveColor(light: Color(hex: "717182"), dark: Color(hex: "888888"))

    /// Accent background
    static let accent = adaptiveColor(light: Color(hex: "e9ebef"), dark: Color(hex: "2d2d2d"))

    /// Accent foreground
    static let accentForeground = adaptiveColor(light: Color(hex: "030213"), dark: Color(hex: "fafafa"))

    /// Destructive/Error color
    static let destructive = adaptiveColor(light: Color(hex: "d4183d"), dark: Color(hex: "ea3943"))

    /// Destructive foreground
    static let destructiveForeground = adaptiveColor(light: Color(hex: "ffffff"), dark: Color(hex: "ffffff"))

    /// Border color
    static let border = adaptiveColor(light: Color(hex: "1a1a1a").opacity(0.1), dark: Color(hex: "2d2d2d"))

    /// Input background
    static let inputBackground = adaptiveColor(light: Color(hex: "f3f3f5"), dark: Color(hex: "2d2d2d"))

    /// Ring color (focus ring)
    static let ring = adaptiveColor(light: Color(hex: "b4b4b4"), dark: Color(hex: "555555"))

    // MARK: - Sidebar Colors

    /// Sidebar background
    static let sidebar = adaptiveColor(light: Color(hex: "fafafa"), dark: Color(hex: "1a1a1a"))

    /// Sidebar foreground
    static let sidebarForeground = adaptiveColor(light: Color(hex: "030213"), dark: Color(hex: "fafafa"))

    /// Sidebar primary color
    static let sidebarPrimary = adaptiveColor(light: Color(hex: "030213"), dark: Color(hex: "6366f1"))

    /// Sidebar primary foreground
    static let sidebarPrimaryForeground = adaptiveColor(light: Color(hex: "fafafa"), dark: Color(hex: "fafafa"))

    /// Sidebar accent
    static let sidebarAccent = adaptiveColor(light: Color(hex: "f2f2f7"), dark: Color(hex: "2d2d2d"))

    /// Sidebar accent foreground
    static let sidebarAccentForeground = adaptiveColor(light: Color(hex: "1a1a1a"), dark: Color(hex: "fafafa"))

    /// Sidebar border
    static let sidebarBorder = adaptiveColor(light: Color(hex: "ebebeb"), dark: Color(hex: "2d2d2d"))

    // MARK: - Gradient Colors

    /// Primary gradient start
    static let gradientPrimary = Color(hex: "6366f1")

    /// Primary gradient end
    static let gradientOrange = Color(hex: "f97316")
}

// MARK: - Design System Constants

struct AppConstants {
    // MARK: - Corner Radius

    /// Small corner radius (6px)
    static let radiusSm: CGFloat = 6

    /// Medium corner radius (8px)
    static let radiusMd: CGFloat = 8

    /// Large corner radius (10px)
    static let radiusLg: CGFloat = 10

    /// Extra large corner radius (16px for inputs)
    static let radiusXl: CGFloat = 16

    /// 2xl corner radius (20px for cards/modals)
    static let radiusXxl: CGFloat = 20

    // MARK: - Sizing

    /// Input field height (44-48pt)
    static let inputHeight: CGFloat = 48

    /// Icon size small
    static let iconSizeSm: CGFloat = 16

    /// Icon size medium
    static let iconSizeMd: CGFloat = 20

    /// Icon size large
    static let iconSizeLg: CGFloat = 24

    /// Icon size extra large
    static let iconSizeXl: CGFloat = 32

    /// Button height
    static let buttonHeight: CGFloat = 44

    /// Sidebar width
    static let sidebarWidth: CGFloat = 280

    /// Sidebar min width
    static let sidebarMinWidth: CGFloat = 200

    /// Sidebar max width
    static let sidebarMaxWidth: CGFloat = 350
}

// MARK: - Color Extension

extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

/// Primary button style - matches prototype with shadow
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppColors.primaryForeground)
            .frame(height: AppConstants.buttonHeight)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .background(isEnabled ? AppColors.primary : AppColors.muted)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
            .shadow(color: isEnabled ? Color.black.opacity(0.15) : Color.clear, radius: 4, x: 0, y: 2)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

/// Secondary button style - matches prototype
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppColors.foreground)
            .frame(height: AppConstants.buttonHeight)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .background(AppColors.secondary)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

/// Destructive button style
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppColors.destructiveForeground)
            .frame(height: AppConstants.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(AppColors.destructive)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

/// Card container style
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusLg))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.radiusLg)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}

extension View {
    /// Apply card container styling
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}