import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            switch appState.currentScreen {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .home:
                HomeView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case .coloring(let page):
                ColoringView(page: page)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case .gallery:
                GalleryView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .bottom)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.currentScreen)
    }
}
