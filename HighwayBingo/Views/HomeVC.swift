///
/// HomeVC.swift
///

import Firebase
import UIKit

class HomeVC: UIViewController {
    
    var players = [Player]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            players.append(Player(currentUser))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
