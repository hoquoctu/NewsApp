import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    private let profileScreen = ProfileScreen()
    private let db = Firestore.firestore()
    
    override func loadView() {
        view = profileScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hồ sơ cá nhân"
        
        profileScreen.logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        loadUserData()
    }
    
    private func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else { return }
            
            DispatchQueue.main.async {
                self.profileScreen.nameLabel.text = data["name"] as? String ?? "Người dùng"
                self.profileScreen.emailLabel.text = data["email"] as? String ?? "Chưa cập nhật email"
                self.profileScreen.phoneLabel.text = data["phoneNumber"] as? String ?? "Chưa cập nhật số điện thoại"
            }
        }
    }
    
    @objc private func handleLogout() {
        do {
            try Auth.auth().signOut()
            let loginVC = UINavigationController(rootViewController: LoginViewController())
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        } catch {
            print("Lỗi đăng xuất: \(error)")
        }
    }
}
