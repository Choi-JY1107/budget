import SwiftUI

@main
struct BudgetApp: App {
    /// "system" | "light" | "dark" — 사용자가 고른 화면 테마
    @AppStorage("appearance") private var appearance = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1280, minHeight: 800)
                .preferredColorScheme(schemeFor(appearance))
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1280, height: 800)   // 최소 크기와 동일
    }
}
