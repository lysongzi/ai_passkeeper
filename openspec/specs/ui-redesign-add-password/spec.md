## ADDED Requirements

### Requirement: Add password modal overlay
The system SHALL display the add password form as a modal overlay with a semi-transparent black background (bg-black/50).

#### Scenario: Modal overlay display
- **WHEN** user clicks add password button
- **THEN** a modal overlay covers the entire window with semi-transparent background

### Requirement: Add password modal container
The system SHALL display the add password form in a modal container with rounded-2xl corners, shadow, and max-width of 2xl (approximately 672px).

#### Scenario: Modal container
- **WHEN** add password modal is shown
- **THEN** a centered modal container is displayed with rounded corners, shadow, and appropriate max-width

### Requirement: Add password modal header
The system SHALL display a modal header with cancel button (left), title "添加新密码" (center), and save button (right).

#### Scenario: Modal header
- **WHEN** add password modal is shown
- **THEN** a header row shows cancel button, title, and save button with appropriate styling

### Requirement: Add password form fields
The system SHALL display form fields for title, username/email, password, and category with labels in a vertical layout.

#### Scenario: Form fields display
- **WHEN** add password modal is shown
- **THEN** form fields are displayed with labels (标题, 用户名 / 邮箱, 密码, 分类) and corresponding input fields in a vertical stack

### Requirement: Form field styling
The system SHALL use consistent styling for form fields: rounded-xl corners, 48px height (py-3), and focus states with primary ring.

#### Scenario: Form field styling
- **WHEN** form fields are rendered
- **THEN** each field uses rounded-xl corners, proper padding, and focus states with primary color ring

### Requirement: Password field has visibility toggle
The system SHALL include an eye icon button next to the password field to toggle password visibility.

#### Scenario: Password visibility toggle
- **WHEN** user needs to see the password being entered
- **THEN** an eye/eye-off button is displayed next to the password field to toggle visibility

### Requirement: Category dropdown
The system SHALL display a category dropdown (select) populated with all categories except "全部".

#### Scenario: Category selection
- **WHEN** user needs to select a category
- **THEN** a dropdown shows all available categories with their icons

### Requirement: Save button validation
The system SHALL validate that title, username, and password fields are not empty before enabling save.

#### Scenario: Save validation
- **WHEN** user clicks save with empty required fields
- **THEN** the save operation is prevented or shows validation error

### Requirement: Cancel closes modal
The system SHALL close the add password modal when user clicks cancel button.

#### Scenario: Modal close
- **WHEN** user clicks cancel button
- **THEN** the modal is closed and form is reset