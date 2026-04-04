import XCTest
@testable import PasswordManager

final class LightThemePaletteTests: XCTestCase {
    func testLightThemeUsesWarmPrototypeAlignedPalette() {
        XCTAssertEqual(AppThemeLightPalette.backgroundHex, "f7f4f1")
        XCTAssertEqual(AppThemeLightPalette.cardHex, "fffdfa")
        XCTAssertEqual(AppThemeLightPalette.popoverHex, "fffaf6")
        XCTAssertEqual(AppThemeLightPalette.inputBackgroundHex, "f3eeea")
        XCTAssertEqual(AppThemeLightPalette.sidebarHex, "f6eee7")
        XCTAssertEqual(AppThemeLightPalette.sidebarAccentHex, "efe4d8")
        XCTAssertEqual(AppThemeLightPalette.mutedForegroundHex, "8f8175")
    }
}
