///
/// AppController.swift
///

import FBSDKCoreKit
import Foundation
import UIKit

class AppController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    var actingVC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationObservers()
        loadInitialViewController()
    }
}


private typealias NotificationObservers = AppController
private typealias LoadingVCs = AppController
private typealias DisplayingVCs = AppController


enum StoryboardID: String  {
    case instructionsVC = "instructionsVC"
    case loginVC = "loginVC"
    case homeVC = "navVC"
}


extension NotificationObservers {
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(switchViewController(with:)), name: .showHomeVC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchViewController(with:)), name: .showInstructionsVC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchViewController(with:)), name: .showLoginVC, object: nil)
    }
}


extension Notification.Name {
    
    static let showHomeVC = Notification.Name("show-home-view-controller")
    static let showInstructionsVC = Notification.Name("show-instructions-view-controller")
    static let showLoginVC = Notification.Name("show-login-view-controller")
}


extension LoadingVCs {
    
    func loadInitialViewController() {
        let id: StoryboardID = FBSDKAccessToken.current() == nil ? .loginVC : .homeVC
        self.actingVC = self.loadViewController(withID: id)
        self.add(viewController: self.actingVC, animated: true)
    }
    
    func loadViewController(withID id: StoryboardID) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id.rawValue)
    }
}


extension DisplayingVCs {
    
    func add(viewController: UIViewController, animated: Bool = false) {
        self.addChildViewController(viewController)
        containerView.addSubview(viewController.view)
        containerView.alpha = 0.0
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
        
        guard animated else { containerView.alpha = 1.0; return }
        
        UIView.transition(with: containerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.containerView.alpha = 1.0
        }) { _ in }
    }
    
    func switchViewController(with notification: Notification) {
        switch notification.name {
        case Notification.Name.showHomeVC:
            switchToViewController(with: .homeVC)
        case Notification.Name.showLoginVC:
            switchToViewController(with: .loginVC)
        case Notification.Name.showInstructionsVC:
            switchToViewController(with: .instructionsVC)
        default:
            fatalError("\(#function) - Unable to match notification name.")
        }
    }
    
    private func switchToViewController(with id: StoryboardID) {
        let existingVC = actingVC
        existingVC?.willMove(toParentViewController: nil)
        actingVC = loadViewController(withID: id)
        add(viewController: actingVC)
        actingVC.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.8, animations: {
            self.actingVC.view.alpha = 1.0
            existingVC?.view.alpha = 0.0
        }) { success in
            existingVC?.view.removeFromSuperview()
            existingVC?.removeFromParentViewController()
            self.actingVC.didMove(toParentViewController: self)
        }
    }
}
