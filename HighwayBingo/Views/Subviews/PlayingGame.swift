///
/// PlayingGame.swift
///

import UIKit

class PlayingGame: UIView {
    
    let gameTitleLabel = UILabel()
    let playersStackView = UIStackView()
    
    var game: Game
    
    init(game: Game) {
        self.game = game
        super.init(frame: .zero)
        setupView()
    }
    
    func setupView() {
        
        _ = gameTitleLabel.then {
            $0.text = "Game Title"
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            $0.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        
        _ = playersStackView.then {
            self.addSubview($0)
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 25
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            
            $0.topAnchor.constraint(equalTo: gameTitleLabel.bottomAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
        for player in game.players {
            
            let playerCell = UIView()
            let nameLabel = UILabel()
            
            _ = playerCell.then {
                $0.addSubview(nameLabel)
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.heightAnchor.constraint(equalToConstant: 80).isActive = true
                $0.widthAnchor.constraint(equalToConstant: 80).isActive = true
                playersStackView.addArrangedSubview($0)
            }
            
            _ = nameLabel.then {
                $0.text = player.kindName
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.topAnchor.constraint(equalTo: playerCell.topAnchor).isActive = true
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
