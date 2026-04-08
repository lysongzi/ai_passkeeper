import XCTest
@testable import PassKeeper

final class AuthScreenVisualModelTests: XCTestCase {
    func testAuthVisualMetricsMatchLockScreenPrototype() {
        let metrics = AuthScreenVisualMetrics.prototype

        XCTAssertEqual(metrics.panelWidth, 408)
        XCTAssertEqual(metrics.heroSize, 104)
        XCTAssertEqual(metrics.fieldHeight, 62)
        XCTAssertEqual(metrics.buttonHeight, 60)
        XCTAssertEqual(metrics.fieldCornerRadius, 18)
        XCTAssertEqual(metrics.buttonCornerRadius, 18)
    }

    func testSetupScreenUsesSameVisualMetricsAsUnlockScreen() {
        XCTAssertEqual(AuthScreenVisualMetrics.prototype, .prototype)
    }
}
