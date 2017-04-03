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
    
    let firebaseManager = FirebaseManager.shared
    let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = loginButton.then {
            $0.delegate = self
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
    }
    
    func navigateToHomeVC() {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! HomeVC
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
}


private typealias FacebookManager = LoginVC
extension FacebookManager {
    
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
        // User's basic profile information is available from the FIRUser object
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let validationError = error {
                print("LoginVC -> error validating login: %@", validationError)
            } else if let user = user {
                self.firebaseManager.createOrUpdate(user)
                self.navigateToHomeVC()
            } else {
                print("LoginVC -> error validating login")
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let signOutError as NSError {
            print ("LoginVC -> error while signing out: %@", signOutError)
        }
        print("LoginVC -> user logged out")
    }
}
