///
/// HomeVC.swift
///

import Firebase
import Then
import UIKit

class HomeVC: UIViewController {
    
    var players = [Player]()
    
    let newGameLabel = UILabel()
    let playingLabel = UILabel()
    
    var views: [UIView] {
        return [playingLabel, newGameLabel]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            players.append(Player(currentUser))
        }
        
        views.forEach(view.addSubview)
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        _ = playingLabel.then {
            $0.text = "PLAYING"
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant:  screen.height * 0.1).isActive = true
        }
        
        let newGameTap = UITapGestureRecognizer(target: self, action: #selector(self.pushNewGameVC(_:)))
        
        _ = newGameLabel.then {
            $0.text = "NEW GAME"
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(newGameTap)
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant:  screen.height * 0.5).isActive = true
        }
    }
    
    func pushNewGameVC(_ sender: UITapGestureRecognizer) {
        let newGameVC = self.storyboard?.instantiateViewController(withIdentifier: "newGameVC") as! NewGameVC
        self.navigationController?.pushViewController(newGameVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
