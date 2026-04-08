import XCTest
@testable import PassKeeper

final class CustomCategoryStoreTests: XCTestCase {
    func testDeleteInUseErrorDescriptionKey() {
        XCTAssertEqual(CategoryStoreError.categoryInUse.errorDescription, "settings.category.validation.inUse".localized)
    }

    func testBuiltInCategoryProtectedErrorDescriptionKey() {
        XCTAssertEqual(CategoryStoreError.builtInCategoryProtected.errorDescription, "settings.category.validation.builtInProtected".localized)
    }
}
