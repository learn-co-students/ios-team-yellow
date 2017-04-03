///
/// FacebookManager.swift
///

import FacebookCore
import FacebookLogin
import FBSDKCoreKit

final class FacebookManager {
    
    static let shared = FacebookManager()
    
    private init() {}
    
    private let manager = LoginManager(loginBehavior: .systemAccount, defaultAudience: .everyone)
    
    func login(vc: UIViewController) {
        
        
        print(FBSDKAccessToken.current())
        
        self.manager.logIn([.publicProfile, .userFriends, .email], viewController: vc) { (result) in
            switch result {
            case .failed(let error):
                print("FacebookManager -> login failed\nError: \(error)")
            case .cancelled:
                print("FacebookManager -> login cancelled")
            case .success(let grantedPermissions, let deniedPermissions, let accessToken):
                if grantedPermissions.contains(Permission(name: "email")) == true {
                    //                    ApiClient.shared.facebookSignIn(authToken: accessToken.authenticationToken, completion: { (err, user) in
                    //                        if err == nil {
                    //                            // success
                    //                        }
                    //                        else {
                    //                            self.showAlert(forError: err!)
                    //                        }
                    //                    })
                }
                else {
                    //                    self.showAlert(forError: HAError(title: String(format: String.somethingError, String.signIn), message: grantedPermissions.contains(Permission(name: "email")) == true ? String.noAccountFound : String.missingEmailForSignUp))
                }
            }
        }
    }
}
