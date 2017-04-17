///
/// LoginVC.swift
///

import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin
import Firebase
import Then
import UIKit

class LoginVC: UIViewController, FBSDKLoginButtonDelegate {
    
    let loginButton = FBSDKLoginButton()
    
    @IBOutlet var loginView: UIView!
    
    @IBOutlet weak var loginMaskImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = loginButton.then {
            $0.delegate = self
            view.addSubview($0)
            // Anchors
            $0.freeConstraints()
            $0.centerXAnchor.constraint(equalTo: loginMaskImageView.centerXAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: loginMaskImageView.centerYAnchor, constant: 30 ).isActive = true
        }
    }
}


private typealias FacebookLoginManager = LoginVC
extension FacebookLoginManager {
    
    var newUser: Bool {
        return UserDefaults.standard.string(forKey: "userId") == nil
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("LoginVC -> error while logging in")
        }
        else if result.isCancelled {
            print("LoginVC -> user cancelled login")
        }
        else {
            print("LoginVC -> user logged in")
            validateLogin()
        }
    }
    
    func validateLogin() {
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let validationError = error {
                print("LoginVC -> error validating login: %@", validationError)
            } else if let user = user, let userId = AccessToken.current?.userId {
                let notificationName: Notification.Name = self.newUser ? .showInstructionsVC : .showHomeVC
                if self.newUser { UserDefaults.standard.set(userId, forKey: "userId") }
                FirebaseManager.shared.createOrUpdate(user)
                DispatchQueue.main.async { NotificationCenter.default.post(name: notificationName, object: nil) }
            } else {
                print("LoginVC -> error validating login")
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        do {
            try FIRAuth.auth()?.signOut()
            print("LoginVC -> user logged out")
        } catch let signOutError as NSError {
            print ("LoginVC -> error while signing out: %@", signOutError)
        }
    }
}
