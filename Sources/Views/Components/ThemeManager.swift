import SwiftUI

// MARK: - Theme Manager

/// Theme manager for handling theme persistence and switching
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var appearanceMode: AppearanceMode {
        didSet {
            saveAppearance()
            applyAppearance()
        }
    }

    private let appearanceKey = "appearanceMode"

    private init() {
        // Load saved preference or default to system
        let savedValue = UserDefaults.standard.integer(forKey: appearanceKey)
        if let mode = AppearanceMode(rawValue: savedValue) {
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

/// Button to toggle between light/dark modes
struct ThemeToggleButton: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button {
            themeManager.toggle()
        } label: {
            Image(systemName: themeIcon)
                .font(.system(size: AppConstants.iconSizeMd))
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