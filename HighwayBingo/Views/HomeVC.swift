///
/// HomeVC.swift
///

import Firebase
import Then
import UIKit


protocol TransitionToPlayerBoardDelegate: class {
    var storyboard: UIStoryboard? { get }
    var navigationController: UINavigationController? { get }
    func pushBoardVC(board: Board, game: Game, player: Player)
}


extension TransitionToPlayerBoardDelegate {
    func pushBoardVC(board: Board, game: Game, player: Player) {
        let boardCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "boardCollectionVC") as! BoardCollectionVC
        boardCollectionVC.board = board
        boardCollectionVC.game = game
        boardCollectionVC.player = player
        self.navigationController?.pushViewController(boardCollectionVC, animated: true)
    }
}


class HomeVC: UIViewController, TransitionToPlayerBoardDelegate {
    
    let newGameLabel = UILabel()
    let newGameButton = UIImageView()
    let playingLabel = UILabel()
    let playingScrollView = UIScrollView()
    let playingStackView = UIStackView()
    
    let store = DataStore.shared
    
    var views: [UIView] {
        return [newGameLabel, newGameButton, playingLabel, playingScrollView]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseManager.shared.refreshFirebase(completion: { (success) in
            if success {
                self.store.fetchCurrentUser() {
                    DispatchQueue.main.async {
                        self.playingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                        self.setupView()
                    }
                }
            }
        })

  
    }
    
    
    func createGameViews(_ games: [Game]) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "AI - Spy"
        
        var image = #imageLiteral(resourceName: "instruction")
        image = resizeImage(image: image, targetSize: CGSize(width: 35, height: 35))
        image = image.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.pushInstructionsVC(_:)))

//        playingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        // Fetch User and Game data before setting up View
//        DataStore.shared.fetchCurrentUser() { self.setupView() }
        
      

    }
    
    func setupView() {
        
        views.forEach(view.addSubview)
        views.forEach { $0.freeConstraints() }
        
        // New game label
        let newGameTap = UITapGestureRecognizer(target: self, action: #selector(self.pushNewGameVC(_:)))
        let newGameButtonTap = UITapGestureRecognizer(target: self, action: #selector(self.pushNewGameVC(_:)))
        
        _ = newGameLabel.then {
            $0.text = "NEW GAME"
            $0.font = UIFont(name: "BelleroseLight", size: 24)
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(newGameTap)
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: navBarHeight + 40).isActive = true
        }
        
        _ = newGameButton.then {
            $0.image = #imageLiteral(resourceName: "new")
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(newGameButtonTap)
            // Anchors
            $0.leadingAnchor.constraint(equalTo: newGameLabel.trailingAnchor, constant: 5).isActive = true
            $0.bottomAnchor.constraint(equalTo: newGameLabel.bottomAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        // Setup views for user's games
        _ = playingLabel.then {
            $0.text = "GAMES"
            $0.font = UIFont(name: "BelleroseLight", size: 24)
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
        
        _ = PlayingGame(game: game, delegate: self).then {
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
        guard let messageModal = MessageModal(message: message) else { return }
        _ = messageModal.then {
            view.addSubview($0)
            // Border
            $0.purpleBorder()
            // Anchors
            $0.freeConstraints()
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: navBarHeight + 50).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
            $0.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
            $0.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        }
    }
    
    func pushGameOverviewVC(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let gameIndex = playingStackView.subviews.index(of: view) else { return }
        let game = store.currentUserGames[gameIndex]
        let gameOverviewVC = self.storyboard?.instantiateViewController(withIdentifier: "gameOverviewVC") as! GameOverviewVC
        gameOverviewVC.game = game
        self.navigationController?.pushViewController(gameOverviewVC, animated: true)
    }
    
    func pushInstructionsVC(_:UIBarButtonItem) {
        DispatchQueue.main.async { NotificationCenter.default.post(name: .showInstructionsVC, object: nil) }
    }
    
    func pushNewGameVC(_ sender: UITapGestureRecognizer) {
        let newGameVC = self.storyboard?.instantiateViewController(withIdentifier: "newGameVC") as! NewGameVC
        self.navigationController?.pushViewController(newGameVC, animated: true)
    }
}
