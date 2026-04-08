# Account Fields and Custom Categories Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add optional phone/email fields to password records, unify add/edit/detail field presentation, and support user-managed custom categories in settings, selectors, and main-page filtering.

**Architecture:** Extend the existing password record model and SQLite schema in place, then add a lightweight custom-category persistence path alongside the built-in category enum. UI work stays inside the current SwiftUI MVVM structure, with shared validation and category-source helpers feeding add/edit/detail/settings/sidebar flows.

**Tech Stack:** Swift, SwiftUI, SQLite.swift, XCTest/Xcodebuild, existing i18n service

---

## File map

### Existing files likely to modify
- `Sources/Models/PasswordItem.swift` - add phone/email fields to encrypted and decrypted item models and widen search-index generation.
- `Sources/Services/Storage/DatabaseManager.swift` - add schema migration for new password columns, add custom category table, expand CRUD and search queries.
- `Sources/Services/Storage/PasswordRepository.swift` - widen read/write APIs for phone/email and add custom-category CRUD methods.
- `Sources/ViewModels/AddEditPasswordViewModel.swift` - track phone/email field state, validation, and merged category options.
- `Sources/ViewModels/PasswordListViewModel.swift` - expose merged categories for sidebar filters and preserve custom categories across language changes.
- `Sources/ViewModels/SettingsViewModel.swift` - load and mutate custom categories, surface delete-in-use errors.
- `Sources/Views/Components/AddEditPasswordView.swift` - insert phone/email rows and unify required/optional labels.
- `Sources/Views/Components/PasswordDetailView.swift` - show/edit phone/email in the approved field order.
- `Sources/Views/Components/SidebarView.swift` - include custom categories in the quick filter list.
- `Sources/Views/Components/SettingsView.swift` - add custom-category management UI.
- `Resources/en.lproj/Localizable.strings` - add English copy for labels, placeholders, validation, and category management.
- `Resources/zh-Hans.lproj/Localizable.strings` - add Simplified Chinese copy for labels, placeholders, validation, and category management.
- `SourcesTests/PassKeeperTests.swift` - extend model/search-index coverage.
- `SourcesTests/PasswordUpdateTests.swift` - extend update helper coverage for new fields.

### New files to add
- `Sources/Models/CustomCategory.swift` - user-defined category model and storage-layer errors.
- `Sources/Services/Validation/AccountFieldValidator.swift` - shared loose phone/email validation helpers.
- `SourcesTests/AccountFieldValidatorTests.swift` - validator coverage.
- `SourcesTests/CustomCategoryStoreTests.swift` - repository/database coverage for custom categories.

---

### Task 1: Create the isolated implementation branch and baseline the workspace

**Files:**
- Create/Modify: git branch/worktree only

- [ ] **Step 1: Verify the feature branch worktree is active**

Run:
```bash
pwd
git branch --show-current
git status --short
```

Expected:
- The working directory is `.worktrees/feature-account-fields-custom-categories`.
- The current branch is `feature/account-fields-custom-categories`.
- The worktree is clean before code changes.

- [ ] **Step 2: Confirm the approved design doc is available inside the worktree**

Run:
```bash
sed -n '1,240p' docs/superpowers/specs/2026-04-08-account-fields-and-custom-categories-design.md
```

Expected:
- The spec includes phone/email support, custom categories, search participation, and delete-in-use restriction.

- [ ] **Step 3: Record the existing test targets and baseline build command**

Run:
```bash
xcodebuild -list -project PasswordManager.xcodeproj
```

Expected:
- The project exposes the `PasswordManager` scheme and the `PasswordManagerTests` target.

### Task 2: Extend the password item models and search-index tests for phone/email

**Files:**
- Modify: `Sources/Models/PasswordItem.swift`
- Modify: `SourcesTests/PassKeeperTests.swift`
- Modify: `SourcesTests/PasswordUpdateTests.swift`

- [ ] **Step 1: Add failing model tests for phone/email fields and search index expansion**

```swift
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

func testUpdatedItemReflectsNewPhoneAndEmail() {
    let original = makeItem(phoneNumber: "", email: "")
    let updated = makeUpdatedItem(from: original, phoneNumber: "+86 13800138000", email: "new@example.com")
    XCTAssertEqual(updated.phoneNumber, "+86 13800138000")
    XCTAssertEqual(updated.email, "new@example.com")
}
```

- [ ] **Step 2: Run the focused model tests to verify they fail**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/PasswordItemTests -only-testing:PasswordManagerTests/PasswordUpdateTests
```

Expected:
- Tests fail because `PasswordItem`, `DecryptedPasswordItem`, and helper methods do not yet include phone/email fields.

- [ ] **Step 3: Implement the minimal model changes**

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
        let values = [title, username, phoneNumber, email]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        return values + [values.joined(separator: " ")]
    }
}

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

- [ ] **Step 4: Run the focused model tests to verify they pass**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/PasswordItemTests -only-testing:PasswordManagerTests/PasswordUpdateTests
```

Expected:
- Both test classes pass.

- [ ] **Step 5: Commit the model changes**

```bash
git add Sources/Models/PasswordItem.swift SourcesTests/PassKeeperTests.swift SourcesTests/PasswordUpdateTests.swift
git commit -m "feat: add phone and email fields to password items"
```

### Task 3: Add database migration and repository support for phone/email fields

**Files:**
- Modify: `Sources/Services/Storage/DatabaseManager.swift`
- Modify: `Sources/Services/Storage/PasswordRepository.swift`

- [ ] **Step 1: Add a failing repository/database test for phone/email persistence and search**

```swift
func testRepositoryCanPersistAndSearchPhoneAndEmail() async throws {
    let repository = PasswordRepository()

    let created = try await repository.addItem(
        title: "GitHub",
        username: "octocat",
        password: "Secret123!",
        category: "General",
        phoneNumber: "+1 415 555 0101",
        email: "octo@example.com",
        notes: "work"
    )

    XCTAssertEqual(created.phoneNumber, "+1 415 555 0101")
    XCTAssertEqual(created.email, "octo@example.com")

    let fetched = try await repository.fetchItem(id: created.id)
    XCTAssertEqual(fetched?.phoneNumber, "+1 415 555 0101")
    XCTAssertEqual(fetched?.email, "octo@example.com")

    let phoneMatches = try await repository.searchItems(query: "415 555")
    XCTAssertTrue(phoneMatches.contains(where: { $0.id == created.id }))

    let emailMatches = try await repository.searchItems(query: "octo@example.com")
    XCTAssertTrue(emailMatches.contains(where: { $0.id == created.id }))
}
```

- [ ] **Step 2: Run the repository persistence test to verify it fails**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/PassKeeperTests/testRepositoryCanPersistAndSearchPhoneAndEmail
```

Expected:
- The test fails because repository methods and database schema do not yet accept or return phone/email fields.

- [ ] **Step 3: Implement the schema migration and repository wiring**

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
func addItem(
    title: String,
    username: String,
    password: String,
    category: String,
    phoneNumber: String,
    email: String,
    notes: String
) async throws -> DecryptedPasswordItem
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

- [ ] **Step 4: Run the repository persistence test to verify it passes**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/PassKeeperTests/testRepositoryCanPersistAndSearchPhoneAndEmail
```

Expected:
- The targeted test passes.

- [ ] **Step 5: Commit the storage/repository changes**

```bash
git add Sources/Services/Storage/DatabaseManager.swift Sources/Services/Storage/PasswordRepository.swift
git commit -m "feat: persist and search phone and email fields"
```

### Task 4: Add shared account-field validation and update add/edit form behavior

**Files:**
- Create: `Sources/Services/Validation/AccountFieldValidator.swift`
- Create: `SourcesTests/AccountFieldValidatorTests.swift`
- Modify: `Sources/ViewModels/AddEditPasswordViewModel.swift`
- Modify: `Sources/Views/Components/AddEditPasswordView.swift`
- Modify: `Resources/en.lproj/Localizable.strings`
- Modify: `Resources/zh-Hans.lproj/Localizable.strings`

- [ ] **Step 1: Add failing validator tests for optional email and loose phone rules**

```swift
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
```

- [ ] **Step 2: Run the validator tests to verify they fail**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/AccountFieldValidatorTests
```

Expected:
- The test target fails because the validator type does not yet exist.

- [ ] **Step 3: Implement validator helpers and add/edit wiring**

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
        let cleaned = trimmed.replacingOccurrences(of: #"[\s\-\(\)]"#, with: "", options: .regularExpression)
        let allowed = CharacterSet(charactersIn: "+0123456789")
        return cleaned.count >= 6 && cleaned.count <= 20 && cleaned.unicodeScalars.allSatisfy(allowed.contains)
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
    PKFieldContainer {
        TextField(text: $viewModel.phoneNumber, prompt: Text("addEdit.placeholder.phone".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
            .textFieldStyle(.plain)
            .font(.system(size: 14, weight: .medium))
    }
}

fieldSection(title: "detail.email".localized, optional: true) {
    PKFieldContainer {
        TextField(text: $viewModel.email, prompt: Text("addEdit.placeholder.email".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
            .textFieldStyle(.plain)
            .font(.system(size: 14, weight: .medium))
    }
}
```

- [ ] **Step 4: Run the validator tests to verify they pass**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/AccountFieldValidatorTests
```

Expected:
- `AccountFieldValidatorTests` passes.

- [ ] **Step 5: Commit the validator and add/edit updates**

```bash
git add Sources/Services/Validation/AccountFieldValidator.swift SourcesTests/AccountFieldValidatorTests.swift Sources/ViewModels/AddEditPasswordViewModel.swift Sources/Views/Components/AddEditPasswordView.swift Resources/en.lproj/Localizable.strings Resources/zh-Hans.lproj/Localizable.strings
git commit -m "feat: validate phone and email input fields"
```

### Task 5: Update the detail screen and list-update flow for phone/email fields

**Files:**
- Modify: `Sources/Views/Components/PasswordDetailView.swift`
- Modify: `Sources/ViewModels/PasswordListViewModel.swift`
- Modify: `SourcesTests/PasswordUpdateTests.swift`

- [ ] **Step 1: Add a failing update-flow test for phone/email round-trip**

```swift
func testUpdatePasswordPassesPhoneAndEmailToRepositoryPayload() async throws {
    let item = makeItem(phoneNumber: "+1 415 555 0101", email: "old@example.com")
    let updated = makeUpdatedItem(from: item, phoneNumber: "+1 415 555 0202", email: "new@example.com")

    XCTAssertEqual(updated.phoneNumber, "+1 415 555 0202")
    XCTAssertEqual(updated.email, "new@example.com")
}
```

- [ ] **Step 2: Run the focused update-flow tests to verify they fail**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/PasswordUpdateTests
```

Expected:
- The tests fail because detail-save/update flows do not yet carry phone/email data.

- [ ] **Step 3: Implement the detail-screen and list-update changes**

```swift
@State private var editedPhoneNumber: String = ""
@State private var editedEmail: String = ""

if isEditing || !item.phoneNumber.isEmpty {
    detailFieldSection(title: "detail.phone".localized) {
        if isEditing {
            editableTextField(text: $editedPhoneNumber, placeholder: "detail.phone".localized)
        } else {
            PKFieldContainer { Text(item.phoneNumber) }
        }
    }
}

if isEditing || !item.email.isEmpty {
    detailFieldSection(title: "detail.email".localized) {
        if isEditing {
            editableTextField(text: $editedEmail, placeholder: "detail.email".localized)
        } else {
            PKFieldContainer { Text(item.email) }
        }
    }
}
```

```swift
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
```

- [ ] **Step 4: Run the focused update-flow tests to verify they pass**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/PasswordUpdateTests
```

Expected:
- `PasswordUpdateTests` passes with the new phone/email assertions.

- [ ] **Step 5: Commit the detail/update changes**

```bash
git add Sources/Views/Components/PasswordDetailView.swift Sources/ViewModels/PasswordListViewModel.swift SourcesTests/PasswordUpdateTests.swift
git commit -m "feat: show phone and email in password detail"
```

### Task 6: Add custom-category persistence and deletion guardrails

**Files:**
- Create: `Sources/Models/CustomCategory.swift`
- Create: `SourcesTests/CustomCategoryStoreTests.swift`
- Modify: `Sources/Services/Storage/DatabaseManager.swift`
- Modify: `Sources/Services/Storage/PasswordRepository.swift`
- Modify: `Sources/ViewModels/SettingsViewModel.swift`

- [ ] **Step 1: Add failing tests for custom-category CRUD and delete-in-use rejection**

```swift
func testCustomCategoryCRUDAndDeleteInUseProtection() async throws {
    let repository = PasswordRepository()

    let created = try repository.createCustomCategory(name: "Travel")
    XCTAssertEqual(created.name, "Travel")

    let renamed = try repository.updateCustomCategory(id: created.id, name: "Trips")
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

    XCTAssertThrowsError(try repository.deleteCustomCategory(id: created.id)) { error in
        XCTAssertEqual(error as? CategoryStoreError, .categoryInUse)
    }
}
```

- [ ] **Step 2: Run the custom-category tests to verify they fail**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/CustomCategoryStoreTests
```

Expected:
- The tests fail because custom category storage and guardrail APIs do not exist yet.

- [ ] **Step 3: Implement custom-category storage and repository APIs**

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

- [ ] **Step 4: Run the custom-category tests to verify they pass**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/CustomCategoryStoreTests
```

Expected:
- `CustomCategoryStoreTests` passes, including delete-in-use rejection.

- [ ] **Step 5: Commit the custom-category storage changes**

```bash
git add Sources/Models/CustomCategory.swift SourcesTests/CustomCategoryStoreTests.swift Sources/Services/Storage/DatabaseManager.swift Sources/Services/Storage/PasswordRepository.swift Sources/ViewModels/SettingsViewModel.swift
git commit -m "feat: add custom category storage and safeguards"
```

### Task 7: Wire custom categories into add/edit selectors, sidebar filters, settings UI, and localization

**Files:**
- Modify: `Sources/ViewModels/AddEditPasswordViewModel.swift`
- Modify: `Sources/ViewModels/PasswordListViewModel.swift`
- Modify: `Sources/ViewModels/SettingsViewModel.swift`
- Modify: `Sources/Views/Components/AddEditPasswordView.swift`
- Modify: `Sources/Views/Components/SidebarView.swift`
- Modify: `Sources/Views/Components/SettingsView.swift`
- Modify: `Resources/en.lproj/Localizable.strings`
- Modify: `Resources/zh-Hans.lproj/Localizable.strings`

- [ ] **Step 1: Add failing tests for merged category visibility in forms and sidebar filters**

```swift
func testCustomCategoriesAppearInAddEditAndSidebarLists() async throws {
    let settingsViewModel = SettingsViewModel()
    try settingsViewModel.addCustomCategory(name: "Travel")

    let addEditViewModel = AddEditPasswordViewModel()
    await addEditViewModel.reloadCategories()
    XCTAssertTrue(addEditViewModel.categories.contains("Travel"))

    let listViewModel = PasswordListViewModel()
    await listViewModel.reloadCategories()
    XCTAssertTrue(listViewModel.categories.contains("Travel"))
}
```

- [ ] **Step 2: Run the merged-category tests to verify they fail**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/CustomCategoryStoreTests -only-testing:PasswordManagerTests/PasswordUpdateTests
```

Expected:
- The tests fail because view models and UI still expose only built-in categories.

- [ ] **Step 3: Implement merged category sourcing and settings management UI**

```swift
@Published var categories: [String] = []

func reloadCategories() async {
    let builtIn = PasswordCategory.allCases.map(\.localizedName)
    let custom = (try? repository.fetchCustomCategories())?.map(\.name) ?? []
    categories = builtIn + custom
}
```

```swift
@Published var customCategories: [CustomCategory] = []
@Published var customCategoryError: String?

func loadCustomCategories() {
    customCategories = (try? repository.fetchCustomCategories()) ?? []
}
```

```swift
settingsSection(title: "settings.categories".localized) {
    settingsReadOnlyRow(
        title: "settings.categories.system".localized,
        value: PasswordCategory.allCases.map(\.localizedName).joined(separator: ", ")
    )

    CustomCategoryManagementSection(viewModel: viewModel)
}
```

- [ ] **Step 4: Run the merged-category tests to verify they pass**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/CustomCategoryStoreTests -only-testing:PasswordManagerTests/PasswordUpdateTests
```

Expected:
- The merged-category tests pass and the UI data sources include custom categories.

- [ ] **Step 5: Commit the selector/filter/settings UI changes**

```bash
git add Sources/ViewModels/AddEditPasswordViewModel.swift Sources/ViewModels/PasswordListViewModel.swift Sources/ViewModels/SettingsViewModel.swift Sources/Views/Components/AddEditPasswordView.swift Sources/Views/Components/SidebarView.swift Sources/Views/Components/SettingsView.swift Resources/en.lproj/Localizable.strings Resources/zh-Hans.lproj/Localizable.strings
git commit -m "feat: wire custom categories into forms settings and filters"
```

### Task 8: Run verification for all changed areas and prepare the branch for review

**Files:**
- Modify: any files needed to fix verification failures

- [ ] **Step 1: Run the focused test classes for this feature**

Run:
```bash
xcodebuild test -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -only-testing:PasswordManagerTests/PasswordItemTests -only-testing:PasswordManagerTests/PasswordUpdateTests -only-testing:PasswordManagerTests/AccountFieldValidatorTests -only-testing:PasswordManagerTests/CustomCategoryStoreTests
```

Expected:
- All focused feature tests pass.

- [ ] **Step 2: Run a full macOS build for integration verification**

Run:
```bash
TMPDIR=/tmp xcodebuild -scheme PasswordManager -project PasswordManager.xcodeproj -destination 'platform=macOS' -clonedSourcePackagesDirPath /tmp/spm-cache -derivedDataPath /tmp/DerivedData build
```

Expected:
- The app builds successfully with no new compile errors.

- [ ] **Step 3: Inspect the branch state and recent commits**

Run:
```bash
git status --short
git log --oneline --decorate -6
```

Expected:
- Only intentional feature files are modified.
- The recent commit history shows the incremental feature slices from Tasks 2-7.

- [ ] **Step 4: Commit any last verification fixes**

```bash
git add Sources SourcesTests Resources docs/superpowers/plans
git commit -m "test: finalize account fields and custom categories verification"
```

- [ ] **Step 5: Prepare the review summary**

Include in handoff:
```text
- Branch: feature/account-fields-custom-categories
- Worktree: .worktrees/feature-account-fields-custom-categories
- Verified via focused xcodebuild tests and a full macOS build
- Key areas: password storage migration, phone/email validation, detail/add-edit UI, custom category settings and filters
```
