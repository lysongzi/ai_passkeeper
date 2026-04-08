import Foundation
import Combine

/// ViewModel for password list
@MainActor
final class PasswordListViewModel: ObservableObject {

    @Published var passwords: [DecryptedPasswordItem] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String = "category.all".localized
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var customCategories: [CustomCategory] = []

    private let repository = PasswordRepository()
    private var cancellables = Set<AnyCancellable>()

    var categories: [String] {
        ["category.all".localized] + PasswordCategory.allCases.map { $0.localizedName } + customCategories.map(\.name)
    }

    init() {
        setupSearchObserver()
        setupVaultLockObserver()
        loadCustomCategories()
    }

    private func setupSearchObserver() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task { await self?.performSearch(query: query) }
            }
            .store(in: &cancellables)
    }

    private func setupVaultLockObserver() {
        NotificationCenter.default.publisher(for: .vaultLocked)
            .sink { [weak self] _ in
                self?.clearSensitiveData()
            }
            .store(in: &cancellables)
    }

    func loadCustomCategories() {
        do {
            customCategories = try repository.fetchCustomCategories()
            normalizeSelectedCategoryIfNeeded()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshCategoriesAndPasswords() async {
        loadCustomCategories()
        await loadPasswords()
    }

    func loadPasswords() async {
        isLoading = true
        errorMessage = nil

        do {
            if selectedCategory == "category.all".localized || selectedCategory == "All" {
                passwords = try await repository.fetchAllItems()
            } else {
                let matchingCategory = PasswordCategory.allCases.first { $0.localizedName == selectedCategory }
                let categoryKey = matchingCategory?.rawValue ?? selectedCategory
                passwords = try await repository.fetchItems(category: categoryKey)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func filterByCategory(_ category: String) async {
        selectedCategory = category
        await loadPasswords()
    }

    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            await loadPasswords()
            return
        }

        isLoading = true
        do {
            passwords = try await repository.searchItems(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func updatePassword(_ item: DecryptedPasswordItem) async {
        do {
            try await repository.updateItem(
                id: item.id,
                title: item.title,
                username: item.username,
                password: item.password,
                category: item.category,
                phoneNumber: item.phoneNumber,
                email: item.email,
                notes: item.notes
            )
            if let index = passwords.firstIndex(where: { $0.id == item.id }) {
                passwords[index] = item
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePassword(_ item: DecryptedPasswordItem) async {
        do {
            try repository.deleteItem(id: item.id)
            passwords.removeAll { $0.id == item.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func clearSensitiveData() {
        passwords = []
    }

    func securelyClearAllData() {
        passwords = []
        searchText = ""
        selectedCategory = "category.all".localized
    }

    private func normalizeSelectedCategoryIfNeeded() {
        let current = selectedCategory
        if current == "All" {
            selectedCategory = "category.all".localized
            return
        }

        let builtInLocalized = Set(PasswordCategory.allCases.map(\.localizedName))
        if current == "category.all".localized || builtInLocalized.contains(current) || customCategories.map(\.name).contains(current) {
            return
        }

        if PasswordCategory.allCases.map(\.rawValue).contains(current),
           let localized = PasswordCategory.allCases.first(where: { $0.rawValue == current })?.localizedName {
            selectedCategory = localized
            return
        }

        selectedCategory = "category.all".localized
    }
}
