///
/// HomeVC.swift
///

import Firebase
import Then
import UIKit

class HomeVC: UIViewController {
    
    let newGameLabel = UILabel()
    let playingLabel = UILabel()
    
    var views: [UIView] {
        return [playingLabel, newGameLabel]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch User and Game data before setting up View
        DataStore.shared.fetchCurrentUser() { self.setupView() }
    }
    
    func setupView() {
    
        let currentUser = DataStore.shared.currentUser
        
        views.forEach(view.addSubview)
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        _ = playingLabel.then {
            $0.text = "PLAYING"
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant:  screen.height * 0.1).isActive = true
        }
        
        for game in currentUser.games {
            
            _ = PlayingGame(game: game).then {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
                $0.layer.borderColor = UIColor.black.cgColor
                $0.layer.borderWidth = 1
                $0.topAnchor.constraint(equalTo: playingLabel.bottomAnchor).isActive = true
                $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
                $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 80).isActive = true
            }
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
