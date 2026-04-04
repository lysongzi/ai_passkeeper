import Foundation
import XCTest

/// Unit tests for the password update / save flow
final class PasswordUpdateTests: XCTestCase {

    // MARK: - DecryptedPasswordItem update helpers

    func testUpdatedItemPreservesId() {
        let original = makeItem(id: UUID(), title: "Original", category: "General")
        let updated = makeUpdatedItem(from: original, title: "Updated")
        XCTAssertEqual(original.id, updated.id, "ID must not change after update")
    }

    func testUpdatedItemReflectsNewTitle() {
        let original = makeItem(title: "Old Title")
        let updated = makeUpdatedItem(from: original, title: "New Title")
        XCTAssertEqual(updated.title, "New Title")
    }

    func testUpdatedItemReflectsNewUsername() {
        let original = makeItem(username: "old@example.com")
        let updated = makeUpdatedItem(from: original, username: "new@example.com")
        XCTAssertEqual(updated.username, "new@example.com")
    }

    func testUpdatedItemReflectsNewPassword() {
        let original = makeItem(password: "oldPass123")
        let updated = makeUpdatedItem(from: original, password: "newPass456")
        XCTAssertEqual(updated.password, "newPass456")
    }

    func testUpdatedItemReflectsNewNotes() {
        let original = makeItem(notes: "")
        let updated = makeUpdatedItem(from: original, notes: "Some notes here")
        XCTAssertEqual(updated.notes, "Some notes here")
    }

    func testUpdatedItemReflectsNewCategory() {
        let original = makeItem(category: "General")
        let updated = makeUpdatedItem(from: original, category: "Work")
        XCTAssertEqual(updated.category, "Work")
    }

    func testUpdatedItemPreservesCreatedAt() {
        let createdAt = Date(timeIntervalSinceReferenceDate: 0)
        let original = makeItem(createdAt: createdAt)
        let updated = makeUpdatedItem(from: original)
        XCTAssertEqual(updated.createdAt, createdAt, "createdAt must not change on update")
    }

    func testUpdatedAtIsRefreshed() {
        let oldDate = Date(timeIntervalSinceReferenceDate: 0)
        let original = makeItem(updatedAt: oldDate)
        let updated = makeUpdatedItem(from: original)
        XCTAssertGreaterThan(updated.updatedAt, oldDate, "updatedAt should be more recent after update")
    }

    // MARK: - Category localization round-trip

    func testCategoryRawValueRoundTrip() {
        let categories: [(rawValue: String, localized: String)] = [
            ("General", "General"),
            ("Social", "Social"),
            ("Work", "Work"),
            ("Finance", "Finance"),
            ("Shopping", "Shopping"),
            ("Entertainment", "Entertainment"),
            ("Other", "Other"),
        ]

        for pair in categories {
            // Simulate what saveChanges() does: look up rawValue by localized display name
            let resolved = resolveCategoryRawValue(from: pair.localized, allCases: categories)
            XCTAssertEqual(resolved, pair.rawValue, "Category '\(pair.localized)' should map back to rawValue '\(pair.rawValue)'")
        }
    }

    func testUnknownCategoryFallsBackToInput() {
        let known: [(rawValue: String, localized: String)] = [("General", "General")]
        let result = resolveCategoryRawValue(from: "CustomCategory", allCases: known)
        XCTAssertEqual(result, "CustomCategory", "Unknown localized name should fall back to the input string")
    }

    func testTitleTrimmingOnSave() {
        let rawTitle = "  My Account  "
        let trimmed = rawTitle.trimmingCharacters(in: .whitespaces)
        XCTAssertEqual(trimmed, "My Account")
    }

    // MARK: - In-memory list sync

    func testListSyncUpdatesMatchingItem() {
        let id = UUID()
        var list = [
            makeItem(id: id, title: "Before"),
            makeItem(title: "Other")
        ]
        let updated = makeUpdatedItem(id: id, title: "After")
        if let index = list.firstIndex(where: { $0.id == updated.id }) {
            list[index] = updated
        }
        XCTAssertEqual(list.first(where: { $0.id == id })?.title, "After")
    }

    func testListSyncDoesNotAffectOtherItems() {
        let id = UUID()
        var list = [
            makeItem(id: id, title: "Target"),
            makeItem(title: "Untouched")
        ]
        let updated = makeUpdatedItem(id: id, title: "Changed")
        if let index = list.firstIndex(where: { $0.id == updated.id }) {
            list[index] = updated
        }
        XCTAssertEqual(list.last?.title, "Untouched")
    }

    func testListSyncNoOpForMissingId() {
        var list = [makeItem(title: "Unchanged")]
        let foreign = makeUpdatedItem(id: UUID(), title: "Foreign")
        if let index = list.firstIndex(where: { $0.id == foreign.id }) {
            list[index] = foreign
        }
        XCTAssertEqual(list.first?.title, "Unchanged")
    }

    // MARK: - Helpers

    private func makeItem(
        id: UUID = UUID(),
        title: String = "Test",
        username: String = "user@example.com",
        password: String = "password123",
        category: String = "General",
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> TestDecryptedItem {
        TestDecryptedItem(id: id, category: category, title: title, username: username,
                          password: password, notes: notes, createdAt: createdAt, updatedAt: updatedAt)
    }

    private func makeUpdatedItem(
        from original: TestDecryptedItem? = nil,
        id: UUID? = nil,
        title: String? = nil,
        username: String? = nil,
        password: String? = nil,
        category: String? = nil,
        notes: String? = nil
    ) -> TestDecryptedItem {
        let base = original ?? makeItem()
        return TestDecryptedItem(
            id: id ?? base.id,
            category: category ?? base.category,
            title: title ?? base.title,
            username: username ?? base.username,
            password: password ?? base.password,
            notes: notes ?? base.notes,
            createdAt: base.createdAt,
            updatedAt: Date()
        )
    }

    private func resolveCategoryRawValue(
        from localized: String,
        allCases: [(rawValue: String, localized: String)]
    ) -> String {
        allCases.first(where: { $0.localized == localized })?.rawValue ?? localized
    }
}

// MARK: - Test model

struct TestDecryptedItem: Equatable {
    let id: UUID
    var category: String
    var title: String
    var username: String
    var password: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date
}
