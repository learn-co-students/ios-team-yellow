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
    case loginVC = "loginVC"
    case homeVC = "navVC"
}


extension NotificationObservers {
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(switchViewController(with:)), name: .closeLoginVC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchViewController(with:)), name: .closeHomeVC, object: nil)
    }
}


extension Notification.Name {
    
    static let closeLoginVC = Notification.Name("close-login-view-controller")
    static let closeHomeVC = Notification.Name("close-game-view-controller")
    static let pushBoardCollectionVC = Notification.Name("push-board-collection-view-controller")
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
        case Notification.Name.closeLoginVC:
            switchToViewController(with: .homeVC)
        case Notification.Name.closeHomeVC:
            switchToViewController(with: .loginVC)
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
