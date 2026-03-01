import SwiftUI

@main
struct StageReadyApp: App {
    // TEMPORARY: Set to false to always show onboarding for testing
    // Change back to @AppStorage for production
    @State private var hasCompletedOnboarding: Bool = false
    // @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("preferredColorScheme") private var preferredColorSchemeRaw = 0 // 0=system, 1=light, 2=dark

    var preferredColorScheme: ColorScheme? {
        switch preferredColorSchemeRaw {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .preferredColorScheme(preferredColorScheme)
        }
    }
}
