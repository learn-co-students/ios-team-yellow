///
/// PlayerCell.swift
///

import UIKit
import Then

class PlayerCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let playerImageView = UIImageView()
    let lastPicImageView = UIImageView()
    let numberLabel = UILabel()
    
    let screenSize = UIScreen.main.bounds
    var lastPicImageURL: URL?
    
    
    static let reuseID = "player"
    
    weak var delegate: TransitionToPlayerBoardDelegate?
    
    var game: Game?
    var player: Player? {
        didSet {
            guard let player = player else { return }
            nameLabel.text = player.kindName
            if let url = player.lastPic { lastPicImageView.kfSetPlayerImageRound(with: url, diameter: 80) }
            if let game = game { addPlayerPhoto(game: game, player: player) }
        }
    }
    
    var views: [UIView] {

        return [nameLabel, lastPicImageView]

    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        views.forEach { contentView.addSubview($0) }
        views.forEach { $0.freeConstraints() }
        
        _ = nameLabel.then {
            $0.textAlignment = .center
            $0.font = UIFont(name: "BelleroseLight", size: 20)
            // Anchors
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: screenSize.width * 0.15).isActive = true
            $0.widthAnchor.constraint(equalToConstant: screenSize.width * 0.25).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
        _ = lastPicImageView.then {
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: screenSize.width * 0.64).isActive = true
            $0.bottomAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
    }
    
    func addPlayerPhoto(game: Game, player: Player) {
        
        let playerPhoto = PlayerPhoto(game: game, player: player)
        
        _ = playerPhoto.then {
            $0.delegate = self.delegate
            self.addSubview(playerPhoto)
            playerPhoto.freeConstraints()
            // Anchors
            $0.bottomAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
            $0.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
