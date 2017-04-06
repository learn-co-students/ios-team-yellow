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
        //
        DataStore.shared.fetchCurrentUser() { self.setupView() }
    }
    
    func setupView() {
        
        let currentUser = DataStore.shared.currentUser
        
        views.forEach(view.addSubview)
        views.forEach { $0.freeConstraints() }
        
        // Setup Views for Games the Current User is Playing
        //
        _ = playingLabel.then {
            $0.text = "PLAYING"
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant:  screen.height * 0.1).isActive = true
        }
        
        currentUser.games.forEach { display(playingGame: $0) }
        
        // New Game Option
        //
        let newGameTap = UITapGestureRecognizer(target: self, action: #selector(self.pushNewGameVC(_:)))
        
        _ = newGameLabel.then {
            $0.text = "NEW GAME"
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(newGameTap)
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant:  screen.height * 0.5).isActive = true
        }
        
        // Show Notifications first (if any)
        //
        currentUser.notifications.forEach { display(notification: $0) }
    }
    
    func display(playingGame game: Game) {
        _ = PlayingGame(game: game).then {
            view.addSubview($0)
            // Border
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.borderWidth = 1
            // Anchors
            $0.freeConstraints()
            $0.topAnchor.constraint(equalTo: playingLabel.bottomAnchor).isActive = true
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 80).isActive = true
        }
    }
    
    func display(notification: Notification) {
        _ = NotificationModal(notification: notification).then {
            view.addSubview($0)
            $0.backgroundColor = .yellow
            // Anchors
            $0.freeConstraints()
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
            $0.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
            $0.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
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
    
    @IBAction func buttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "boardSegue", sender: self)
    }
}
