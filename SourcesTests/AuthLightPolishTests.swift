import XCTest
@testable import PassKeeper

final class AuthLightPolishTests: XCTestCase {
    func testAuthPrototypeMetricsRemainStableDuringLightPolish() {
        let metrics = AuthScreenVisualMetrics.prototype

        XCTAssertEqual(metrics.panelWidth, 412)
        XCTAssertEqual(metrics.setupPanelWidth, 432)
        XCTAssertEqual(metrics.heroSize, 100)
        XCTAssertEqual(metrics.fieldHeight, 58)
        XCTAssertEqual(metrics.buttonHeight, 58)
        XCTAssertEqual(metrics.contentOffsetY, -34)
    }

    func testLightPaletteAuthColorsAreWarmAndSoft() {
        XCTAssertEqual(AppThemeLightPalette.backgroundHex, "f7f4f1")
        XCTAssertEqual(AppThemeLightPalette.authFieldBackgroundHex, "fbf8f5")
        XCTAssertEqual(AppThemeLightPalette.authSubtitleHex, "8c7f74")
    }
}
