import SwiftUI

// MARK: - Add/Edit Password Modal New

/// Rebuilt add/edit modal using shared modal and form primitives.
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
        PKModalContainer(onDismiss: { dismiss() }) {
            VStack(spacing: 0) {
                PKModalHeader(
                    title: editingItem == nil ? "main.addNewPassword".localized : "main.addPassword".localized,
                    left: {
                        Button("addEdit.cancel".localized) {
                            dismiss()
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.mutedForeground)
                    },
                    right: {
                        PKModalActionButton(
                            title: "addEdit.save".localized,
                            isEnabled: viewModel.isValid,
                            isLoading: viewModel.isSaving
                        ) {
                            Task {
                                if await viewModel.save() {
                                    onSave()
                                    dismiss()
                                }
                            }
                        }
                    }
                )

                Rectangle()
                    .fill(AppColors.border)
                    .frame(height: 1)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppColors.destructive)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppColors.destructive.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                                        .stroke(AppColors.destructive.opacity(0.22), lineWidth: 1)
                                )
                        }

                        fieldSection(title: "addEdit.titleField".localized, required: true) {
                            PKFieldContainer {
                                TextField(text: $viewModel.title, prompt: Text("addEdit.placeholder.title".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }

                        fieldSection(title: "addEdit.username".localized, required: true) {
                            PKFieldContainer {
                                TextField(text: $viewModel.username, prompt: Text("addEdit.placeholder.username".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }

                        fieldSection(title: "detail.password".localized, required: true) {
                            HStack(spacing: AppSpacing.sm) {
                                PKFieldContainer {
                                    Group {
                                        if viewModel.showPassword {
                                            TextField(text: $viewModel.password, prompt: Text("addEdit.placeholder.password".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
                                        } else {
                                            SecureField(text: $viewModel.password, prompt: Text("addEdit.placeholder.password".localized).foregroundColor(AppColors.mutedForeground.opacity(0.5))) { }
                                        }
                                    }
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 14, weight: .medium))
                                }

                                TogglePasswordButton(isSecure: $viewModel.showPassword)
                            }
                        }

                        fieldSection(title: "addEdit.category".localized, required: true) {
                            PKCategoryPicker(
                                categories: viewModel.categories,
                                selection: $viewModel.category
                            )
                        }

                        fieldSection(title: "detail.notes".localized, optional: true) {
                            TextEditor(text: $viewModel.notes)
                                .font(.system(size: 14, weight: .regular))
                                .frame(minHeight: 66)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppColors.inputBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                                        .stroke(AppColors.border, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 24)
                    .padding(.bottom, 28)
                }
            }
            .frame(width: 572, height: 648)
            .background(AppColors.popover)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: AppElevation.modalShadow, radius: 22, x: 0, y: 10)
        }
        .task {
            if let editingItem {
                viewModel.loadItem(editingItem)
            }
        }
    }

    private func fieldSection<Content: View>(
        title: String,
        required: Bool = false,
        optional: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 5) {
                if required {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 5, height: 5)
                }
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.2)
                    .foregroundColor(AppColors.mutedForeground)
                if optional {
                    Text("（选填）")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.mutedForeground.opacity(0.7))
                }
            }

            content()
        }
    }
}
