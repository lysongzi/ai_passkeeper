import SwiftUI

// MARK: - Add/Edit Password Modal New

/// Redesigned modal for adding or editing a password entry - matches prototype
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
            // Semi-transparent background - matches prototype
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Modal container - matches prototype styling
            VStack(spacing: 0) {
                // Header - matches prototype
                headerView

                Divider()

                // Form - matches prototype
                ScrollView {
                    VStack(spacing: 20) {
                        // Section title
                        Text("addEdit.details".localized)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.mutedForeground)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)

                        // Title field - matches prototype (right-aligned label)
                        FormFieldRightLabel(
                            label: "addEdit.titleField".localized,
                            placeholder: "addEdit.titleField".localized,
                            text: $viewModel.title,
                            icon: "textformat"
                        )
                        .padding(.horizontal, 16)

                        // Username field - matches prototype
                        FormFieldRightLabel(
                            label: "addEdit.username".localized,
                            placeholder: "addEdit.username".localized,
                            text: $viewModel.username,
                            icon: "person"
                        )
                        .padding(.horizontal, 16)

                        // Password field - matches prototype
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
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)

                        // Category picker - matches prototype
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
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .menuStyle(.borderlessButton)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)

                        // Notes field - matches prototype
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
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.border, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                }
            }
            .frame(width: 520, height: 640)
            .background(AppColors.popover)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.accent)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Spacer()

            Text(editingItem == nil ? "main.addNewPassword".localized : "main.addPassword".localized)
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
            .font(.headline)
            .foregroundColor(AppColors.primaryForeground)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(viewModel.isValid ? AppColors.primary : AppColors.muted)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .disabled(!viewModel.isValid || viewModel.isSaving)
        }
        .padding(16)
    }
}