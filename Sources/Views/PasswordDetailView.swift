import SwiftUI
import AppKit

/// Detail view for a password entry
struct PasswordDetailView: View {
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
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("detail.deletePassword".localized + "?", isPresented: $showingDeleteConfirmation) {
            Button("detail.cancel".localized, role: .cancel) { }
            Button("detail.delete".localized, role: .destructive) {
                onDelete()
            }
        } message: {
            Text("detail.deleteConfirm".localized + " \"\(item.title)\"? " + "detail.deleteWarning".localized)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var headerSection: some View {
        HStack(alignment: .center) {
            headerIcon
            headerTitle
            Spacer()
            headerButtons
        }
    }

    @ViewBuilder
    private var headerIcon: some View {
        Image(systemName: "key.fill")
            .font(.system(size: 28))
            .foregroundStyle(.blue)
            .frame(width: 50, height: 50)
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private var headerTitle: some View {
        if isEditing {
            VStack(alignment: .leading, spacing: 0) {
                TextField("addEdit.titleField".localized, text: $editedTitle)
                    .textFieldStyle(.plain)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(12)
                    .frame(height: 60)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                    )
            }
        } else {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.title)
                    .fontWeight(.bold)
                Text(localizedCategory)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var headerButtons: some View {
        if isEditing {
            Button("detail.cancel".localized) {
                cancelEditing()
            }
            .buttonStyle(.bordered)

            Button("addEdit.save".localized) {
                saveChanges()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSaving || editedTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        } else {
            Button {
                startEditing()
            } label: {
                Label("detail.edit".localized, systemImage: "pencil")
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private var usernameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("detail.username".localized)
                .font(.headline)
                .foregroundStyle(.secondary)

            if isEditing {
                usernameEditField
            } else {
                usernameDisplay
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    @ViewBuilder
    private var usernameEditField: some View {
        TextField("addEdit.username".localized, text: $editedUsername)
            .textFieldStyle(.plain)
            .padding(10)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )
            .frame(height: 40)
    }

    @ViewBuilder
    private var usernameDisplay: some View {
        HStack {
            Text(item.username)
                .textSelection(.enabled)
            Spacer()
            Button {
                copyToClipboard(item.username)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("detail.password".localized)
                .font(.headline)
                .foregroundStyle(.secondary)

            passwordContent

            if let feedback = copyFeedback {
                Text(feedback)
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    @ViewBuilder
    private var passwordContent: some View {
        HStack(spacing: 12) {
            if isEditing {
                passwordEditField
                passwordToggleButton
            } else {
                passwordDisplay
                copyButton
            }
        }
    }

    @ViewBuilder
    private var passwordEditField: some View {
        Group {
            if showEditedPassword {
                TextField("detail.password".localized, text: $editedPassword)
            } else {
                SecureField("detail.password".localized, text: $editedPassword)
            }
        }
        .textFieldStyle(.plain)
        .padding(10)
        .background(Color(nsColor: .textBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
        )
        .frame(height: 40)
    }

    @ViewBuilder
    private var passwordToggleButton: some View {
        Button {
            showEditedPassword.toggle()
        } label: {
            Image(systemName: showEditedPassword ? "eye.slash" : "eye")
        }
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    private var passwordDisplay: some View {
        Group {
            if showPassword {
                Text(item.password)
            } else {
                Text(String(repeating: "•", count: min(item.password.count, 20)))
            }
        }
        .font(.system(.body, design: .monospaced))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var copyButton: some View {
        Button {
            showPassword.toggle()
        } label: {
            Image(systemName: showPassword ? "eye.slash" : "eye")
        }
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("addEdit.category".localized)
                .font(.headline)
                .foregroundStyle(.secondary)

            if isEditing {
                categoryPicker
            } else {
                categoryDisplay
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    @ViewBuilder
    private var categoryPicker: some View {
        Menu {
            ForEach(categories, id: \.self) { category in
                Button {
                    editedCategory = category
                } label: {
                    Text(category)
                        .frame(height: 30)
                }
            }
        } label: {
            HStack {
                Text(editedCategory)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundColor(.blue)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 30)
            .frame(height: 40, alignment: .center)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .frame(height: 40)
        .padding(.horizontal, 10)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var categoryDisplay: some View {
        HStack(alignment: .center) {
            Text(localizedCategory)
                .textSelection(.enabled)
            Spacer()
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var notesSection: some View {
        Group {
            if isEditing || !item.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("detail.notes".localized)
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    if isEditing {
                        notesEditor
                    } else {
                        notesDisplay
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var notesEditor: some View {
        TextEditor(text: $editedNotes)
            .font(.body)
            .frame(height: 120)
            .scrollContentBackground(.hidden)
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            )
    }

    @ViewBuilder
    private var notesDisplay: some View {
        Text(item.notes)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
    }

    @ViewBuilder
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("detail.details".localized)
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {
                Text("detail.created".localized)
                    .foregroundStyle(.secondary)
                Text(item.createdAt, style: .date)
            }
            .font(.caption)

            HStack {
                Text("detail.lastModified".localized)
                    .foregroundStyle(.secondary)
                Text(item.updatedAt, style: .date)
            }
            .font(.caption)
        }
    }

    @ViewBuilder
    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteConfirmation = true
        } label: {
            Label("detail.deletePassword".localized, systemImage: "trash")
        }
        .buttonStyle(.bordered)
    }

    // MARK: - Actions

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        copyFeedback = "detail.copied".localized

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if NSPasteboard.general.string(forType: .string) == text {
                NSPasteboard.general.clearContents()
            }
            withAnimation {
                copyFeedback = nil
            }
        }
    }

    private func startEditing() {
        editedTitle = item.title
        editedUsername = item.username
        editedPassword = item.password
        editedNotes = item.notes
        showEditedPassword = true  // 进入编辑模式时，密码默认可见

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

/// Detail row with copy button
struct DetailRow: View {
    let label: String
    let value: String
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack {
                Text(value)
                    .textSelection(.enabled)
                Spacer()
                Button {
                    onCopy()
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
        }
    }
}

#Preview {
    PasswordDetailView(
        item: DecryptedPasswordItem(
            title: "Example",
            username: "user@example.com",
            password: "secretpassword123",
            notes: "This is a test note"
        ),
        onDelete: { },
        onSave: { }
    )
}
