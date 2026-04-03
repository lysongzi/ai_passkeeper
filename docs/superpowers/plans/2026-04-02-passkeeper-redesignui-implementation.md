# PassKeeper RedesignUI High-Fidelity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the SwiftUI UI layer so the macOS app matches the RedesignUI prototype as closely as possible while preserving existing ViewModel and service logic.

**Architecture:** Introduce a reusable UI design-system layer first (tokens, modal container, form rows, icon buttons, field containers), then recompose screen-level views on top of those primitives. Replace the settings reset-password `.sheet` flow with an in-modal route state so modal behavior matches the prototype.

**Tech Stack:** SwiftUI, existing MVVM view models, AppKit where already used, XcodeGen/Xcode build, local prototype screenshots in `prototype-screenshots/`

---

## File Structure

### Existing files to modify
- `Sources/Views/Components/Theme.swift` — normalize color, radius, spacing, control sizing, shadows to prototype-driven tokens
- `Sources/Views/Components/UIComponents.swift` — shared buttons, field containers, icon buttons, section labels
- `Sources/Views/Components/WindowComponents.swift` — window chrome and shell-level helpers
- `Sources/Views/Components/UnlockView.swift` — rebuild unlock/setup screen around shared primitives
- `Sources/Views/Components/SidebarView.swift` — sidebar search, password rows, category rows, settings row
- `Sources/Views/Components/MainContentView.swift` — toolbar, empty state, shell composition
- `Sources/Views/Components/PasswordDetailView.swift` — detail screen rebuilt on shared field/panel primitives
- `Sources/Views/Components/AddEditPasswordView.swift` — migrate to shared modal container and shared form rows
- `Sources/Views/Components/SettingsView.swift` — rebuild settings and replace `.sheet` route with in-modal content switching

### New files to create
- `Sources/Views/Components/ModalComponents.swift` — reusable dimmed overlay modal container/header/footer slots
- `Sources/Views/Components/FormComponents.swift` — right-label form rows, metadata panel, detail row containers
- `Sources/Views/Components/ToolbarComponents.swift` — toolbar button group and top action bar helpers
- `Sources/Views/Components/SidebarComponents.swift` — extracted sidebar-specific composables if `SidebarView.swift` remains too large

### Tests / verification targets
- `xcodebuild test -scheme PassKeeper -destination 'platform=macOS'`
- `xcodebuild test -scheme Resources -destination 'platform=macOS'` (if existing scheme is available in project)
- `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`

---

### Task 1: Establish prototype-driven design tokens

**Files:**
- Modify: `Sources/Views/Components/Theme.swift`
- Test: `Sources/Views/Components/UnlockView.swift`

- [ ] **Step 1: Write the failing visual checklist in the plan workspace**

```text
Target token mismatches to fix:
- Unlock page background is too generic if it does not match prototype warm dark tone.
- Primary button, field radius, sidebar accent, border opacity, and modal shadow must match screenshot families.
- Light mode and dark mode need explicit values rather than inferred defaults.
```

- [ ] **Step 2: Run a build before editing to capture the baseline**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: Build succeeds or reports the current unrelated baseline issues before UI token changes.

- [ ] **Step 3: Update `Theme.swift` with explicit prototype-aligned tokens**

```swift
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

struct AppElevation {
    static let modalShadow = Color.black.opacity(0.22)
    static let buttonShadow = Color.black.opacity(0.14)
}
```

Also ensure existing color tokens have explicit dark/light values matching the screenshots for:
- background
- card / popover
- sidebar
- sidebar accent
- field fill
- border
- primary
- destructive
- muted foreground

- [ ] **Step 4: Run build after token changes**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add Sources/Views/Components/Theme.swift
git commit -m "feat: align UI tokens with redesign prototype"
```

### Task 2: Build reusable modal and form primitives

**Files:**
- Create: `Sources/Views/Components/ModalComponents.swift`
- Create: `Sources/Views/Components/FormComponents.swift`
- Modify: `Sources/Views/Components/UIComponents.swift`
- Test: `Sources/Views/Components/AddEditPasswordView.swift`

- [ ] **Step 1: Write the failing visual contract**

```text
Needed reusable UI pieces:
- dimmed overlay modal container
- modal header with leading/trailing actions and centered title
- right-label form row
- static detail field container
- metadata panel
```

- [ ] **Step 2: Run build to confirm new files are required and baseline is stable**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Add the modal primitive in `ModalComponents.swift`**

```swift
import SwiftUI

struct PKModalContainer<Content: View>: View {
    let width: CGFloat
    let height: CGFloat?
    let onBackgroundTap: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture(perform: onBackgroundTap)

            VStack(spacing: 0) {
                content
            }
            .frame(width: width, height: height)
            .background(AppColors.popover)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: AppElevation.modalShadow, radius: 20, x: 0, y: 8)
        }
    }
}
```

- [ ] **Step 4: Add the form primitives in `FormComponents.swift`**

```swift
import SwiftUI

struct PKFormRowRightLabel<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.foreground)
                .frame(width: 120, alignment: .trailing)

            content
        }
    }
}
```

Also add a shared field/panel wrapper for static detail sections.

- [ ] **Step 5: Wire exports/helpers from `UIComponents.swift` if shared buttons or field wrappers belong there**

```swift
struct PKIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: 36, height: 36)
                .background(AppColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 6: Run build after creating primitives**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 7: Commit**

```bash
git add Sources/Views/Components/ModalComponents.swift Sources/Views/Components/FormComponents.swift Sources/Views/Components/UIComponents.swift
git commit -m "feat: add reusable modal and form primitives"
```

### Task 3: Rebuild unlock/setup screens around shared primitives

**Files:**
- Modify: `Sources/Views/Components/UnlockView.swift`
- Test: `Sources/ViewModels/AuthenticationViewModel.swift`

- [ ] **Step 1: Write the failing visual contract**

```text
Unlock screen must preserve:
- centered single-column composition
- equal-width password field and CTA button
- large icon block above title
- no extra chrome beyond prototype window shell and theme toggle
```

- [ ] **Step 2: Run build to lock in baseline before edits**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Recompose unlock and setup views to use the shared spacing/tokens**

```swift
VStack(spacing: AppSpacing.xxl) {
    Spacer()
    unlockHero
    unlockForm
        .frame(maxWidth: 420)
    Spacer()
}
.background(AppColors.background)
```

Ensure the password field and CTA button share the same width and visual rhythm.

- [ ] **Step 4: Run build after unlock refactor**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add Sources/Views/Components/UnlockView.swift
git commit -m "feat: rebuild unlock screens to match redesign"
```

### Task 4: Rebuild shell layout: toolbar, sidebar, empty state

**Files:**
- Create: `Sources/Views/Components/ToolbarComponents.swift`
- Create: `Sources/Views/Components/SidebarComponents.swift`
- Modify: `Sources/Views/Components/SidebarView.swift`
- Modify: `Sources/Views/Components/MainContentView.swift`
- Modify: `Sources/Views/Components/WindowComponents.swift`
- Test: `Sources/ViewModels/PasswordListViewModel.swift`

- [ ] **Step 1: Write the failing shell contract**

```text
Shell must match prototype in three regions:
- minimal top toolbar with + / settings / lock and trailing theme toggle
- fixed-width sidebar with search, rows, categories, bottom settings entry
- main empty state centered in content panel
```

- [ ] **Step 2: Run build before shell changes**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Create toolbar helpers in `ToolbarComponents.swift`**

```swift
import SwiftUI

struct PKTopToolbar<Leading: View, Trailing: View>: View {
    @ViewBuilder let leading: Leading
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack {
            leading
            Spacer()
            trailing
        }
        .padding(12)
        .background(AppColors.card)
    }
}
```

- [ ] **Step 4: Create sidebar helpers in `SidebarComponents.swift` and refactor `SidebarView.swift` to use them**

```swift
struct PKSidebarSectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(AppColors.mutedForeground)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }
}
```

Keep row selection styling aligned to screenshot-selected state.

- [ ] **Step 5: Refactor `MainContentView.swift` and `WindowComponents.swift` to assemble the shell using new primitives**

```swift
PKTopToolbar {
    HStack(spacing: 12) {
        addButton
        PKIconButton(systemName: "gearshape", action: onSettings)
        PKIconButton(systemName: "lock", action: onLock)
    }
} trailing: {
    ThemeToggleButton()
}
```

- [ ] **Step 6: Run build after shell refactor**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 7: Commit**

```bash
git add Sources/Views/Components/ToolbarComponents.swift Sources/Views/Components/SidebarComponents.swift Sources/Views/Components/SidebarView.swift Sources/Views/Components/MainContentView.swift Sources/Views/Components/WindowComponents.swift
git commit -m "feat: rebuild vault shell to mirror redesign prototype"
```

### Task 5: Rebuild password detail screen on shared field primitives

**Files:**
- Modify: `Sources/Views/Components/PasswordDetailView.swift`
- Test: `Sources/ViewModels/PasswordListViewModel.swift`

- [ ] **Step 1: Write the failing detail-screen contract**

```text
Detail screen must keep:
- icon + title + category header
- static field containers for username/password/notes
- inline copy and reveal actions
- metadata panel and destructive delete action at bottom
```

- [ ] **Step 2: Run build before detail changes**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Refactor the detail screen to use shared field and metadata panel components**

```swift
VStack(alignment: .leading, spacing: 24) {
    detailHeader
    PKDetailFieldRow(label: "用户名") { usernameContent }
    PKDetailFieldRow(label: "密码") { passwordContent }
    notesSection
    metadataSection
    deleteButton
}
```

Ensure display mode and edit mode continue to function with the existing save/delete hooks.

- [ ] **Step 4: Run build after detail refactor**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add Sources/Views/Components/PasswordDetailView.swift
git commit -m "feat: align password detail screen with redesign prototype"
```

### Task 6: Rebuild add/edit password modal with shared modal and form rows

**Files:**
- Modify: `Sources/Views/Components/AddEditPasswordView.swift`
- Test: `Sources/ViewModels/AddEditPasswordViewModel.swift`

- [ ] **Step 1: Write the failing modal contract**

```text
Add/edit modal must preserve:
- dimmed overlay background
- left cancel / center title / right save header
- right-aligned labels
- shared field containers
- category row styled like prototype pseudo-select
```

- [ ] **Step 2: Run build before modal changes**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Refactor `AddEditPasswordView.swift` to wrap content in `PKModalContainer` and `PKFormRowRightLabel`**

```swift
PKModalContainer(width: 620, height: 640, onBackgroundTap: { dismiss() }) {
    modalHeader
    Divider()
    ScrollView { modalForm }
}
```

Ensure the form still binds to `AddEditPasswordViewModel` and save validation still controls the save button state.

- [ ] **Step 4: Run build after modal refactor**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit**

```bash
git add Sources/Views/Components/AddEditPasswordView.swift
git commit -m "feat: rebuild add edit modal to match redesign"
```

### Task 7: Replace settings `.sheet` with in-modal route switching

**Files:**
- Modify: `Sources/Views/Components/SettingsView.swift`
- Test: `Sources/ViewModels/SettingsViewModel.swift`

- [ ] **Step 1: Write the failing route contract**

```text
Settings flow requirement:
- no system `.sheet` for password reset
- settings and reset password share the same modal shell
- internal route switches between general settings and reset password form
```

- [ ] **Step 2: Run build before route changes**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Replace `showingResetSheet` with an in-modal route enum**

```swift
enum SettingsModalRoute {
    case general
    case resetPassword
}

@State private var route: SettingsModalRoute = .general
```

Render `generalSection` when `route == .general` and render reset-password content in the same modal container when `route == .resetPassword`.

- [ ] **Step 4: Keep reset behavior wired to the existing `SettingsViewModel` without introducing a second modal**

```swift
switch route {
case .general:
    settingsContent
case .resetPassword:
    resetPasswordContent
}
```

The reset form should keep current-password/new-password/confirm-password validation and action wiring.

- [ ] **Step 5: Run build after route refactor**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 6: Commit**

```bash
git add Sources/Views/Components/SettingsView.swift
git commit -m "feat: move reset password into settings modal flow"
```

### Task 8: Final verification against prototype screenshots and test/build suite

**Files:**
- Modify: none required unless fixes are found
- Test: `prototype-screenshots/*.png`, `xcodebuild`

- [ ] **Step 1: Perform the screenshot checklist against all six states in both themes**

```text
Check against:
- 01-lock-screen(.png / -light.png)
- 02-main-default(.png / -light.png)
- 03-detail-view(.png / -light.png)
- 04-add-password-modal(.png / -light.png)
- 05-settings-modal(.png / -light.png)
- 06-reset-password-flow(.png / -light.png)
```

- [ ] **Step 2: Run unit/integration tests**

Run: `xcodebuild test -scheme PassKeeper -destination 'platform=macOS'`
Expected: `** TEST SUCCEEDED **`

- [ ] **Step 3: Run the final build**

Run: `xcodebuild -scheme PassKeeper -destination 'platform=macOS' build`
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: If a `Resources` test scheme exists, run it as well**

Run: `xcodebuild test -scheme Resources -destination 'platform=macOS'`
Expected: `** TEST SUCCEEDED **` or a clear message that the scheme does not exist.

- [ ] **Step 5: Commit final verification fixes if needed**

```bash
git add Sources/Views/Components docs/superpowers/specs/2026-04-02-passkeeper-redesignui-design.md docs/superpowers/plans/2026-04-02-passkeeper-redesignui-implementation.md
git commit -m "docs: capture redesign implementation plan and verification"
```
