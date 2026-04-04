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
                        Button {
                            Task {
                                if await viewModel.save() {
                                    onSave()
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("addEdit.save".localized)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.primaryForeground)
                                .padding(.horizontal, 16)
                                .frame(height: 34)
                                .background(viewModel.isValid ? AppColors.primary : AppColors.muted)
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .opacity(viewModel.isSaving ? 0.86 : 1)
                        .disabled(!viewModel.isValid || viewModel.isSaving)
                    }
                )

                Rectangle()
                    .fill(AppColors.border)
                    .frame(height: 1)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("addEdit.details".localized)
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(0.2)
                                .foregroundColor(AppColors.mutedForeground)

                            Text(editingItem == nil ? "Create a new password entry" : "Update the selected password entry")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(AppColors.mutedForeground.opacity(0.92))
                        }

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

                        VStack(spacing: 18) {
                            formRow(label: "addEdit.titleField".localized, icon: "textformat") {
                                TextField("addEdit.titleField".localized, text: $viewModel.title)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 14, weight: .medium))
                            }

                            formRow(label: "addEdit.username".localized, icon: "person") {
                                TextField("addEdit.username".localized, text: $viewModel.username)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 14, weight: .medium))
                            }

                            PKFormRowRightLabel("detail.password".localized, labelWidth: 118, spacing: 16) {
                                HStack(spacing: AppSpacing.sm) {
                                    PKFieldContainer {
                                        HStack(spacing: AppSpacing.sm) {
                                            Image(systemName: "lock")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppColors.mutedForeground)
                                                .frame(width: 18)

                                            Group {
                                                if viewModel.showPassword {
                                                    TextField("detail.password".localized, text: $viewModel.password)
                                                } else {
                                                    SecureField("detail.password".localized, text: $viewModel.password)
                                                }
                                            }
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 14, weight: .medium))
                                        }
                                    }

                                    TogglePasswordButton(isSecure: $viewModel.showPassword)
                                        .frame(width: 30, height: 30)
                                        .background(AppColors.accent.opacity(0.72))
                                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                                }
                            }

                            PKFormRowRightLabel("addEdit.category".localized, labelWidth: 118, spacing: 16) {
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
                                    PKFieldContainer {
                                        HStack(spacing: AppSpacing.sm) {
                                            Image(systemName: categoryIcon(for: viewModel.category))
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(AppColors.sidebarPrimary)
                                                .frame(width: 18)

                                            Text(viewModel.category)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(AppColors.foreground)

                                            Spacer(minLength: 0)

                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(AppColors.mutedForeground)
                                        }
                                    }
                                }
                                .menuStyle(.borderlessButton)
                            }

                            PKFormRowRightLabel(
                                "detail.notes".localized,
                                labelWidth: 118,
                                spacing: 16,
                                verticalAlignment: .top
                            ) {
                                TextEditor(text: $viewModel.notes)
                                    .font(.system(size: 14, weight: .regular))
                                    .frame(minHeight: 132)
                                    .scrollContentBackground(.hidden)
                                    .padding(10)
                                    .background(AppColors.inputBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppConstants.radiusMd)
                                            .stroke(AppColors.border, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 24)
                    .padding(.bottom, 28)
                }
            }
            .frame(width: 572, height: 596)
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

    private func formRow<Field: View>(label: String, icon: String, @ViewBuilder field: () -> Field) -> some View {
        PKFormRowRightLabel(label, labelWidth: 118, spacing: 16) {
            PKFieldContainer {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.mutedForeground)
                        .frame(width: 18)

                    field()
                }
            }
        }
    }
}
