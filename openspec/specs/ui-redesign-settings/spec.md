## ADDED Requirements

### Requirement: Settings modal overlay
The system SHALL display the settings as a modal overlay with a semi-transparent black background.

#### Scenario: Settings modal overlay
- **WHEN** user clicks settings button
- **THEN** a modal overlay covers the window with semi-transparent background

### Requirement: Settings modal container
The system SHALL display the settings in a modal container with rounded-2xl corners and shadow.

#### Scenario: Settings modal container
- **WHEN** settings modal is shown
- **THEN** a centered modal container is displayed with appropriate styling

### Requirement: Settings modal header
The system SHALL display a header with title "设置" and a close (X) button.

#### Scenario: Settings header
- **WHEN** settings modal is shown
- **THEN** a header shows "设置" title and close button

### Requirement: Settings has general section
The system SHALL display a "通用" section with language and appearance options.

#### Scenario: General section display
- **WHEN** settings modal is shown
- **THEN** a "通用" section is displayed with language and appearance settings

### Requirement: Language setting
The system SHALL provide a language dropdown with options "简体中文" and "English".

#### Scenario: Language selection
- **WHEN** user needs to change language
- **THEN** a dropdown shows language options and allows selection

### Requirement: Appearance setting
The system SHALL provide an appearance dropdown with options "浅色" (light) and "深色" (dark).

#### Scenario: Appearance selection
- **WHEN** user needs to change appearance
- **THEN** a dropdown shows appearance options and switches theme when changed

### Requirement: Settings has security section
The system SHALL display a "安全" section with password reset option.

#### Scenario: Security section display
- **WHEN** settings modal is shown
- **THEN** a "安全" section is displayed with reset password button

### Requirement: Password reset functionality
The system SHALL display a password reset form with fields for current password, new password, and confirm password.

#### Scenario: Password reset form
- **WHEN** user clicks reset password button
- **THEN** a form is displayed with current password, new password, and confirm password fields

### Requirement: Password reset validation
The system SHALL validate that all password fields are filled and new passwords match.

#### Scenario: Reset validation
- **WHEN** user attempts to reset password with mismatched passwords
- **THEN** validation error is shown

### Requirement: Settings close button
The system SHALL close the settings modal when user clicks the close (X) button.

#### Scenario: Close settings
- **WHEN** user clicks close button
- **THEN** the settings modal is closed