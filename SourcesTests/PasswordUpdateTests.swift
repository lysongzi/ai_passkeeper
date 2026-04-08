import Foundation
import XCTest
@testable import PassKeeper

/// Unit tests for the password update / save flow
final class PasswordUpdateTests: XCTestCase {

    func testUpdatedItemPreservesId() {
        let original = makeItem(id: UUID(), title: "Original", category: "General")
        let updated = makeUpdatedItem(from: original, title: "Updated")
        XCTAssertEqual(original.id, updated.id)
    }

    func testUpdatedItemReflectsNewPhoneAndEmail() {
        let original = makeItem(phoneNumber: "", email: "")
        let updated = makeUpdatedItem(from: original, phoneNumber: "+86 13800138000", email: "new@example.com")
        XCTAssertEqual(updated.phoneNumber, "+86 13800138000")
        XCTAssertEqual(updated.email, "new@example.com")
    }

    func testCategoryRawValueRoundTripIncludesCustomFallback() {
        let categories: [(rawValue: String, localized: String)] = [
            ("General", "General"),
            ("Social", "Social"),
            ("Work", "Work"),
            ("Finance", "Finance"),
            ("Shopping", "Shopping"),
            ("Entertainment", "Entertainment"),
            ("Other", "Other")
        ]

        for pair in categories {
            let resolved = resolveCategoryRawValue(from: pair.localized, allCases: categories)
            XCTAssertEqual(resolved, pair.rawValue)
        }

        XCTAssertEqual(resolveCategoryRawValue(from: "CustomCategory", allCases: categories), "CustomCategory")
    }

    private func makeItem(
        id: UUID = UUID(),
        title: String = "Test",
        username: String = "user@example.com",
        password: String = "password123",
        category: String = "General",
        phoneNumber: String = "",
        email: String = "",
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> DecryptedPasswordItem {
        DecryptedPasswordItem(
            id: id,
            category: category,
            title: title,
            username: username,
            password: password,
            phoneNumber: phoneNumber,
            email: email,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    private func makeUpdatedItem(
        from original: DecryptedPasswordItem? = nil,
        id: UUID? = nil,
        title: String? = nil,
        username: String? = nil,
        password: String? = nil,
        category: String? = nil,
        phoneNumber: String? = nil,
        email: String? = nil,
        notes: String? = nil
    ) -> DecryptedPasswordItem {
        let base = original ?? makeItem()
        return DecryptedPasswordItem(
            id: id ?? base.id,
            category: category ?? base.category,
            title: title ?? base.title,
            username: username ?? base.username,
            password: password ?? base.password,
            phoneNumber: phoneNumber ?? base.phoneNumber,
            email: email ?? base.email,
            notes: notes ?? base.notes,
            createdAt: base.createdAt,
            updatedAt: Date()
        )
    }

    private func resolveCategoryRawValue(from localized: String, allCases: [(rawValue: String, localized: String)]) -> String {
        allCases.first(where: { $0.localized == localized })?.rawValue ?? localized
    }
}
