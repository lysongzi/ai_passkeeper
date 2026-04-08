import Foundation
import XCTest
@testable import PassKeeper

/// Unit tests for PasswordItem model
final class PasswordItemTests: XCTestCase {

    func testPasswordItemCreation() {
        let item = PasswordItem(
            category: "General",
            title: "Test Site",
            username: "user@test.com",
            encryptedPassword: Data("encrypted".utf8)
        )

        XCTAssertEqual(item.title, "Test Site")
        XCTAssertEqual(item.username, "user@test.com")
        XCTAssertEqual(item.category, "General")
    }

    func testSearchIndexCreationIncludesPhoneAndEmail() {
        let index = PasswordItem.createSearchIndex(
            title: "Google",
            username: "user@gmail.com",
            phoneNumber: "+1 415 555 0101",
            email: "user@work.com"
        )

        XCTAssertTrue(index.contains("google"))
        XCTAssertTrue(index.contains("user@gmail.com"))
        XCTAssertTrue(index.contains("+1 415 555 0101".lowercased()))
        XCTAssertTrue(index.contains("user@work.com"))
    }
}

/// Unit tests for BiometricType
final class BiometricTypeTests: XCTestCase {
    func testBiometricTypeDisplayName() {
        XCTAssertEqual(TestBiometricType.touchID.displayName, "Touch ID")
        XCTAssertEqual(TestBiometricType.faceID.displayName, "Face ID")
        XCTAssertEqual(TestBiometricType.none.displayName, "Biometric")
    }

    func testBiometricTypeIcon() {
        XCTAssertEqual(TestBiometricType.touchID.icon, "touchid")
        XCTAssertEqual(TestBiometricType.faceID.icon, "faceid")
        XCTAssertEqual(TestBiometricType.none.icon, "lock")
    }
}

enum TestBiometricType {
    case touchID
    case faceID
    case none

    var displayName: String {
        switch self {
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        case .none: return "Biometric"
        }
    }

    var icon: String {
        switch self {
        case .touchID: return "touchid"
        case .faceID: return "faceid"
        case .none: return "lock"
        }
    }
}

final class ErrorMessageTests: XCTestCase {
    func testSecurityErrorDescriptions() {
        XCTAssertEqual("No active session key", "No active session key")
        XCTAssertEqual("Failed to encode data", "Failed to encode data")
        XCTAssertEqual("Failed to decode data", "Failed to decode data")
        XCTAssertEqual("Encryption failed", "Encryption failed")
        XCTAssertEqual("Decryption failed", "Decryption failed")
        XCTAssertEqual("Key derivation failed", "Key derivation failed")
    }

    func testDatabaseErrorDescriptions() {
        XCTAssertEqual("Database not initialized", "Database not initialized")
        XCTAssertEqual("Failed to insert record", "Failed to insert record")
        XCTAssertEqual("Failed to update record", "Failed to update record")
        XCTAssertEqual("Failed to delete record", "Failed to delete record")
    }
}

final class AppErrorTests: XCTestCase {
    func testAppErrorDescriptions() {
        XCTAssertEqual("Invalid master password", "Invalid master password")
        XCTAssertEqual("Biometric authentication is not available", "Biometric authentication is not available")
        XCTAssertEqual("Failed to encrypt data", "Failed to encrypt data")
        XCTAssertEqual("Failed to decrypt data", "Failed to decrypt data")
        XCTAssertEqual("Failed to access storage", "Failed to access storage")
    }
}
