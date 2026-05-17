import SwiftUI
import FirebaseCore

@main
struct NewsAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeViewWrapper()
                .ignoresSafeArea()
        }
    }
}

// Bridging UIKit to SwiftUI
struct HomeViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let homeVC = HomeViewController()
        // Wrap in NavigationController for standard iOS navigation feel
        let navController = UINavigationController(rootViewController: homeVC)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed
    }
}
