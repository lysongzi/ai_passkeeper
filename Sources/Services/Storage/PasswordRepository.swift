import Foundation
import SQLite

/// Repository for password operations - coordinates security and storage
final class PasswordRepository {

    private let databaseManager = DatabaseManager.shared
    private let securityService = SecurityService()

    // MARK: - Read Operations

    func fetchAllItems() async throws -> [DecryptedPasswordItem] {
        let encryptedItems = try databaseManager.fetchAllPasswords()
        return try await decryptItems(encryptedItems)
    }

    func fetchItem(id: UUID) async throws -> DecryptedPasswordItem? {
        guard let encryptedItem = try databaseManager.fetchPassword(id: id) else {
            return nil
        }
        return try await decryptSingleItem(encryptedItem)
    }

    func searchItems(query: String) async throws -> [DecryptedPasswordItem] {
        let encryptedItems = try databaseManager.searchPasswords(query: query)
        return try await decryptItems(encryptedItems)
    }

    func fetchItems(category: String) async throws -> [DecryptedPasswordItem] {
        let encryptedItems = try databaseManager.fetchPasswords(category: category)
        return try await decryptItems(encryptedItems)
    }

    // MARK: - Write Operations

    func addItem(
        title: String,
        username: String,
        password: String,
        category: String,
        phoneNumber: String,
        email: String,
        notes: String
    ) async throws -> DecryptedPasswordItem {
        let encryptedPassword = try securityService.encrypt(password)
        let normalizedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchIndex = PasswordItem.createSearchIndex(
            title: title,
            username: username,
            phoneNumber: normalizedPhone,
            email: normalizedEmail
        )

        let item = PasswordItem(
            category: category,
            title: title,
            username: username,
            encryptedPassword: encryptedPassword,
            phoneNumber: normalizedPhone,
            email: normalizedEmail,
            notes: notes,
            searchIndex: searchIndex
        )

        try databaseManager.insertPassword(item)

        return DecryptedPasswordItem(
            id: item.id,
            category: item.category,
            title: item.title,
            username: item.username,
            password: password,
            phoneNumber: item.phoneNumber,
            email: item.email,
            notes: item.notes,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt
        )
    }

    func updateItem(
        id: UUID,
        title: String,
        username: String,
        password: String,
        category: String,
        phoneNumber: String,
        email: String,
        notes: String
    ) async throws {
        guard let existingItem = try databaseManager.fetchPassword(id: id) else {
            throw RepositoryError.itemNotFound
        }

        let encryptedPassword = try securityService.encrypt(password)
        let normalizedPhone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let searchIndex = PasswordItem.createSearchIndex(
            title: title,
            username: username,
            phoneNumber: normalizedPhone,
            email: normalizedEmail
        )

        let updatedItem = PasswordItem(
            id: existingItem.id,
            category: category,
            title: title,
            username: username,
            encryptedPassword: encryptedPassword,
            phoneNumber: normalizedPhone,
            email: normalizedEmail,
            notes: notes,
            createdAt: existingItem.createdAt,
            updatedAt: Date(),
            searchIndex: searchIndex
        )

        try databaseManager.updatePassword(updatedItem)
    }

    func deleteItem(id: UUID) throws {
        try databaseManager.deletePassword(id: id)
    }

    // MARK: - Custom Categories

    func fetchCustomCategories() throws -> [CustomCategory] {
        try databaseManager.fetchCustomCategories()
    }

    func createCustomCategory(name: String) throws -> CustomCategory {
        let normalizedName = normalizeCategoryName(name)
        try ensureCustomCategoryNameIsValid(normalizedName)

        let category = CustomCategory(name: normalizedName)
        do {
            try databaseManager.insertCustomCategory(category)
            return category
        } catch {
            if isConstraintViolation(error) {
                throw CategoryStoreError.duplicateName
            }
            throw error
        }
    }

    func updateCustomCategory(id: UUID, name: String) throws -> CustomCategory {
        guard let existing = try databaseManager.fetchCustomCategory(id: id) else {
            throw CategoryStoreError.categoryNotFound
        }

        let normalizedName = normalizeCategoryName(name)
        try ensureCustomCategoryNameIsValid(normalizedName, ignoring: id)

        do {
            try databaseManager.updateCustomCategory(id: id, name: normalizedName)
        } catch {
            if isConstraintViolation(error) {
                throw CategoryStoreError.duplicateName
            }
            throw error
        }

        return CustomCategory(id: existing.id, name: normalizedName, createdAt: existing.createdAt, updatedAt: Date())
    }

    func deleteCustomCategory(id: UUID) throws {
        guard let existing = try databaseManager.fetchCustomCategory(id: id) else {
            throw CategoryStoreError.categoryNotFound
        }

        if try databaseManager.isCategoryInUse(existing.name) {
            throw CategoryStoreError.categoryInUse
        }

        try databaseManager.deleteCustomCategory(id: id)
    }

    // MARK: - Private Helpers

    private func decryptItems(_ items: [PasswordItem]) async throws -> [DecryptedPasswordItem] {
        var decryptedItems: [DecryptedPasswordItem] = []

        for item in items {
            if let decrypted = try? await decryptSingleItem(item) {
                decryptedItems.append(decrypted)
            }
        }

        return decryptedItems
    }

    private func decryptSingleItem(_ item: PasswordItem) async throws -> DecryptedPasswordItem {
        let password = try securityService.decrypt(item.encryptedPassword)
        return DecryptedPasswordItem(from: item, password: password)
    }

    private func normalizeCategoryName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func ensureCustomCategoryNameIsValid(_ name: String, ignoring id: UUID? = nil) throws {
        guard !name.isEmpty else {
            throw CategoryStoreError.emptyName
        }
        guard !PasswordCategory.allCases.map(\.rawValue).contains(name) else {
            throw CategoryStoreError.builtInCategoryProtected
        }
        if let existing = try databaseManager.fetchCustomCategory(name: name), existing.id != id {
            throw CategoryStoreError.duplicateName
        }
    }

    private func isConstraintViolation(_ error: Error) -> Bool {
        let message = String(describing: error).lowercased()
        return message.contains("constraint") || message.contains("unique")
    }
}

/// Repository errors
enum RepositoryError: LocalizedError {
    case itemNotFound
    case encryptionFailed
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Password item not found"
        case .encryptionFailed:
            return "Failed to encrypt password"
        case .decryptionFailed:
            return "Failed to decrypt password"
        }
    }
}
