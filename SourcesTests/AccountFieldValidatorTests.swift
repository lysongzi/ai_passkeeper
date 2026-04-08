import XCTest
@testable import PassKeeper

final class AccountFieldValidatorTests: XCTestCase {
    func testEmailValidationAllowsEmptyAndRejectsMalformedAddress() {
        XCTAssertTrue(AccountFieldValidator.isValidEmail(""))
        XCTAssertFalse(AccountFieldValidator.isValidEmail("invalid-email"))
        XCTAssertTrue(AccountFieldValidator.isValidEmail("person@example.com"))
    }

    func testPhoneValidationAllowsLooseFormatsButRejectsTooShortInput() {
        XCTAssertTrue(AccountFieldValidator.isValidPhoneNumber(""))
        XCTAssertTrue(AccountFieldValidator.isValidPhoneNumber("+86 138-0013-8000"))
        XCTAssertTrue(AccountFieldValidator.isValidPhoneNumber("(415) 555 0101"))
        XCTAssertFalse(AccountFieldValidator.isValidPhoneNumber("12"))
    }
}
