import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct NewsAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootViewWrapper()
                .ignoresSafeArea()
        }
    }
}

// Bridging UIKit to SwiftUI
struct RootViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        if Auth.auth().currentUser != nil {
            return MainTabBarController()
        } else {
            let loginVC = LoginViewController()
            return UINavigationController(rootViewController: loginVC)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}
