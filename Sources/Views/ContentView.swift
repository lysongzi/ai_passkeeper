import SwiftUI

/// Main content view - routes to appropriate screen based on app state
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var i18nService: I18nService

    var body: some View {
        Group {
            if appState.isFirstLaunch {
                // 首次启动显示创建密码界面
                SetupView()
            } else if appState.isLocked {
                // 已设置密码但已锁定
                LockScreenView()
            } else {
                // 已解锁，显示主界面
                MainView()
            }
        }
        .animation(.easeInOut, value: appState.isLocked)
    }
}

/// Lock screen for entering master password or biometric
struct LockScreenView: View {
    var body: some View {
        UnlockView()
    }
}

/// Initial setup screen for first-time users
struct SetupView: View {
    var body: some View {
        SetupViewNew()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}
