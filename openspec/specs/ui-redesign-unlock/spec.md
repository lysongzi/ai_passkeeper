## ADDED Requirements

### Requirement: Unlock screen displays gradient lock icon
The system SHALL display a centered gradient lock icon (from primary color to orange-600) with rounded corners (12, 96px width/height) on the unlock screen.

#### Scenario: Gradient icon rendering
- **WHEN** the app launches or requires unlock
- **THEN** a 96x96px gradient icon with rounded-3xl corners (approximately 24px radius) is displayed at the top center of the unlock area

### Requirement: Unlock screen shows app title and subtitle
The system SHALL display "密码管家" as the main title and "输入主密码以解锁" as the subtitle below the gradient icon.

#### Scenario: Title and subtitle display
- **WHEN** the unlock screen is shown
- **THEN** "密码管家" is displayed in large text (text-3xl) and "输入主密码以解锁" is displayed below in muted foreground color

### Requirement: Unlock screen has password input field
The system SHALL display a full-width password input field with the placeholder "主密码".

#### Scenario: Password input field
- **WHEN** the unlock screen is shown
- **THEN** a password input field is displayed with placeholder "主密码", using rounded-2xl corners (approximately 16px), 2px border with primary/30 color, and 48px height (py-4)

### Requirement: Unlock screen has unlock button
The system SHALL display a full-width button labeled "解锁" below the password input.

#### Scenario: Unlock button
- **WHEN** the unlock screen is shown
- **THEN** a full-width button with text "解锁" is displayed, using primary background color, rounded-2xl corners, and white text

### Requirement: Theme toggle button exists on unlock screen
The system SHALL display a theme toggle button in the top-right corner that switches between light and dark modes.

#### Scenario: Theme toggle on unlock screen
- **WHEN** the unlock screen is displayed
- **THEN** a fixed position button in top-right corner shows sun icon (light mode) or moon icon (dark mode) and toggles theme when clicked

### Requirement: Unlock form submission
The system SHALL validate and submit the master password when user presses Enter or clicks the unlock button.

#### Scenario: Form submission
- **WHEN** user presses Enter or clicks unlock button with non-empty password
- **THEN** the app attempts to unlock with the provided master password