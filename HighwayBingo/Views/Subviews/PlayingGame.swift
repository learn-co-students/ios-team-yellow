///
/// PlayingGame.swift
///

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
            //$0.text = game.
            // Anchors
            $0.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            $0.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        
        _ = playersStackView.then {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 25
            // Anchors
            $0.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: gameTitleLabel.bottomAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }

        for player in game.players {
            
            let playerCell = UIView()
            let nameLabel = UILabel()
            
            [playerCell, nameLabel].forEach { $0.freeConstraints() }
            
            _ = playerCell.then {
                $0.addSubview(nameLabel)
                playersStackView.addArrangedSubview($0)
                // Anchors
                $0.topAnchor.constraint(equalTo: gameTitleLabel.bottomAnchor).isActive = true
                $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
            }
            
            _ = nameLabel.then {
                $0.text = player.kindName
                $0.textAlignment = .center
                // Anchors
                $0.topAnchor.constraint(equalTo: playerCell.topAnchor).isActive = true
                $0.leftAnchor.constraint(equalTo: playerCell.leftAnchor).isActive = true
                $0.widthAnchor.constraint(equalTo: playerCell.widthAnchor).isActive = true
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
