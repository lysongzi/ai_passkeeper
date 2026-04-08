import SwiftUI

/// Main view with redesigned sidebar and detail shell.
struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var i18nService: I18nService
    @StateObject private var listViewModel = PasswordListViewModel()
    @State private var selectedPasswordId: UUID?
    @State private var showingAddSheet = false
    @State private var showingSettings = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarViewNew(
                viewModel: listViewModel,
                selectedPasswordId: $selectedPasswordId,
                showingSettings: $showingSettings
            )
            .navigationSplitViewColumnWidth(
                min: AppConstants.sidebarMinWidth,
                ideal: AppConstants.sidebarWidth,
                max: AppConstants.sidebarMaxWidth
            )
        } detail: {
            MainContentView(
                viewModel: listViewModel,
                selectedPasswordId: $selectedPasswordId,
                onAddNew: { showingAddSheet = true },
                onSettings: { showingSettings = true },
                onLock: { appState.lock() }
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsViewNew(onCategoriesChanged: {
                await listViewModel.refreshCategoriesAndPasswords()
            })
            .environmentObject(i18nService)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditPasswordViewNew(onSave: {
                Task { await listViewModel.refreshCategoriesAndPasswords() }
            })
        }
        .task {
            await listViewModel.refreshCategoriesAndPasswords()
            if selectedPasswordId == nil {
                selectedPasswordId = listViewModel.passwords.first?.id
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .addNewPassword)) { _ in
            showingAddSheet = true
        }
    }
}
