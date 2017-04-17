///
/// PlayerPhoto.swift
///

import Kingfisher
import Then
import UIKit

class PlayerPhoto: UIView {
    
    let playerImageView = UIImageView()
    let invitationImageView = UIImageView()
    let rankLabel = UILabel()
    
    weak var delegate: TransitionToPlayerBoardDelegate?
    
    let game: Game
    let player: Player
    
    var acceptedInvitation: Bool {
        return game.participants[player.id] ?? false
    }
    
    var rank: String? {
        return game.playerPositions.filter({ $0.playerId == player.id }).first?.rankText
    }
    
    var views: [UIView] {
        return [playerImageView, invitationImageView, rankLabel]
    }
    
    init(game: Game, player: Player) {
        self.game = game
        self.player = player
        super.init(frame: .zero)
        
        views.forEach(addSubview)
        views.forEach { $0.freeConstraints() }
        
        let playerTap = UITapGestureRecognizer(target: self, action: #selector(self.playerTapped(_:)))
        
        _ = playerImageView.then {
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(playerTap)
            // Anchors
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        }
        
        _ = rankLabel.then {
            $0.text = rank
            $0.font = UIFont(name: "Fabian", size: 16)
            // Anchors
            $0.topAnchor.constraint(equalTo: playerImageView.topAnchor, constant: -6).isActive = true
            $0.leadingAnchor.constraint(equalTo: playerImageView.trailingAnchor, constant: -6).isActive = true
        }
        
        if let url = player.imageUrl {
            playerImageView.kfSetPlayerImageRound(with: url, diameter: 50)
        }
        
        if !acceptedInvitation && game.gameProgress == .notStarted {
            
            _ = invitationImageView.then {
                $0.image = #imageLiteral(resourceName: "invitation")
                // Anchors
                $0.trailingAnchor.constraint(equalTo: playerImageView.trailingAnchor, constant: 6).isActive = true
                $0.topAnchor.constraint(equalTo: playerImageView.topAnchor, constant: -6).isActive = true
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
