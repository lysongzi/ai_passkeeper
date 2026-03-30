import SwiftUI

// MARK: - Add/Edit Password Modal New

/// Redesigned modal for adding or editing a password entry
struct AddEditPasswordViewNew: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddEditPasswordViewModel()

    let editingItem: DecryptedPasswordItem?
    let onSave: () -> Void

    init(editingItem: DecryptedPasswordItem? = nil, onSave: @escaping () -> Void) {
        self.editingItem = editingItem
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Modal container
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(16)

                Divider()

                // Form
                ScrollView {
                    VStack(spacing: 20) {
                        // Title field
                        FormField(
                            label: "addEdit.titleField".localized,
                            placeholder: "addEdit.titleField".localized,
                            text: $viewModel.title,
                            icon: "textformat"
                        )

                        // Username field
                        FormField(
                            label: "addEdit.username".localized,
                            placeholder: "addEdit.username".localized,
                            text: $viewModel.username,
                            icon: "person"
                        )

                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("detail.password".localized)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.foreground)

                            HStack(spacing: 12) {
                                if viewModel.showPassword {
                                    TextField("detail.password".localized, text: $viewModel.password)
                                        .textFieldStyle(.plain)
                                } else {
                                    SecureField("detail.password".localized, text: $viewModel.password)
                                        .textFieldStyle(.plain)
                                }

                                TogglePasswordButton(isSecure: $viewModel.showPassword)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .frame(height: AppConstants.inputHeight)
                            .background(AppColors.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.radiusXl)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        }

                        // Category picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("addEdit.category".localized)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.foreground)

                            Menu {
                                ForEach(viewModel.categories, id: \.self) { category in
                                    Button {
                                        viewModel.category = category
                                    } label: {
                                        HStack {
                                            Image(systemName: categoryIcon(for: category))
                                            Text(category)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: categoryIcon(for: viewModel.category))
                                        .foregroundColor(AppColors.sidebarPrimary)
                                    Text(viewModel.category)
                                        .foregroundColor(AppColors.foreground)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.mutedForeground)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: AppConstants.inputHeight)
                                .background(AppColors.inputBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
                            }
                            .menuStyle(.borderlessButton)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.radiusXl)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        }

                        // Notes field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("detail.notes".localized)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.foreground)

                            TextEditor(text: $viewModel.notes)
                                .font(.body)
                                .frame(height: 100)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(AppColors.inputBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.radiusXl)
                                        .stroke(AppColors.border, lineWidth: 1)
                                )
                        }
                    }
                    .padding(16)
                }
            }
            .frame(width: 480, height: 600)
            .background(AppColors.popover)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
            .shadow(color: Color.black.opacity(0.2), radius: 20)
        }
    }

    // MARK: - Header View

    @ViewBuilder
    private var headerView: some View {
        HStack {
            Button("addEdit.cancel".localized) {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundColor(AppColors.mutedForeground)

            Spacer()

            Text(viewModel.isEditing ? "main.addPassword".localized : "main.addNewPassword".localized)
                .font(.headline)
                .foregroundColor(AppColors.foreground)

            Spacer()

            Button("addEdit.save".localized) {
                Task {
                    if await viewModel.save() {
                        onSave()
                        dismiss()
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 80)
            .disabled(!viewModel.isValid || viewModel.isSaving)
        }
    }
}