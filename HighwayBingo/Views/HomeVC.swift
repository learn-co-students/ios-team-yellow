///
/// HomeVC.swift
///

import Firebase
import Then
import UIKit

class HomeVC: UIViewController {
    
    let newGameLabel = UILabel()
    let playingLabel = UILabel()
    let playingStackView = UIStackView()
    
    let store = DataStore.shared
    
    var views: [UIView] {
        return [newGameLabel, playingLabel, playingStackView]
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "BelleroseLight", size: 20)!]
        
        playingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Fetch User and Game data before setting up View
        DataStore.shared.fetchCurrentUser() { self.setupView() }
    }
    
    func setupView() {
        
        views.forEach(view.addSubview)
        views.forEach { $0.freeConstraints() }
        
        // Setup views for user's games
        _ = playingLabel.then {
            $0.text = "GAMES"
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant:  screen.height * 0.1).isActive = true
        }
        
        _ = playingStackView.then {
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 25
            // Anchors
            $0.topAnchor.constraint(equalTo: playingLabel.bottomAnchor, constant: 20).isActive = true
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
        }
        
        store.currentUserGames.forEach { display(playingGame: $0) }
        
        // New game label
        let newGameTap = UITapGestureRecognizer(target: self, action: #selector(self.pushNewGameVC(_:)))
        
        _ = newGameLabel.then {
            $0.text = "NEW GAME"
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(newGameTap)
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant:  screen.height * 0.75).isActive = true
        }
        
        // Show notifications first (if any)
        store.currentUser.notifications.forEach { display(notification: $0) }
    }
    
    func display(playingGame game: Game) {
        
        let gameTap = UITapGestureRecognizer(target: self, action: #selector(self.pushGameOverviewVC(_:)))
        
        _ = PlayingGame(game: game).then {
            playingStackView.addArrangedSubview($0)
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(gameTap)
            // Border
            $0.layer.borderColor = UIColor.black.cgColor
            $0.layer.borderWidth = 1
            // Anchors
            $0.freeConstraints()
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 125).isActive = true
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
    
    func pushGameOverviewVC(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let gameIndex = playingStackView.subviews.index(of: view) else { return }
        let game = store.currentUserGames[gameIndex]
        let gameOverviewVC = self.storyboard?.instantiateViewController(withIdentifier: "gameOverviewVC") as! GameOverviewVC
        gameOverviewVC.game = game
        self.navigationController?.pushViewController(gameOverviewVC, animated: true)
    }
    
    func pushNewGameVC(_ sender: UITapGestureRecognizer) {
        let newGameVC = self.storyboard?.instantiateViewController(withIdentifier: "newGameVC") as! NewGameVC
        self.navigationController?.pushViewController(newGameVC, animated: true)
    }
    
}
