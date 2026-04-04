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
            VStack(alignment: .leading, spacing: 28) {
                headerSection

                VStack(alignment: .leading, spacing: 20) {
                    detailFieldSection(
                        title: "detail.username".localized,
                        content: {
                            if isEditing {
                                editableTextField(text: $editedUsername, placeholder: "addEdit.username".localized)
                            } else {
                                PKFieldContainer {
                                    HStack(spacing: AppSpacing.sm) {
                                        Text(item.username)
                                            .font(.system(size: 14, weight: .medium))
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
                                        .font(.system(size: 14, weight: .medium))
                                    }

                                    TogglePasswordButton(isSecure: $showEditedPassword)
                                }
                            } else {
                                HStack(spacing: AppSpacing.sm) {
                                    PKFieldContainer {
                                        Text(showPassword ? item.password : String(repeating: "•", count: min(item.password.count, 20)))
                                            .font(.system(size: 14, weight: .medium, design: .monospaced))
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
                                        HStack(alignment: .firstTextBaseline) {
                                            Text(editedCategory)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppColors.foreground)
                                            Spacer()
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(AppColors.mutedForeground)
                                        }
                                    }
                                }
                                .menuStyle(.borderlessButton)
                            } else {
                                PKFieldContainer {
                                    HStack(spacing: AppSpacing.sm) {
                                        Image(systemName: categoryIcon(for: item.category))
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(AppColors.sidebarPrimary)
                                        Text(localizedCategory)
                                            .font(.system(size: 14, weight: .medium))
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
                                        .font(.system(size: 14, weight: .regular))
                                        .frame(minHeight: 132)
                                        .scrollContentBackground(.hidden)
                                        .padding(AppSpacing.xs)
                                        .background(AppColors.inputBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                                                .stroke(AppColors.border, lineWidth: 1)
                                        )
                                } else {
                                    PKFieldContainer(minHeight: 132) {
                                        Text(item.notes)
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(AppColors.foreground)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        )
                    }
                }

                PKMetadataPanel(title: "detail.details".localized) {
                    metadataRow(title: "detail.created".localized, value: item.createdAt.formatted(date: .abbreviated, time: .omitted))
                    metadataDivider
                    metadataRow(title: "detail.lastModified".localized, value: item.updatedAt.formatted(date: .abbreviated, time: .omitted))
                }

                if !isEditing {
                    deleteSection
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 28)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity, alignment: .topLeading)
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
        HStack(alignment: .center, spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientPrimary.opacity(0.16), AppColors.gradientOrange.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                GradientIcon(systemName: "key.fill", size: 26)
            }

            Group {
                if isEditing {
                    editableTitleField
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.foreground)
                            .lineLimit(2)

                        Text(localizedCategory)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.mutedForeground)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            headerButtons
        }
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private var editableTitleField: some View {
        PKFieldContainer(minHeight: 50) {
            TextField("addEdit.titleField".localized, text: $editedTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 24, weight: .bold))
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
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("detail.edit".localized)
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .frame(maxWidth: 232)
    }

    // MARK: - Shared Section Builders

    @ViewBuilder
    private func detailFieldSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.2)
                .foregroundColor(AppColors.mutedForeground)

            content()
        }
    }

    @ViewBuilder
    private func editableTextField(text: Binding<String>, placeholder: String) -> some View {
        PKFieldContainer {
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.foreground)
        }
    }

    @ViewBuilder
    private func metadataRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundColor(AppColors.mutedForeground)
            Spacer()
            Text(value)
                .foregroundColor(AppColors.foreground)
        }
        .font(.system(size: 12, weight: .medium))
    }

    @ViewBuilder
    private var metadataDivider: some View {
        Rectangle()
            .fill(AppColors.border)
            .frame(height: 1)
            .padding(.vertical, 4)
    }

    // MARK: - Delete Button

    @ViewBuilder
    private var deleteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle()
                .fill(AppColors.border)
                .frame(height: 1)

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                    Text("detail.deletePassword".localized)
                }
            }
            .buttonStyle(DestructiveButtonStyle())
        }
        .padding(.top, 4)
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
        isSaving = false
    }

    private func saveChanges() {
        isSaving = true
        onSave()
        isSaving = false
        isEditing = false
    }
}
