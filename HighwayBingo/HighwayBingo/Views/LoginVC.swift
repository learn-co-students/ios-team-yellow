///
/// LoginVC.swift
///

import UIKit

class LoginVC: UIViewController {
    
    let facebookManager = FacebookManager.shared
    
    @IBAction func loginButton(_ sender: Any) {
        facebookManager.login(vc: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
