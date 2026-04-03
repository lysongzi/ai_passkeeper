import SwiftUI
import AppKit

// MARK: - Password Detail View New

/// Rebuilt detail view aligned to the RedesignUI prototype.
struct PasswordDetailViewNew: View {
    let item: DecryptedPasswordItem
    let onDelete: () -> Void
    let onSave: () -> Void

    @State private var showPassword = false
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
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                headerSection

                detailFieldSection(
                    title: "detail.username".localized,
                    content: {
                        if isEditing {
                            editableTextField(text: $editedUsername, placeholder: "addEdit.username".localized)
                        } else {
                            PKFieldContainer {
                                HStack(spacing: AppSpacing.sm) {
                                    Text(item.username)
                                        .font(.body)
                                        .textSelection(.enabled)
                                        .foregroundColor(AppColors.foreground)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    CopyButton(text: item.username)
                                }
                            }
                        }
                    }
                )

                detailFieldSection(
                    title: "detail.password".localized,
                    content: {
                        if isEditing {
                            HStack(spacing: AppSpacing.sm) {
                                PKFieldContainer {
                                    Group {
                                        if showEditedPassword {
                                            TextField("detail.password".localized, text: $editedPassword)
                                        } else {
                                            SecureField("detail.password".localized, text: $editedPassword)
                                        }
                                    }
                                    .textFieldStyle(.plain)
                                }

                                TogglePasswordButton(isSecure: $showEditedPassword)
                            }
                        } else {
                            HStack(spacing: AppSpacing.sm) {
                                PKFieldContainer {
                                    Text(showPassword ? item.password : String(repeating: "•", count: min(item.password.count, 20)))
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(AppColors.foreground)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                TogglePasswordButton(isSecure: $showPassword)
                                CopyButton(text: item.password)
                            }
                        }
                    }
                )

                detailFieldSection(
                    title: "addEdit.category".localized,
                    content: {
                        if isEditing {
                            Menu {
                                ForEach(categories, id: \.self) { category in
                                    Button(category) {
                                        editedCategory = category
                                    }
                                }
                            } label: {
                                PKFieldContainer {
                                    HStack {
                                        Text(editedCategory)
                                            .foregroundColor(AppColors.foreground)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(AppColors.mutedForeground)
                                    }
                                }
                            }
                            .menuStyle(.borderlessButton)
                        } else {
                            PKFieldContainer {
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: categoryIcon(for: item.category))
                                        .foregroundColor(AppColors.sidebarPrimary)
                                    Text(localizedCategory)
                                        .foregroundColor(AppColors.foreground)
                                    Spacer()
                                }
                            }
                        }
                    }
                )

                if isEditing || !item.notes.isEmpty {
                    detailFieldSection(
                        title: "detail.notes".localized,
                        content: {
                            if isEditing {
                                TextEditor(text: $editedNotes)
                                    .font(.body)
                                    .frame(minHeight: 120)
                                    .scrollContentBackground(.hidden)
                                    .padding(AppSpacing.xs)
                                    .background(AppColors.inputBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                                            .stroke(AppColors.border, lineWidth: 1)
                                    )
                            } else {
                                PKFieldContainer(minHeight: 120) {
                                    Text(item.notes)
                                        .font(.body)
                                        .foregroundColor(AppColors.foreground)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    )
                }

                PKMetadataPanel(title: "detail.details".localized) {
                    metadataRow(title: "detail.created".localized, value: item.createdAt.formatted(date: .abbreviated, time: .omitted))
                    metadataRow(title: "detail.lastModified".localized, value: item.updatedAt.formatted(date: .abbreviated, time: .omitted))
                }

                if !isEditing {
                    deleteButton
                }
            }
            .padding(AppSpacing.xl)
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
        HStack(alignment: .center, spacing: AppSpacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.radiusLg)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary.opacity(0.16), AppColors.gradientOrange.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 68, height: 68)

                GradientIcon(systemName: "key.fill", size: 30)
            }

            Group {
                if isEditing {
                    editableTitleField
                } else {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(item.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.foreground)

                        Text(localizedCategory)
                            .font(.subheadline)
                            .foregroundColor(AppColors.mutedForeground)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            headerButtons
        }
    }

    @ViewBuilder
    private var editableTitleField: some View {
        PKFieldContainer(minHeight: 48) {
            TextField("addEdit.titleField".localized, text: $editedTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 26, weight: .bold))
        }
    }

    @ViewBuilder
    private var headerButtons: some View {
        HStack(spacing: AppSpacing.sm) {
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
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "pencil")
                        Text("detail.edit".localized)
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .frame(maxWidth: 220)
    }

    // MARK: - Shared Section Builders

    @ViewBuilder
    private func detailFieldSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(AppColors.mutedForeground)

            content()
        }
    }

    @ViewBuilder
    private func editableTextField(text: Binding<String>, placeholder: String) -> some View {
        PKFieldContainer {
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .foregroundColor(AppColors.foreground)
        }
    }

    @ViewBuilder
    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(AppColors.mutedForeground)
            Spacer()
            Text(value)
                .foregroundColor(AppColors.foreground)
        }
        .font(.caption)
    }

    // MARK: - Delete Button

    @ViewBuilder
    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteConfirmation = true
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "trash")
                Text("detail.deletePassword".localized)
            }
        }
        .buttonStyle(DestructiveButtonStyle())
        .padding(.top, AppSpacing.sm)
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
