import SwiftUI
import AppKit

// MARK: - Theme Manager

/// Shared theme manager bridged to the app-wide AppearanceMode preference.
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var appearanceMode: AppearanceMode {
        didSet {
            saveAppearance()
            applyAppearance()
        }
    }

    private let appearanceKey = "app_appearance_mode"

    private init() {
        let savedValue = UserDefaults.standard.integer(forKey: appearanceKey)
        self.appearanceMode = AppearanceMode(rawValue: savedValue) ?? .system
        applyAppearance()
    }

    private func saveAppearance() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceKey)
    }

    func setAppearance(_ mode: AppearanceMode) {
        guard appearanceMode != mode else { return }
        appearanceMode = mode
    }

    func applyAppearance() {
        switch appearanceMode {
        case .system:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
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

/// Button to toggle between light/dark/system modes - matches prototype styling.
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
