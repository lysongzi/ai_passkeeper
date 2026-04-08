import Foundation
import SQLite

/// Database manager for SQLite operations using SQLite.swift
final class DatabaseManager {

    static let shared = DatabaseManager()

    private var db: Connection?

    // Table definition
    private let passwords = Table("passwords")
    private let customCategories = Table("custom_categories")
    private let colId = SQLite.Expression<String>("id")
    private let colCategory = SQLite.Expression<String>("category")
    private let colTitle = SQLite.Expression<String>("title")
    private let colUsername = SQLite.Expression<String>("username")
    private let colEncryptedPassword = SQLite.Expression<Data>("encryptedPassword")
    private let colPhoneNumber = SQLite.Expression<String>("phoneNumber")
    private let colEmail = SQLite.Expression<String>("email")
    private let colNotes = SQLite.Expression<String>("notes")
    private let colCreatedAt = SQLite.Expression<Double>("createdAt")
    private let colUpdatedAt = SQLite.Expression<Double>("updatedAt")
    private let colSearchIndex = SQLite.Expression<String>("searchIndex")

    private init() {
        do {
            try setupDatabase()
        } catch {
            print("Database setup failed: \(error)")
        }
    }

    // MARK: - Setup

    private func setupDatabase() throws {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("PassKeeper", isDirectory: true)

        if !fileManager.fileExists(atPath: appFolder.path) {
            try fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true)
        }

        let dbPath = appFolder.appendingPathComponent("passwords.sqlite").path
        db = try Connection(dbPath)
        try createTables()
    }

    private func createTables() throws {
        try db?.run(passwords.create(ifNotExists: true) { table in
            table.column(colId, primaryKey: true)
            table.column(colCategory, defaultValue: "General")
            table.column(colTitle)
            table.column(colUsername)
            table.column(colEncryptedPassword)
            table.column(colPhoneNumber, defaultValue: "")
            table.column(colEmail, defaultValue: "")
            table.column(colNotes, defaultValue: "")
            table.column(colCreatedAt)
            table.column(colUpdatedAt)
            table.column(colSearchIndex, defaultValue: "[]")
        })

        try db?.run(customCategories.create(ifNotExists: true) { table in
            table.column(colId, primaryKey: true)
            table.column(colTitle, unique: true)
            table.column(colCreatedAt)
            table.column(colUpdatedAt)
        })

        try addColumnIfNeeded(name: "phoneNumber", definition: "TEXT NOT NULL DEFAULT ''")
        try addColumnIfNeeded(name: "email", definition: "TEXT NOT NULL DEFAULT ''")
    }

    private func addColumnIfNeeded(name: String, definition: String) throws {
        guard let db else { throw DatabaseError.notInitialized }
        let existingColumns = try db.prepare("PRAGMA table_info(passwords)").compactMap { row -> String? in
            row[1] as? String
        }

        guard !existingColumns.contains(name) else { return }
        try db.run("ALTER TABLE passwords ADD COLUMN \(name) \(definition)")
    }

    // MARK: - Password CRUD Operations

    func fetchAllPasswords() throws -> [PasswordItem] {
        guard let db else { throw DatabaseError.notInitialized }

        var items: [PasswordItem] = []
        for row in try db.prepare(passwords) {
            if let item = try? mapRowToPasswordItem(row) {
                items.append(item)
            }
        }
        return items
    }

    func fetchPassword(id: UUID) throws -> PasswordItem? {
        guard let db else { throw DatabaseError.notInitialized }
        let query = passwords.filter(colId == id.uuidString)
        guard let row = try db.pluck(query) else { return nil }
        return try mapRowToPasswordItem(row)
    }

    func insertPassword(_ item: PasswordItem) throws {
        guard let db else { throw DatabaseError.notInitialized }

        let searchIndexJSON = (try? JSONEncoder().encode(item.searchIndex))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

        let insert = passwords.insert(
            colId <- item.id.uuidString,
            colCategory <- item.category,
            colTitle <- item.title,
            colUsername <- item.username,
            colEncryptedPassword <- item.encryptedPassword,
            colPhoneNumber <- item.phoneNumber,
            colEmail <- item.email,
            colNotes <- item.notes,
            colCreatedAt <- item.createdAt.timeIntervalSince1970,
            colUpdatedAt <- item.updatedAt.timeIntervalSince1970,
            colSearchIndex <- searchIndexJSON
        )

        try db.run(insert)
    }

    func updatePassword(_ item: PasswordItem) throws {
        guard let db else { throw DatabaseError.notInitialized }

        let searchIndexJSON = (try? JSONEncoder().encode(item.searchIndex))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"

        let passwordRow = passwords.filter(colId == item.id.uuidString)

        try db.run(passwordRow.update(
            colCategory <- item.category,
            colTitle <- item.title,
            colUsername <- item.username,
            colEncryptedPassword <- item.encryptedPassword,
            colPhoneNumber <- item.phoneNumber,
            colEmail <- item.email,
            colNotes <- item.notes,
            colUpdatedAt <- item.updatedAt.timeIntervalSince1970,
            colSearchIndex <- searchIndexJSON
        ))
    }

    func deletePassword(id: UUID) throws {
        guard let db else { throw DatabaseError.notInitialized }
        let passwordRow = passwords.filter(colId == id.uuidString)
        try db.run(passwordRow.delete())
    }

    func searchPasswords(query: String) throws -> [PasswordItem] {
        guard let db else { throw DatabaseError.notInitialized }

        let lowercasedQuery = query.lowercased()
        let searchQuery = passwords.filter(
            colTitle.lowercaseString.like("%\(lowercasedQuery)%") ||
            colUsername.lowercaseString.like("%\(lowercasedQuery)%") ||
            colCategory.lowercaseString.like("%\(lowercasedQuery)%") ||
            colPhoneNumber.lowercaseString.like("%\(lowercasedQuery)%") ||
            colEmail.lowercaseString.like("%\(lowercasedQuery)%")
        )

        var items: [PasswordItem] = []
        for row in try db.prepare(searchQuery) {
            if let item = try? mapRowToPasswordItem(row) {
                items.append(item)
            }
        }
        return items
    }

    func fetchPasswords(category: String) throws -> [PasswordItem] {
        guard let db else { throw DatabaseError.notInitialized }
        let query = passwords.filter(colCategory == category)

        var items: [PasswordItem] = []
        for row in try db.prepare(query) {
            if let item = try? mapRowToPasswordItem(row) {
                items.append(item)
            }
        }
        return items
    }

    // MARK: - Custom Categories

    func fetchCustomCategories() throws -> [CustomCategory] {
        guard let db else { throw DatabaseError.notInitialized }

        var items: [CustomCategory] = []
        for row in try db.prepare(customCategories.order(colCreatedAt.asc)) {
            if let item = try? mapRowToCustomCategory(row) {
                items.append(item)
            }
        }
        return items
    }

    func insertCustomCategory(_ category: CustomCategory) throws {
        guard let db else { throw DatabaseError.notInitialized }
        let trimmedName = category.name.trimmingCharacters(in: .whitespacesAndNewlines)
        try db.run(customCategories.insert(
            colId <- category.id.uuidString,
            colTitle <- trimmedName,
            colCreatedAt <- category.createdAt.timeIntervalSince1970,
            colUpdatedAt <- category.updatedAt.timeIntervalSince1970
        ))
    }

    func updateCustomCategory(id: UUID, name: String) throws {
        guard let db else { throw DatabaseError.notInitialized }
        let categoryRow = customCategories.filter(colId == id.uuidString)
        try db.run(categoryRow.update(
            colTitle <- name.trimmingCharacters(in: .whitespacesAndNewlines),
            colUpdatedAt <- Date().timeIntervalSince1970
        ))
    }

    func deleteCustomCategory(id: UUID) throws {
        guard let db else { throw DatabaseError.notInitialized }
        let categoryRow = customCategories.filter(colId == id.uuidString)
        try db.run(categoryRow.delete())
    }

    func fetchCustomCategory(id: UUID) throws -> CustomCategory? {
        guard let db else { throw DatabaseError.notInitialized }
        let query = customCategories.filter(colId == id.uuidString)
        guard let row = try db.pluck(query) else { return nil }
        return try mapRowToCustomCategory(row)
    }

    func fetchCustomCategory(name: String) throws -> CustomCategory? {
        guard let db else { throw DatabaseError.notInitialized }
        let query = customCategories.filter(colTitle == name.trimmingCharacters(in: .whitespacesAndNewlines))
        guard let row = try db.pluck(query) else { return nil }
        return try mapRowToCustomCategory(row)
    }

    func isCategoryInUse(_ name: String) throws -> Bool {
        guard let db else { throw DatabaseError.notInitialized }
        return try db.pluck(passwords.filter(colCategory == name)) != nil
    }

    // MARK: - Helper

    private func mapRowToPasswordItem(_ row: Row) throws -> PasswordItem {
        guard let id = UUID(uuidString: row[colId]) else {
            throw DatabaseError.invalidData
        }

        let searchIndexJSON: String = row[colSearchIndex]
        var searchIndex: [String] = []
        if let data = searchIndexJSON.data(using: .utf8) {
            searchIndex = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }

        return PasswordItem(
            id: id,
            category: row[colCategory],
            title: row[colTitle],
            username: row[colUsername],
            encryptedPassword: row[colEncryptedPassword],
            phoneNumber: row[colPhoneNumber],
            email: row[colEmail],
            notes: row[colNotes],
            createdAt: Date(timeIntervalSince1970: row[colCreatedAt]),
            updatedAt: Date(timeIntervalSince1970: row[colUpdatedAt]),
            searchIndex: searchIndex
        )
    }

    private func mapRowToCustomCategory(_ row: Row) throws -> CustomCategory {
        guard let id = UUID(uuidString: row[colId]) else {
            throw DatabaseError.invalidData
        }

        return CustomCategory(
            id: id,
            name: row[colTitle],
            createdAt: Date(timeIntervalSince1970: row[colCreatedAt]),
            updatedAt: Date(timeIntervalSince1970: row[colUpdatedAt])
        )
    }
}

/// Database errors
enum DatabaseError: LocalizedError {
    case notInitialized
    case insertFailed
    case updateFailed
    case deleteFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Database not initialized"
        case .insertFailed:
            return "Failed to insert record"
        case .updateFailed:
            return "Failed to update record"
        case .deleteFailed:
            return "Failed to delete record"
        case .invalidData:
            return "Invalid data format"
        }
    }
}
