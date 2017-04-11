///
/// AppDelegate.swift
///

import FBSDKCoreKit
import Firebase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    override init() {
        super.init()
        
        FIRApp.configure()
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "BelleroseLight", size: 20)!]
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}
