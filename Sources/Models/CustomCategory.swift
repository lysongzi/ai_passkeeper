import Foundation

struct CustomCategory: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum CategoryStoreError: LocalizedError, Equatable {
    case emptyName
    case duplicateName
    case builtInCategoryProtected
    case categoryInUse
    case categoryNotFound

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "settings.category.validation.empty".localized
        case .duplicateName:
            return "settings.category.validation.duplicate".localized
        case .builtInCategoryProtected:
            return "settings.category.validation.builtInProtected".localized
        case .categoryInUse:
            return "settings.category.validation.inUse".localized
        case .categoryNotFound:
            return "settings.category.validation.notFound".localized
        }
    }
}
