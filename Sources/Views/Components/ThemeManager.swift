import SwiftUI
import AppKit

// MARK: - Theme Appearance

/// Theme appearance mode enum - independent from SettingsViewModel
enum ThemeAppearance: Int, CaseIterable, Identifiable {
    case system = 0
    case light = 1
    case dark = 2

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .system: return "settings.appearance.system".localized
        case .light: return "settings.appearance.light".localized
        case .dark: return "settings.appearance.dark".localized
        }
    }
}

// MARK: - Theme Manager

/// Theme manager for handling theme persistence and switching
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var appearanceMode: ThemeAppearance {
        didSet {
            saveAppearance()
            applyAppearance()
        }
    }

    private let appearanceKey = "theme_appearance_mode"

    private init() {
        let savedValue = UserDefaults.standard.integer(forKey: appearanceKey)
        if let mode = ThemeAppearance(rawValue: savedValue) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .system
        }
        applyAppearance()
    }

    private func saveAppearance() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceKey)
    }

    private func applyAppearance() {
        guard let window = NSApplication.shared.windows.first else { return }

        switch appearanceMode {
        case .system:
            window.appearance = nil
        case .light:
            window.appearance = NSAppearance(named: .aqua)
        case .dark:
            window.appearance = NSAppearance(named: .darkAqua)
        }
    }

    func toggle() {
        switch appearanceMode {
        case .system:
            appearanceMode = .light
        case .light:
            appearanceMode = .dark
        case .dark:
            appearanceMode = .system
        }
    }
}

// MARK: - Theme Toggle Button

/// Button to toggle between light/dark modes - matches prototype styling
struct ThemeToggleButton: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button {
            themeManager.toggle()
        } label: {
            Image(systemName: themeIcon)
                .font(.system(size: AppConstants.iconSizeMd))
                .foregroundColor(AppColors.mutedForeground)
                .frame(width: 36, height: 36)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .help(themeHelpText)
    }

    private var themeIcon: String {
        switch themeManager.appearanceMode {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }

    private var themeHelpText: String {
        switch themeManager.appearanceMode {
        case .system:
            return "Switch to light mode"
        case .light:
            return "Switch to dark mode"
        case .dark:
            return "Switch to system mode"
        }
    }
}