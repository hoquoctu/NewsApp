import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class RegisterViewController: UIViewController {
    
    private let registerScreen = RegisterScreen()
    private let db = Firestore.firestore()
    
    override func loadView() {
        view = registerScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    private func setupActions() {
        registerScreen.registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }
    
    @objc private func handleRegister() {
        guard let name = registerScreen.nameTextField.text, !name.isEmpty,
              let email = registerScreen.emailTextField.text, !email.isEmpty,
              let phone = registerScreen.phoneTextField.text, !phone.isEmpty,
              let password = registerScreen.passwordTextField.text, password.count >= 6 else {
            showAlert(title: "Lỗi", message: "Vui lòng nhập đầy đủ thông tin và mật khẩu ít nhất 6 ký tự.")
            return
        }
        
        registerScreen.registerButton.setTitle("Đang xử lý...", for: .normal)
        registerScreen.registerButton.isEnabled = false
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                let nsError = error as NSError
                print("🔥 [FIREBASE AUTH ERROR] Domain: \(nsError.domain), Code: \(nsError.code)")
                print("🔥 [FIREBASE AUTH ERROR] Full details: \(nsError)")
                
                self.resetButton()
                self.showAlert(title: "Đăng ký thất bại", message: error.localizedDescription)
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            
            // Lưu thông tin vào Firestore
            let newUser = User(id: uid, email: email, name: name, phoneNumber: phone, note_article: [])
            
            do {
                try self.db.collection("users").document(uid).setData(from: newUser) { error in
                    self.resetButton()
                    if let error = error {
                        self.showAlert(title: "Lỗi lưu dữ liệu", message: error.localizedDescription)
                    } else {
                        // Đăng ký thành công, vào TabBar
                        let tabBar = MainTabBarController()
                        tabBar.modalPresentationStyle = .fullScreen
                        self.present(tabBar, animated: true)
                    }
                }
            } catch {
                self.resetButton()
                self.showAlert(title: "Lỗi", message: "Không thể lưu dữ liệu người dùng")
            }
        }
    }
    
    private func resetButton() {
        DispatchQueue.main.async {
            self.registerScreen.registerButton.setTitle("Đăng ký", for: .normal)
            self.registerScreen.registerButton.isEnabled = true
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
