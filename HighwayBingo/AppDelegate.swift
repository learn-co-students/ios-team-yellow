///
/// AppDelegate.swift
///

import FBSDKCoreKit
import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var window: UIWindow?
    
    override init() {
        super.init()
        
        // Configure Firebase
        FIRApp.configure()
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        // Initialize Facebook SDK and login User on the basis of persisted data
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Choose initial VC base on whether the User is FB authenticated
        let identifier = FBSDKAccessToken.current() == nil ? "loginVC" : "homeVC"
        let initialViewController = storyboard.instantiateViewController(withIdentifier: identifier)
        let navigationController = UINavigationController(rootViewController: initialViewController)
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}
