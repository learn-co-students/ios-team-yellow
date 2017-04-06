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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let loginManager = FBSDKLoginManager()
//        loginManager.logOut()
        
        _ = loginButton.then {
            $0.delegate = self
            view.addSubview($0)
            $0.freeConstraints()
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
    }
    
    func navigateToHomeVC() {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! HomeVC
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
}


private typealias FacebookLoginManager = LoginVC
extension FacebookLoginManager {
    
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
                //
                // We are re-setting the user's name and profile photo every login, the userId "should" stay the same
                //
                UserDefaults.standard.set(userId, forKey: "userId")
                FirebaseManager.shared.createOrUpdate(user)
                self.navigateToHomeVC()
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
