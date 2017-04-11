///
/// PlayingGame.swift
///

import Kingfisher
import UIKit

class PlayingGame: UIView {
   
    let gameTitleLabel = UILabel()
    let playersStackView = UIStackView()
    
    var game: Game
    
    var views: [UIView] {
        return [gameTitleLabel, playersStackView]
    }
    
    init(game: Game) {
        self.game = game
        super.init(frame: .zero)
        
        views.forEach(self.addSubview)
        views.forEach { $0.freeConstraints() }
        
        _ = gameTitleLabel.then {
            self.addSubview($0)
            $0.text = "\(game.boardType) Bingo"
            $0.font = UIFont(name: "Fabian", size: 25)
            // Anchors
            $0.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
            $0.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
            $0.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
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
        
        for player in game.players {
            
            let playerCell = UIView()
            let nameLabel = UILabel()
            let playerImageView = UIImageView()
            
            [playerCell, nameLabel, playerImageView].forEach { $0.freeConstraints() }
            
            _ = playerCell.then {
                $0.addSubview(nameLabel)
                $0.addSubview(playerImageView)
                playersStackView.addArrangedSubview($0)
                // Anchors
                $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                $0.widthAnchor.constraint(equalToConstant: 70).isActive = true
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
                _ = playerImageView.then {
                    $0.kfSetPlayerImage(with: url, diameter: 50)
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
