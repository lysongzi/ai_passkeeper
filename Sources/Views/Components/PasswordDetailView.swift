import SwiftUI
import AppKit

// MARK: - Password Detail View New

/// Redesigned detail view for a password entry with shadcn/ui styling - matches prototype
struct PasswordDetailViewNew: View {
    let item: DecryptedPasswordItem
    let onDelete: () -> Void
    let onSave: () -> Void

    @State private var showPassword = false
    @State private var copyFeedback: String?
    @State private var showingDeleteConfirmation = false
    @State private var isEditing = false

    @State private var editedTitle: String = ""
    @State private var editedUsername: String = ""
    @State private var editedPassword: String = ""
    @State private var editedNotes: String = ""
    @State private var editedCategory: String = ""
    @State private var showEditedPassword = false
    @State private var isSaving = false

    private let categories = PasswordCategory.allCases.map { $0.localizedName }

    private var localizedCategory: String {
        if let cat = PasswordCategory.allCases.first(where: { $0.rawValue == item.category }) {
            return cat.localizedName
        }
        return item.category
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                Divider()
                    .padding(.horizontal, 16)

                usernameSection

                passwordSection

                categorySection

                notesSection

                metadataSection

                Spacer()

                if !isEditing {
                    deleteButton
                }
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .alert("detail.deletePassword".localized + "?", isPresented: $showingDeleteConfirmation) {
            Button("detail.cancel".localized, role: .cancel) { }
            Button("detail.delete".localized, role: .destructive) {
                onDelete()
            }
        } message: {
            Text("detail.deleteConfirm".localized + " \"\(item.title)\"? " + "detail.deleteWarning".localized)
        }
    }

    // MARK: - Header Section

    @ViewBuilder
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            // Gradient icon - matches prototype
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.radiusLg)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary.opacity(0.15), AppColors.gradientOrange.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)

                GradientIcon(systemName: "key.fill", size: 28)
            }

            if isEditing {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("addEdit.titleField".localized, text: $editedTitle)
                        .textFieldStyle(.plain)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(12)
                        .frame(height: 48)
                        .background(AppColors.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.foreground)

                    Text(localizedCategory)
                        .font(.subheadline)
                        .foregroundColor(AppColors.mutedForeground)
                }
            }

            Spacer()

            headerButtons
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var headerButtons: some View {
        if isEditing {
            Button("detail.cancel".localized) {
                cancelEditing()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("addEdit.save".localized) {
                saveChanges()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isSaving || editedTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        } else {
            Button {
                startEditing()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                    Text("detail.edit".localized)
                }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    // MARK: - Username Section

    @ViewBuilder
    private var usernameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("detail.username".localized)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.mutedForeground)

            if isEditing {
                TextField("addEdit.username".localized, text: $editedUsername)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .frame(height: AppConstants.inputHeight)
                    .background(AppColors.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
            } else {
                HStack {
                    Text(item.username)
                        .font(.body)
                        .textSelection(.enabled)
                        .foregroundColor(AppColors.foreground)
                    Spacer()
                    CopyButton(text: item.username)
                }
                .padding(12)
                .background(AppColors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Password Section

    @ViewBuilder
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("detail.password".localized)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.mutedForeground)

            HStack(spacing: 12) {
                if isEditing {
                    // Edit mode - matches prototype
                    Group {
                        if showEditedPassword {
                            TextField("detail.password".localized, text: $editedPassword)
                        } else {
                            SecureField("detail.password".localized, text: $editedPassword)
                        }
                    }
                    .textFieldStyle(.plain)
                    .padding(12)
                    .frame(height: AppConstants.inputHeight)
                    .background(AppColors.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                            .stroke(AppColors.border, lineWidth: 1)
                    )

                    TogglePasswordButton(isSecure: $showEditedPassword)
                } else {
                    // Display mode - matches prototype
                    Group {
                        if showPassword {
                            Text(item.password)
                                .font(.system(.body, design: .monospaced))
                        } else {
                            Text(String(repeating: "•", count: min(item.password.count, 20)))
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(AppColors.foreground)
                    .padding(12)
                    .background(AppColors.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))

                    TogglePasswordButton(isSecure: $showPassword)

                    CopyButton(text: item.password)
                }
            }

            if !isEditing {
                Text("common.copied".localized)
                    .font(.caption)
                    .foregroundColor(.green)
                    .opacity(copyFeedback != nil ? 1 : 0)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Category Section

    @ViewBuilder
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("addEdit.category".localized)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.mutedForeground)

            if isEditing {
                Menu {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            editedCategory = category
                        } label: {
                            Text(category)
                        }
                    }
                } label: {
                    HStack {
                        Text(editedCategory)
                            .foregroundColor(AppColors.foreground)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.mutedForeground)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: AppConstants.inputHeight)
                    .background(AppColors.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                }
                .menuStyle(.borderlessButton)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            } else {
                HStack {
                    Image(systemName: categoryIcon(for: item.category))
                        .foregroundColor(AppColors.sidebarPrimary)
                    Text(localizedCategory)
                        .foregroundColor(AppColors.foreground)
                    Spacer()
                }
                .padding(12)
                .background(AppColors.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Notes Section

    @ViewBuilder
    private var notesSection: some View {
        Group {
            if isEditing || !item.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("detail.notes".localized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.mutedForeground)

                    if isEditing {
                        TextEditor(text: $editedNotes)
                            .font(.body)
                            .frame(height: 120)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .background(AppColors.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                    } else {
                        Text(item.notes)
                            .font(.body)
                            .foregroundColor(AppColors.foreground)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Metadata Section

    @ViewBuilder
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("detail.details".localized)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppColors.mutedForeground)

            // Metadata display - inline implementation
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("detail.created".localized)
                        .foregroundColor(AppColors.mutedForeground)
                    Spacer()
                    Text(item.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(AppColors.foreground)
                }
                .font(.caption)

                HStack {
                    Text("detail.lastModified".localized)
                        .foregroundColor(AppColors.mutedForeground)
                    Spacer()
                    Text(item.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(AppColors.foreground)
                }
                .font(.caption)
            }
            .padding(12)
            .background(AppColors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Delete Button

    @ViewBuilder
    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteConfirmation = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                Text("detail.deletePassword".localized)
            }
        }
        .buttonStyle(DestructiveButtonStyle())
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Actions

    private func startEditing() {
        editedTitle = item.title
        editedUsername = item.username
        editedPassword = item.password
        editedNotes = item.notes
        showEditedPassword = true

        if let cat = PasswordCategory.allCases.first(where: { $0.rawValue == item.category }) {
            editedCategory = cat.localizedName
        } else {
            editedCategory = item.category
        }

        isEditing = true
    }

    private func cancelEditing() {
        isEditing = false
        editedTitle = ""
        editedUsername = ""
        editedPassword = ""
        editedNotes = ""
        editedCategory = ""
    }

    private func saveChanges() {
        guard !editedTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isSaving = true

        Task {
            let repository = PasswordRepository()
            let categoryKey = PasswordCategory.allCases.first { $0.localizedName == editedCategory }?.rawValue ?? editedCategory

            do {
                try await repository.updateItem(
                    id: item.id,
                    title: editedTitle.trimmingCharacters(in: .whitespaces),
                    username: editedUsername.trimmingCharacters(in: .whitespaces),
                    password: editedPassword,
                    category: categoryKey,
                    notes: editedNotes
                )

                await MainActor.run {
                    isSaving = false
                    isEditing = false
                    onSave()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
}