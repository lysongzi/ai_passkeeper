## ADDED Requirements

### Requirement: User can edit password details from detail view
The system SHALL allow users to directly edit all fields (title, username, password, notes, category) of an existing password entry from the detail view.

#### Scenario: Edit title
- **WHEN** user taps the edit button in detail view and modifies the title field
- **THEN** system validates the title is not empty and saves the updated password item

#### Scenario: Edit username
- **WHEN** user taps the edit button in detail view and modifies the username field
- **THEN** system saves the updated password item with new username

#### Scenario: Edit password
- **WHEN** user taps the edit button in detail view and modifies the password field
- **THEN** system saves the updated password item with new password (encrypted)

#### Scenario: Toggle password visibility
- **WHEN** user taps the eye icon while editing password
- **THEN** system toggles between showing plain text and masked password

#### Scenario: Edit notes
- **WHEN** user taps the edit button in detail view and modifies the notes field
- **THEN** system saves the updated password item with new notes

#### Scenario: Edit category
- **WHEN** user taps the edit button in detail view and selects a different category
- **THEN** system saves the updated password item with new category

#### Scenario: Cancel editing
- **WHEN** user taps cancel button while editing
- **THEN** system discards all changes and returns to view mode

#### Scenario: Save after editing
- **WHEN** user taps save button after making changes
- **THEN** system validates input, saves to database, and updates the UI

### Requirement: Category picker width matches input fields
The system SHALL display the category picker in the add/edit password form with width consistent with other input fields.

#### Scenario: Category picker displays correctly
- **WHEN** user opens add password view
- **THEN** category picker width matches the width of title, username, and password fields above it

### Requirement: Edit button displays correctly with localization
The system SHALL display the edit button with proper localized text.

#### Scenario: Edit button shows localized text
- **WHEN** user views the detail page
- **THEN** edit button text is displayed in the current language (e.g., "Edit" in English, "编辑" in Chinese)

### Requirement: Password display width fills container
The system SHALL display the password value with full width to match username field.

#### Scenario: Password field fills width
- **WHEN** user views password in detail view (both edit and view mode)
- **THEN** password value area fills the available width

### Requirement: Category displays in view mode
The system SHALL display the category information even when not in edit mode.

#### Scenario: Category visible in view mode
- **WHEN** user views password details without editing
- **THEN** category information is displayed

### Requirement: Edit mode input areas have proper spacing
The system SHALL provide adequate vertical padding in edit mode input areas.

#### Scenario: Input fields have proper padding
- **WHEN** user enters edit mode
- **THEN** input fields have appropriate vertical padding for comfortable editing

### Requirement: Delete button hidden in edit mode
The system SHALL hide the delete button when user is in edit mode to prevent accidental deletion.

#### Scenario: Delete button visibility
- **WHEN** user enters edit mode
- **THEN** delete button is hidden
- **WHEN** user cancels editing
- **THEN** delete button becomes visible again

### Requirement: Edit mode UI aligns with view mode
The system SHALL maintain visual consistency between edit and view modes.

#### Scenario: UI consistency
- **WHEN** user switches between edit and view modes
- **THEN** the layout structure remains consistent, only input controls replace display text