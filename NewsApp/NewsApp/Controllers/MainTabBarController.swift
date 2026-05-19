import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Trang chủ", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let bookmarksVC = BookmarksViewController()
        let bookmarksNav = UINavigationController(rootViewController: bookmarksVC)
        bookmarksNav.tabBarItem = UITabBarItem(title: "Đã lưu", image: UIImage(systemName: "bookmark"), selectedImage: UIImage(systemName: "bookmark.fill"))
        
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Hồ sơ", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        viewControllers = [homeNav, bookmarksNav, profileNav]
        
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .white
        
        // Navigation Bar styling
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .white
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
}
