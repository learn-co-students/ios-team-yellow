///
/// PlayerPhoto.swift
///

import Kingfisher
import Then
import UIKit

class PlayerPhoto: UIView {
    
    let imageView = UIImageView()
    let invitationImageView = UIImageView()
    
    weak var delegate: TransitionToPlayerBoardDelegate?
    
    let game: Game
    let player: Player
    
    var acceptedInvitation: Bool {
        return game.participants[player.id] ?? false
    }
    
    init(game: Game, player: Player) {
        self.game = game
        self.player = player
        super.init(frame: .zero)
        
        [imageView, invitationImageView].forEach { view in
            self.addSubview(view)
            view.freeConstraints()
        }
        
        let playerTap = UITapGestureRecognizer(target: self, action: #selector(self.playerTapped(_:)))
        
        _ = imageView.then {
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(playerTap)
            // Anchors
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        }
        
        if let url = player.imageUrl {
            imageView.kfSetPlayerImageRound(with: url, diameter: 50)
        }
        
        if !acceptedInvitation {
            
            _ = invitationImageView.then {
                $0.image = #imageLiteral(resourceName: "invitation")
                // Anchors
                $0.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 6).isActive = true
                $0.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -6).isActive = true
                $0.widthAnchor.constraint(equalToConstant: 20).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
            }
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
