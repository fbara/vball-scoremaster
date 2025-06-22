import SwiftUI
import ViewModels

@main
struct VBallScoreMasterApp: App {
    @State private var matchStore = MatchStore()
    var body: some Scene {
        WindowGroup {
            TabView {
                MainView()
                    .tabItem {
                        Label("Score", systemImage: "sportscourt")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .environment(\.matchStore, matchStore)
        }
    }
}
