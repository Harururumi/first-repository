import SwiftUI

@main
struct KidsColoringApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .onAppear {
                    SoundService.shared.setup()
                }
        }
    }
}

class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .splash

    func navigate(to screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.35)) {
            currentScreen = screen
        }
    }
}

enum AppScreen: Equatable {
    case splash
    case home
    case coloring(ColoringPage)
    case gallery

    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.splash, .splash): return true
        case (.home, .home): return true
        case (.gallery, .gallery): return true
        case (.coloring(let a), .coloring(let b)): return a.id == b.id
        default: return false
        }
    }
}
