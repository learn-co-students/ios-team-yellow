///
/// PlayerPhoto.swift
///

import Kingfisher
import Then
import UIKit

class PlayerPhoto: UIView {
    
    let imageView = UIImageView()
    
    weak var delegate: TransitionToPlayerBoardDelegate?
    
    let game: Game
    let player: Player
    
    init(game: Game, player: Player) {
        self.game = game
        self.player = player
        super.init(frame: .zero)
        
        self.addSubview(imageView)
        
        let playerTap = UITapGestureRecognizer(target: self, action: #selector(self.playerTapped(_:)))
        
        _ = imageView.then {
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(playerTap)
            // Anchors
            $0.freeConstraints()
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        }
        
        if let url = player.imageUrl {
            imageView.kfSetPlayerImageRound(with: url, diameter: 50)
        }
    }
    
    func playerTapped(_: UITapGestureRecognizer) {
        if game.gameProgress == .notStarted { return }
        transitionToBoardVC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transitionToBoardVC() {
        FirebaseManager.shared.getBoard(for: game, userid: player.id) { (board) in
            if let board = board {
                self.delegate?.pushBoardVC(board: board, game: self.game, player: self.player)
            }
        }
    }
}
