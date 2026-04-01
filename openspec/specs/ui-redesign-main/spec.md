## ADDED Requirements

### Requirement: Sidebar has search input
The system SHALL display a search input at the top of the sidebar with a search icon and placeholder "搜索".

#### Scenario: Search input display
- **WHEN** the main view is shown
- **THEN** a search input with search icon inside is displayed at the top of the sidebar, using rounded-lg corners, muted background, and full width

### Requirement: Sidebar displays password list
The system SHALL display a scrollable list of passwords in the sidebar, each item showing the title and username.

#### Scenario: Password list rendering
- **WHEN** passwords exist in the vault
- **THEN** each password is displayed as a clickable item in the sidebar with title in primary text and username in muted text, using rounded-lg styling

### Requirement: Sidebar password item selection state
The system SHALL highlight the currently selected password item with a primary/15 background and primary/40 border.

#### Scenario: Password item selection
- **WHEN** user clicks on a password item
- **THEN** the selected item shows highlighted background (primary/15) and border (primary/40), while unselected items show hover state (accent background)

### Requirement: Sidebar has category section
The system SHALL display a category section at the bottom of the sidebar with a header "分类" and list of all available categories.

#### Scenario: Category section display
- **WHEN** the main view is shown
- **THEN** a category section is displayed with "分类" header in uppercase, followed by category items (全部, 通用, 社交, 工作, 金融, 购物, 娱乐, 其他) with icons

### Requirement: Category selection filters password list
The system SHALL filter the displayed passwords based on the selected category.

#### Scenario: Category filtering
- **WHEN** user selects a category
- **THEN** only passwords matching the selected category are displayed in the password list (except "全部" which shows all)

### Requirement: Sidebar has settings button
The system SHALL display a settings button at the bottom of the sidebar with settings icon and label "设置".

#### Scenario: Settings button
- **WHEN** the main view is shown
- **THEN** a settings button is displayed at the bottom of the sidebar with icon and text

### Requirement: Main toolbar has action buttons
The system SHALL display a toolbar at the top of the main content area with add, settings, and lock buttons.

#### Scenario: Toolbar buttons
- **WHEN** the main view is shown
- **THEN** three buttons are displayed: Plus icon (add new password), Settings icon, and Lock icon for locking

### Requirement: Theme toggle in toolbar
The system SHALL display a theme toggle button in the top-right of the toolbar.

#### Scenario: Theme toggle
- **WHEN** the main view is shown
- **THEN** a theme toggle button shows sun/moon icon and toggles between light/dark modes

### Requirement: Empty state when no password selected
The system SHALL display an empty state when no password is selected, showing a key icon, "未选择密码" title, and "从侧边栏选择一个密码或创建新密码" subtitle with an "添加新密码" button.

#### Scenario: Empty state display
- **WHEN** no password is selected
- **THEN** a centered empty state is shown with icon, message text, and action button