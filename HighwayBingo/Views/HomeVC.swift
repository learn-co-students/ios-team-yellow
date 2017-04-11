///
/// HomeVC.swift
///

import Firebase
import Then
import UIKit

class HomeVC: UIViewController {
    
    let newGameLabel = UILabel()
    let newGameButton = UIImageView()
    let playingLabel = UILabel()
    let playingScrollView = UIScrollView()
    let playingStackView = UIStackView()
    
    let store = DataStore.shared
    
    var views: [UIView] {
        return [newGameLabel, newGameButton, playingLabel, playingScrollView]
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "We need a name for our app!"
        
        playingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Fetch User and Game data before setting up View
        DataStore.shared.fetchCurrentUser() {
            self.setupView()
        }
    }
    
    func setupView() {
        
        views.forEach(view.addSubview)
        views.forEach { $0.freeConstraints() }
        
        let navigationBarHeight: CGFloat = navigationController!.navigationBar.frame.height
        
        // New game label
        let newGameTap = UITapGestureRecognizer(target: self, action: #selector(self.pushNewGameVC(_:)))
        let newGameButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.pushNewGameVC(_:)))
        
        _ = newGameLabel.then {
            $0.text = "NEW GAME"
            $0.font = UIFont(name: "BelleroseLight", size: 30)
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(newGameTap)
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationBarHeight + 40).isActive = true
        }
        
        _ = newGameButton.then {
            $0.image = #imageLiteral(resourceName: "new")
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(newGameButtonTap)
            // Anchors
            $0.leadingAnchor.constraint(equalTo: newGameLabel.trailingAnchor, constant: 5).isActive = true
            $0.bottomAnchor.constraint(equalTo: newGameLabel.bottomAnchor, constant: -5).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        // Setup views for user's games
        _ = playingLabel.then {
            $0.text = "GAMES"
            $0.font = UIFont(name: "BelleroseLight", size: 30)
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: newGameLabel.bottomAnchor).isActive = true
        }
        
        _ = playingScrollView.then {
            $0.addSubview(playingStackView)
            // Anchors
            $0.topAnchor.constraint(equalTo: playingLabel.bottomAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
        
        _ = playingStackView.then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 25
            // Anchors
            $0.freeConstraints()
            $0.topAnchor.constraint(equalTo: playingScrollView.topAnchor, constant: 15).isActive = true
            $0.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: playingScrollView.bottomAnchor, constant: -20).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
        }
        
        store.currentUserGames.forEach { display(playingGame: $0) }
        
        // Show messages first (if any)
        store.currentUser.messages.forEach { display(message: $0) }
    }
    
    func display(playingGame game: Game) {
        
        let gameTap = UITapGestureRecognizer(target: self, action: #selector(self.pushGameOverviewVC(_:)))
        
        _ = PlayingGame(game: game).then {
            playingStackView.addArrangedSubview($0)
            // Border
            $0.layer.borderColor = game.boardType.tint.cgColor
            $0.layer.borderWidth = 1
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(gameTap)
            // Anchors
            $0.freeConstraints()
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 115).isActive = true
        }
    }
    
    func display(message: Message) {
        _ = MessageModal(message: message).then {
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
