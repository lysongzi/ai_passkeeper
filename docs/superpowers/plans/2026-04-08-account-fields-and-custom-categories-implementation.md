# Account Fields and Custom Categories Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add optional phone/email fields to password records, unify add/edit/detail field presentation, and support user-managed custom categories in settings, selectors, and main-page filtering.

**Architecture:** Extend the existing password record model and SQLite schema in place, then layer a lightweight custom-category persistence path alongside the existing built-in category model. UI work stays inside the current SwiftUI MVVM structure, with shared validation and category-source helpers feeding add/edit/detail/settings/main-screen flows.

**Tech Stack:** Swift, SwiftUI, SQLite.swift, XCTest/Xcodebuild, existing i18n service

---

## File map

### Existing files likely to modify
- `Sources/Models/PasswordItem.swift` — add phone/email fields and possibly custom category helper types.
- `Sources/Services/Storage/DatabaseManager.swift` — schema migration, CRUD, search query expansion, custom categories persistence if storage stays centralized.
- `Sources/Services/Storage/PasswordRepository.swift` — repository APIs for new fields and custom-category operations.
- `Sources/ViewModels/AddEditPasswordViewModel.swift` — form state, validation, save payload, category source updates.
- `Sources/ViewModels/PasswordListViewModel.swift` — category filter data source and refresh behavior.
- `Sources/ViewModels/SettingsViewModel.swift` — custom-category CRUD orchestration.
- `Sources/Views/Components/AddEditPasswordView.swift` — insert phone/email fields, unify required/optional labels.
- `Sources/Views/Components/PasswordDetailView.swift` — display/edit phone/email in the unified order.
- `Sources/Views/Components/SidebarView.swift` — include custom categories in main-page quick filters.
- `Sources/Views/Components/SettingsView.swift` — add category-management UI.
- `Sources/Services/I18nService.swift` or localization backing files — add strings for new labels/errors/category-management copy.

### Possible new files
- `Sources/Models/CustomCategory.swift` — explicit model for user-defined categories if not embedded into `PasswordItem.swift`.
- `Sources/Services/Validation/AccountFieldValidator.swift` — shared phone/email validation helpers if extracting from view model keeps code smaller.
- `Sources/Services/Storage/CategoryStore.swift` — dedicated persistence wrapper if custom-category logic would bloat `DatabaseManager.swift` too much.
- `SourcesTests/...` — unit coverage for storage, validation, and view-model logic if a test target exists or is added.

---

### Task 1: Document exact touch points and create the implementation branch

**Files:**
- Modify: `docs/superpowers/specs/2026-04-08-account-fields-and-custom-categories-design.md`
- Create/Modify: git branch only

- [ ] **Step 1: Verify the approved spec is present and capture the active branch**

Run:
```bash
git branch --show-current
sed -n '1,260p' docs/superpowers/specs/2026-04-08-account-fields-and-custom-categories-design.md
```

Expected:
- Current branch prints `main` or the current integration branch.
- The spec file exists and includes phone/email plus custom-category requirements.

- [ ] **Step 2: Create a feature branch for this proposal**

Run:
```bash
git checkout -b feature/account-fields-custom-categories
```

Expected:
- Git reports a new branch named `feature/account-fields-custom-categories`.

- [ ] **Step 3: Reconfirm working tree status before code changes**

Run:
```bash
git status --short
```

Expected:
- Only known unrelated files remain, and the new branch is active.

- [ ] **Step 4: Commit if any branch-only metadata or plan note was updated**

```bash
git add docs/superpowers/specs/2026-04-08-account-fields-and-custom-categories-design.md
# Commit only if Step 1-3 caused tracked file changes; otherwise skip commit for this task.
```

### Task 2: Add password-record phone/email fields and database migration support

**Files:**
- Modify: `Sources/Models/PasswordItem.swift`
- Modify: `Sources/Services/Storage/DatabaseManager.swift`
- Modify: `Sources/Services/Storage/PasswordRepository.swift`
- Test: storage-focused XCTest file if available, otherwise add a new focused test file under the existing test target

- [ ] **Step 1: Write the failing storage test for phone/email persistence and search coverage**

```swift
func testPasswordItemPersistsPhoneAndEmailAndSearchCanFindThem() async throws {
    let repository = PasswordRepository(databaseManager: testDatabaseManager, securityService: testSecurityService)

    let item = try await repository.addItem(
        title: "GitHub",
        username: "octocat",
        password: "Secret123!",
        category: "General",
        phoneNumber: "+1 415 555 0101",
        email: "octo@example.com",
        notes: "work account"
    )

    let fetched = try await repository.getItem(id: item.id)
    XCTAssertEqual(fetched?.phoneNumber, "+1 415 555 0101")
    XCTAssertEqual(fetched?.email, "octo@example.com")

    let phoneMatches = try await repository.searchItems(query: "415 555")
    XCTAssertTrue(phoneMatches.contains(where: { $0.id == item.id }))

    let emailMatches = try await repository.searchItems(query: "octo@example.com")
    XCTAssertTrue(emailMatches.contains(where: { $0.id == item.id }))
}
```

- [ ] **Step 2: Run the targeted test to verify it fails**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<StorageTestClass>/testPasswordItemPersistsPhoneAndEmailAndSearchCanFindThem
```

Expected:
- Build/test fails because repository/model APIs do not yet accept or return phone/email fields.

- [ ] **Step 3: Implement the minimal model, schema, migration, CRUD, and search changes**

```swift
struct PasswordItem: Identifiable, Codable, Equatable {
    let id: UUID
    var category: String
    var title: String
    var username: String
    var encryptedPassword: Data
    var phoneNumber: String
    var email: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    var searchIndex: [String]

    static func createSearchIndex(
        title: String,
        username: String,
        phoneNumber: String,
        email: String
    ) -> [String] {
        let normalized = [title, username, phoneNumber, email]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        return normalized + [normalized.joined(separator: " ")]
    }
}
```

```swift
private let colPhoneNumber = SQLite.Expression<String>("phoneNumber")
private let colEmail = SQLite.Expression<String>("email")

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

    try addColumnIfNeeded(name: "phoneNumber", definition: "TEXT NOT NULL DEFAULT ''")
    try addColumnIfNeeded(name: "email", definition: "TEXT NOT NULL DEFAULT ''")
}
```

```swift
let searchQuery = passwords.filter(
    colTitle.lowercaseString.like("%\(lowercasedQuery)%") ||
    colUsername.lowercaseString.like("%\(lowercasedQuery)%") ||
    colCategory.lowercaseString.like("%\(lowercasedQuery)%") ||
    colPhoneNumber.lowercaseString.like("%\(lowercasedQuery)%") ||
    colEmail.lowercaseString.like("%\(lowercasedQuery)%")
)
```

- [ ] **Step 4: Run the targeted storage test to verify it passes**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<StorageTestClass>/testPasswordItemPersistsPhoneAndEmailAndSearchCanFindThem
```

Expected:
- The targeted test passes.

- [ ] **Step 5: Commit the storage/model change**

```bash
git add Sources/Models/PasswordItem.swift Sources/Services/Storage/DatabaseManager.swift Sources/Services/Storage/PasswordRepository.swift SourcesTests
git commit -m "feat: add phone and email storage for password items"
```

### Task 3: Add shared validation and form/view-model support for phone/email plus unified field semantics

**Files:**
- Modify: `Sources/ViewModels/AddEditPasswordViewModel.swift`
- Modify: `Sources/Views/Components/AddEditPasswordView.swift`
- Modify: `Sources/Services/I18nService.swift` or localization resources
- Create: `Sources/Services/Validation/AccountFieldValidator.swift` if extraction improves reuse
- Test: view-model/validator XCTest file

- [ ] **Step 1: Write the failing validation tests for optional email and loose phone rules**

```swift
func testSaveRejectsInvalidEmailButAllowsEmptyPhoneAndEmail() async throws {
    let viewModel = AddEditPasswordViewModel(repository: repository)
    viewModel.title = "GitHub"
    viewModel.username = "octocat"
    viewModel.password = "Secret123!"
    viewModel.category = PasswordCategory.general.localizedName
    viewModel.email = "invalid-email"

    let saved = await viewModel.save()

    XCTAssertFalse(saved)
    XCTAssertEqual(viewModel.errorMessage, "validation.email.invalid".localized)
}

func testSaveRejectsClearlyInvalidPhoneNumber() async throws {
    let viewModel = AddEditPasswordViewModel(repository: repository)
    viewModel.title = "GitHub"
    viewModel.username = "octocat"
    viewModel.password = "Secret123!"
    viewModel.category = PasswordCategory.general.localizedName
    viewModel.phoneNumber = "12"

    let saved = await viewModel.save()

    XCTAssertFalse(saved)
    XCTAssertEqual(viewModel.errorMessage, "validation.phone.invalid".localized)
}
```

- [ ] **Step 2: Run the targeted validation test to verify it fails**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<ValidationTestClass>
```

Expected:
- Tests fail because phone/email fields and validation behavior are missing.

- [ ] **Step 3: Implement validator helpers, view-model state, save wiring, and unified form labels**

```swift
enum AccountFieldValidator {
    static func isValidEmail(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return trimmed.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    static func isValidPhoneNumber(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        let normalized = trimmed.replacingOccurrences(of: #"[\s\-\(\)]"#, with: "", options: .regularExpression)
        let allowed = CharacterSet(charactersIn: "+0123456789")
        return normalized.count >= 6 && normalized.count <= 20 && normalized.unicodeScalars.allSatisfy(allowed.contains)
    }
}
```

```swift
@Published var phoneNumber: String = ""
@Published var email: String = ""

private func validateOptionalFields() -> String? {
    if !AccountFieldValidator.isValidPhoneNumber(phoneNumber) {
        return "validation.phone.invalid".localized
    }
    if !AccountFieldValidator.isValidEmail(email) {
        return "validation.email.invalid".localized
    }
    return nil
}
```

```swift
fieldSection(title: "detail.phone".localized, optional: true) {
    TextField(text: $viewModel.phoneNumber, prompt: Text("addEdit.placeholder.phone".localized)) { }
}

fieldSection(title: "detail.email".localized, optional: true) {
    TextField(text: $viewModel.email, prompt: Text("addEdit.placeholder.email".localized)) { }
}
```

- [ ] **Step 4: Run the targeted validation/form tests to verify they pass**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<ValidationTestClass>
```

Expected:
- The new validation tests pass.

- [ ] **Step 5: Commit the validation and add/edit form changes**

```bash
git add Sources/ViewModels/AddEditPasswordViewModel.swift Sources/Views/Components/AddEditPasswordView.swift Sources/Services/I18nService.swift Sources/Services/Validation SourcesTests
git commit -m "feat: validate and edit phone and email fields"
```

### Task 4: Update detail screen editing/presentation to include phone/email in the unified order

**Files:**
- Modify: `Sources/Views/Components/PasswordDetailView.swift`
- Modify: `Sources/ViewModels/AddEditPasswordViewModel.swift` if shared state or mappers need changes
- Test: detail-view/view-model XCTest or snapshot-style assertions if already present

- [ ] **Step 1: Write the failing test covering detail mapping and save propagation for phone/email**

```swift
func testDetailSavePropagatesPhoneAndEmailChanges() async throws {
    let original = DecryptedPasswordItem(
        id: UUID(),
        category: "General",
        title: "GitHub",
        username: "octocat",
        password: "Secret123!",
        phoneNumber: "+1 415 555 0101",
        email: "old@example.com",
        notes: ""
    )

    var savedItem: DecryptedPasswordItem?
    let view = PasswordDetailViewNew(item: original, onSave: { updated in savedItem = updated })

    // test harness drives edit fields then save
    XCTAssertEqual(savedItem?.phoneNumber, "+1 415 555 0202")
    XCTAssertEqual(savedItem?.email, "new@example.com")
}
```

- [ ] **Step 2: Run the targeted test to verify it fails**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<DetailTestClass>
```

Expected:
- Tests fail because detail view/item models do not yet carry phone/email.

- [ ] **Step 3: Implement the minimal detail-view changes**

```swift
struct DecryptedPasswordItem: Identifiable, Equatable {
    let id: UUID
    var category: String
    var title: String
    var username: String
    var password: String
    var phoneNumber: String
    var email: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date
}
```

```swift
@State private var editedPhoneNumber: String = ""
@State private var editedEmail: String = ""

editableFieldSection(title: "detail.phone".localized, optional: true, text: $editedPhoneNumber)
editableFieldSection(title: "detail.email".localized, optional: true, text: $editedEmail)
```

- [ ] **Step 4: Run the targeted test to verify it passes**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<DetailTestClass>
```

Expected:
- Detail tests pass and confirm save propagation.

- [ ] **Step 5: Commit the detail-screen update**

```bash
git add Sources/Models/PasswordItem.swift Sources/Views/Components/PasswordDetailView.swift SourcesTests
git commit -m "feat: show phone and email in password detail"
```

### Task 5: Add custom-category persistence and deletion guardrails

**Files:**
- Create or Modify: `Sources/Models/CustomCategory.swift`
- Modify: `Sources/Services/Storage/DatabaseManager.swift`
- Modify: `Sources/Services/Storage/PasswordRepository.swift`
- Modify: `Sources/ViewModels/SettingsViewModel.swift`
- Test: category storage/view-model XCTest file

- [ ] **Step 1: Write the failing tests for custom-category CRUD and delete-in-use rejection**

```swift
func testCustomCategoryCRUDAndDeleteInUseProtection() async throws {
    let repository = PasswordRepository(databaseManager: testDatabaseManager, securityService: testSecurityService)

    let travel = try await repository.createCustomCategory(name: "Travel")
    XCTAssertTrue(try await repository.fetchCustomCategories().contains(where: { $0.name == "Travel" }))

    let renamed = try await repository.renameCustomCategory(id: travel.id, name: "Trips")
    XCTAssertEqual(renamed.name, "Trips")

    _ = try await repository.addItem(
        title: "Airline",
        username: "octocat",
        password: "Secret123!",
        category: "Trips",
        phoneNumber: "",
        email: "",
        notes: ""
    )

    await XCTAssertThrowsErrorAsync(try await repository.deleteCustomCategory(id: travel.id)) { error in
        XCTAssertEqual(error as? CategoryStoreError, .categoryInUse)
    }
}
```

- [ ] **Step 2: Run the targeted category test to verify it fails**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<CategoryTestClass>
```

Expected:
- Tests fail because custom-category APIs/storage do not yet exist.

- [ ] **Step 3: Implement the minimal custom-category model, table, repository APIs, and guardrails**

```swift
struct CustomCategory: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
}

enum CategoryStoreError: LocalizedError, Equatable {
    case emptyName
    case duplicateName
    case categoryInUse
}
```

```swift
private let customCategories = Table("custom_categories")
private let colCustomCategoryId = SQLite.Expression<String>("id")
private let colCustomCategoryName = SQLite.Expression<String>("name")
private let colCustomCategoryCreatedAt = SQLite.Expression<Double>("createdAt")
private let colCustomCategoryUpdatedAt = SQLite.Expression<Double>("updatedAt")
```

```swift
func deleteCustomCategory(id: UUID) throws {
    let category = try fetchCustomCategory(id: id)
    let inUseCount = try db.scalar(passwords.filter(colCategory == category.name).count)
    guard inUseCount == 0 else {
        throw CategoryStoreError.categoryInUse
    }
    try db.run(customCategories.filter(colCustomCategoryId == id.uuidString).delete())
}
```

- [ ] **Step 4: Run the targeted category test to verify it passes**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<CategoryTestClass>
```

Expected:
- Category CRUD tests pass, including delete-in-use rejection.

- [ ] **Step 5: Commit the custom-category persistence changes**

```bash
git add Sources/Models/CustomCategory.swift Sources/Services/Storage/DatabaseManager.swift Sources/Services/Storage/PasswordRepository.swift Sources/ViewModels/SettingsViewModel.swift SourcesTests
git commit -m "feat: add custom category storage and safeguards"
```

### Task 6: Wire custom categories into add/edit selectors, main-page filters, and settings management UI

**Files:**
- Modify: `Sources/ViewModels/AddEditPasswordViewModel.swift`
- Modify: `Sources/ViewModels/PasswordListViewModel.swift`
- Modify: `Sources/ViewModels/SettingsViewModel.swift`
- Modify: `Sources/Views/Components/AddEditPasswordView.swift`
- Modify: `Sources/Views/Components/SidebarView.swift`
- Modify: `Sources/Views/Components/SettingsView.swift`
- Modify: localization backing files
- Test: relevant view-model XCTest file(s)

- [ ] **Step 1: Write the failing tests for merged category source visibility across add/edit, sidebar, and settings actions**

```swift
func testCustomCategoriesAppearInSelectorsAndSidebarFilters() async throws {
    let repository = FakePasswordRepository()
    repository.customCategories = [CustomCategory(id: UUID(), name: "Travel", createdAt: .now, updatedAt: .now)]

    let addEditViewModel = AddEditPasswordViewModel(repository: repository)
    await addEditViewModel.reloadCategories()
    XCTAssertTrue(addEditViewModel.categories.contains("Travel"))

    let listViewModel = PasswordListViewModel(repository: repository)
    await listViewModel.reloadCategories()
    XCTAssertTrue(listViewModel.availableCategories.contains("Travel"))
}
```

- [ ] **Step 2: Run the targeted selector/filter test to verify it fails**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<SelectorTestClass>
```

Expected:
- Tests fail because the UI/view-model category sources still only use built-in categories.

- [ ] **Step 3: Implement merged category sourcing and settings CRUD UI**

```swift
@MainActor
func reloadCategories() async {
    let builtIn = PasswordCategory.allCases.map(\.localizedName)
    let custom = (try? await repository.fetchCustomCategories())?.map(\.name) ?? []
    categories = builtIn + custom
}
```

```swift
Section(header: Text("settings.categories.custom".localized)) {
    ForEach(viewModel.customCategories) { category in
        CustomCategoryRow(
            category: category,
            onRename: { newName in await viewModel.renameCategory(category.id, to: newName) },
            onDelete: { await viewModel.deleteCategory(category.id) }
        )
    }

    Button("settings.categories.add".localized) {
        viewModel.isPresentingAddCategory = true
    }
}
```

```swift
ForEach(viewModel.availableCategories, id: \.self) { category in
    CategoryFilterChip(
        title: category,
        isSelected: viewModel.selectedCategory == category,
        onTap: { viewModel.selectCategory(category) }
    )
}
```

- [ ] **Step 4: Run the targeted selector/filter tests to verify they pass**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<SelectorTestClass>
```

Expected:
- Tests pass and confirm custom categories flow through selectors and filters.

- [ ] **Step 5: Commit the UI wiring for custom categories**

```bash
git add Sources/ViewModels/AddEditPasswordViewModel.swift Sources/ViewModels/PasswordListViewModel.swift Sources/ViewModels/SettingsViewModel.swift Sources/Views/Components/AddEditPasswordView.swift Sources/Views/Components/SidebarView.swift Sources/Views/Components/SettingsView.swift Sources/Services/I18nService.swift SourcesTests
git commit -m "feat: wire custom categories into forms and filters"
```

### Task 7: Run full verification and finish the branch for review

**Files:**
- Modify: any files needed to fix verification failures

- [ ] **Step 1: Run the focused test targets for all changed areas**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:SourcesTests/<StorageTestClass> -only-testing:SourcesTests/<ValidationTestClass> -only-testing:SourcesTests/<DetailTestClass> -only-testing:SourcesTests/<CategoryTestClass> -only-testing:SourcesTests/<SelectorTestClass>
```

Expected:
- All targeted tests pass.

- [ ] **Step 2: Run an app build for integration verification**

Run:
```bash
TMPDIR=/tmp xcodebuild -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -clonedSourcePackagesDirPath /tmp/spm-cache -derivedDataPath /tmp/DerivedData build
```

Expected:
- Build succeeds with no new compile errors.

- [ ] **Step 3: Sanity-check git diff and status**

Run:
```bash
git status --short
git log --oneline --decorate -5
```

Expected:
- Only intended files changed.
- Recent commits reflect storage, validation/detail, and custom-category work.

- [ ] **Step 4: Commit any last verification fixes**

```bash
git add Sources docs/superpowers/plans docs/superpowers/specs SourcesTests
git commit -m "test: finalize account fields and custom categories verification"
```

- [ ] **Step 5: Prepare review summary**

Include in handoff:
```text
- Branch: feature/account-fields-custom-categories
- Verified via targeted tests and full macOS build
- Key areas: storage migration, validation, detail/add-edit UI, custom category settings and filters
```
