## 1. Design System Setup

- [x] 1.1 Create Color extension with shadcn/ui color palette (background, foreground, primary, secondary, muted, accent, destructive, border, input, ring)
- [x] 1.2 Implement dark/light color scheme support using SwiftUI's Color Scheme
- [x] 1.3 Define corner radius constants (sm: 6px, md: 8px, lg: 10px, xl: 14px based on radius: 0.625rem)
- [x] 1.4 Define spacing and sizing constants (input height 44-48pt, icon sizes)

## 2. Common UI Components

- [x] 2.1 Create GradientIcon component with primary-to-orange-600 gradient
- [x] 2.2 Create StyledTextField component with rounded corners and border
- [x] 2.3 Create StyledSecureField component for password input
- [x] 2.4 Create FormField component with label and input
- [x] 2.5 Create CardContainer component for section backgrounds
- [x] 2.6 Create CopyButton component with feedback
- [x] 2.7 Create TogglePasswordButton component

## 3. Unlock Screen

- [x] 3.1 Create new UnlockView with gradient lock icon
- [x] 3.2 Implement unlock form with master password input
- [x] 3.3 Add unlock button with primary styling
- [x] 3.4 Add theme toggle button (top-right)
- [x] 3.5 Update MainView to show unlock screen when locked

## 4. Main View - Sidebar

- [x] 4.1 Redesign sidebar container with sidebar colors
- [x] 4.2 Implement search input with search icon
- [x] 4.3 Redesign password list items with selection state
- [x] 4.4 Redesign category section with icons
- [x] 4.5 Add settings button at sidebar bottom

## 5. Main View - Content Area

- [x] 5.1 Redesign toolbar with action buttons (add, settings, lock)
- [x] 5.2 Add theme toggle in toolbar
- [x] 5.3 Implement empty state with key icon and message
- [x] 5.4 Update navigation to use new styling

## 6. Password Detail View

- [x] 6.1 Redesign header with gradient icon and title
- [x] 6.2 Redesign username section with copy button
- [x] 6.3 Redesign password section with visibility toggle and copy
- [x] 6.4 Redesign category display
- [x] 6.5 Redesign notes section
- [x] 6.6 Redesign metadata section
- [x] 6.7 Redesign delete button with destructive styling
- [x] 6.8 Maintain existing edit functionality with new UI

## 7. Add Password Modal

- [x] 7.1 Create modal overlay with semi-transparent background
- [x] 7.2 Implement modal container with rounded corners
- [x] 7.3 Create modal header with cancel/save buttons
- [x] 7.4 Redesign form fields with proper styling (rounded-xl, 48px height)
- [x] 7.5 Add password visibility toggle
- [x] 7.6 Implement category dropdown
- [x] 7.7 Add form validation

## 8. Settings View

- [x] 8.1 Redesign settings modal container
- [x] 8.2 Create header with close button
- [x] 8.3 Implement general section (language, appearance)
- [x] 8.4 Implement security section (reset password)
- [x] 8.5 Add password reset form

## 9. Theme Support

- [x] 9.1 Implement Color Scheme observer for automatic theme switching
- [x] 9.2 Add manual theme toggle (light/dark)
- [x] 9.3 Persist theme preference
- [x] 9.4 Apply theme colors throughout all views

## 10. Polish & Bug Fixes

- [x] 10.1 Verify input field heights (44-48pt)
- [x] 10.2 Fix corner radius consistency
- [x] 10.3 Test dark/light mode transitions
- [x] 10.4 Verify all copy text matches prototype
- [x] 10.5 Build verification