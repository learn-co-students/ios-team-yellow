///
/// PlayingGame.swift
///

import UIKit

class PlayingGame: UIView {
    
    let gameStatusLabel = UILabel()
    let gameTitleLabel = UILabel()
    let playersStackView = UIStackView()
    
    weak var delegate: TransitionToPlayerBoardDelegate?
    
    var game: Game
    
    var views: [UIView] {
        return [gameStatusLabel, gameTitleLabel, playersStackView]
    }
    
    init(game: Game, delegate: TransitionToPlayerBoardDelegate) {
        self.game = game
        self.delegate = delegate
        super.init(frame: .zero)
        
        views.forEach(self.addSubview)
        views.forEach { $0.freeConstraints() }
        
        _ = gameStatusLabel.then {
            $0.text = game.gameProgress.status
            $0.font = UIFont(name: "BelleroseLight", size: 15)
            // Anchors
            $0.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        }
        
        _ = gameTitleLabel.then {
            $0.text = "\(game.boardType) Bingo"
            $0.font = UIFont(name: "Fabian", size: 25)
            // Anchors
            $0.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 35).isActive = true
        }
        
        _ = playersStackView.then {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 10
            // Anchors
            $0.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: gameTitleLabel.bottomAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
        let players = game.gameProgress == .notStarted ? game.players : game.playersOrderedByRank
        
        for player in players {
            
            let playerCell = UIView()
            let nameLabel = UILabel()
            let playerImageView = UIImageView()
            
            [playerCell, nameLabel].forEach { $0.freeConstraints() }
            
            _ = playerCell.then {
                $0.addSubview(nameLabel)
                $0.addSubview(playerImageView)
                playersStackView.addArrangedSubview($0)
                // Anchors
                $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                $0.widthAnchor.constraint(equalToConstant: (UIScreen.smallDevice ? 60 : 70)).isActive = true
            }
            
            _ = nameLabel.then {
                $0.text = player.kindName
                $0.textAlignment = .center
                $0.font = UIFont(name: "BelleroseLight", size: 15)
                // Anchors
                $0.bottomAnchor.constraint(equalTo: playerCell.bottomAnchor, constant: -5).isActive = true
                $0.leftAnchor.constraint(equalTo: playerCell.leftAnchor).isActive = true
                $0.widthAnchor.constraint(equalTo: playerCell.widthAnchor).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 25).isActive = true
            }
            
            if let url = player.imageUrl {
                
                let playerPhoto = PlayerPhoto(game: game, player: player)
                _ = playerPhoto.then {
                    $0.delegate = self.delegate
                    self.addSubview(playerPhoto)
                    playerPhoto.freeConstraints()
                    // Anchors
                    $0.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 5).isActive = true
                    $0.centerXAnchor.constraint(equalTo: playerCell.centerXAnchor).isActive = true
                    $0.widthAnchor.constraint(equalToConstant: 50).isActive = true
                    $0.heightAnchor.constraint(equalToConstant: 45).isActive = true
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
