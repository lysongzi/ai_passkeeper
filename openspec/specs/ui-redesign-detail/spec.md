## ADDED Requirements

### Requirement: Detail view displays password header
The system SHALL display a header section with a gradient icon (64px, rounded-2xl), password title, and category name.

#### Scenario: Header display
- **WHEN** a password is selected
- **THEN** a header is shown with gradient icon (from primary to orange-600), title in large text, and category name below in muted color

### Requirement: Detail view displays username field
The system SHALL display a username field with label "用户名" and the username value, with a copy button.

#### Scenario: Username display
- **WHEN** a password is selected
- **THEN** a username field is displayed with the username value and a copy button (doc.on.doc icon)

### Requirement: Detail view displays password field with visibility toggle
The system SHALL display a password field with label "密码", the password value (or dots when hidden), and two buttons: visibility toggle and copy.

#### Scenario: Password display
- **WHEN** a password is selected
- **THEN** a password field shows masked password (dots) by default, with eye/eye-off toggle button and copy button, using monospace font

### Requirement: Password field shows copy confirmation
The system SHALL display a confirmation message "密码已复制！将在 10 秒后清除。" after copying the password.

#### Scenario: Copy confirmation
- **WHEN** user clicks copy button on password
- **THEN** a message is displayed below the password field confirming the copy with 10-second auto-clear

### Requirement: Detail view displays notes section
The system SHALL display a notes section with label "备注" if notes exist for the password.

#### Scenario: Notes display
- **WHEN** a password with notes is selected
- **THEN** a notes section is displayed showing the notes content in a styled container

### Requirement: Detail view displays metadata section
The system SHALL display a metadata section with label "详情" showing creation date and last modified date.

#### Scenario: Metadata display
- **WHEN** a password is selected
- **THEN** a details section shows "创建时间" and "最后修改" dates

### Requirement: Detail view has delete button
The system SHALL display a delete button with trash icon and label "删除密码" in destructive styling.

#### Scenario: Delete button
- **WHEN** a password is selected
- **THEN** a delete button is displayed at the bottom with destructive color (red) styling

### Requirement: Detail view has edit mode
The system SHALL allow editing of password title, username, password, category, and notes.

#### Scenario: Edit mode activation
- **WHEN** user clicks the edit button
- **THEN** all fields become editable text fields with save and cancel buttons

### Requirement: Detail view displays copy confirmation for username
The system SHALL display a confirmation message after copying username to clipboard.

#### Scenario: Username copy confirmation
- **WHEN** user clicks copy button on username
- **THEN** a brief confirmation message is displayed