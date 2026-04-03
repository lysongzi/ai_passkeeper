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
                        .foregroundColor(AppColors.mutedForeground)
                    },
                    right: {
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
                        .padding(.horizontal, AppSpacing.lg)
                        .frame(height: 36)
                        .background(viewModel.isValid ? AppColors.primary : AppColors.muted)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusMd))
                        .disabled(!viewModel.isValid || viewModel.isSaving)
                    }
                )

                Divider()
                    .overlay(AppColors.border)

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        Text("addEdit.details".localized)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(AppColors.mutedForeground)

                        PKFormRowRightLabel("addEdit.titleField".localized) {
                            PKFieldContainer {
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "textformat")
                                        .foregroundColor(AppColors.mutedForeground)
                                        .frame(width: AppConstants.iconSizeMd)

                                    TextField("addEdit.titleField".localized, text: $viewModel.title)
                                        .textFieldStyle(.plain)
                                }
                            }
                        }

                        PKFormRowRightLabel("addEdit.username".localized) {
                            PKFieldContainer {
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "person")
                                        .foregroundColor(AppColors.mutedForeground)
                                        .frame(width: AppConstants.iconSizeMd)

                                    TextField("addEdit.username".localized, text: $viewModel.username)
                                        .textFieldStyle(.plain)
                                }
                            }
                        }

                        PKFormRowRightLabel("detail.password".localized) {
                            HStack(spacing: AppSpacing.sm) {
                                PKFieldContainer {
                                    Group {
                                        if viewModel.showPassword {
                                            TextField("detail.password".localized, text: $viewModel.password)
                                        } else {
                                            SecureField("detail.password".localized, text: $viewModel.password)
                                        }
                                    }
                                    .textFieldStyle(.plain)
                                }

                                TogglePasswordButton(isSecure: $viewModel.showPassword)
                            }
                        }

                        PKFormRowRightLabel("addEdit.category".localized) {
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
                                }
                            }
                            .menuStyle(.borderlessButton)
                        }

                        PKFormRowRightLabel(
                            "detail.notes".localized,
                            verticalAlignment: .top
                        ) {
                            TextEditor(text: $viewModel.notes)
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
                        }
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.lg)
                }
            }
            .frame(width: 560, height: 620)
            .background(AppColors.popover)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.radiusXl))
            .shadow(color: AppElevation.modalShadow, radius: 20, x: 0, y: 8)
        }
    }
}
