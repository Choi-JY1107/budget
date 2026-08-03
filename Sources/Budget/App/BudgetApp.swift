import SwiftUI

@main
struct BudgetApp: App {
    /// "system" | "light" | "dark" — 사용자가 고른 화면 테마
    @AppStorage("appearance") private var appearance = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1280, minHeight: 700)
                .preferredColorScheme(schemeFor(appearance))
        }
        .windowStyle(.hiddenTitleBar)
    }
}
