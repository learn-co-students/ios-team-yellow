///
/// PlayerCell.swift
///

import UIKit
import Then

class PlayerCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let playerImageView = UIImageView()
    
    let screenSize = UIScreen.main.bounds
    
    static let reuseID = "player"
    
    var game: Game?
    var player: Player? {
        didSet {
            guard let player = player else { return }
            nameLabel.text = player.kindName
            guard let url = player.imageUrl else { return }
            playerImageView.kfSetPlayerImage(with: url, diameter: 80)
        }
    }
    
    var views: [UIView] {
        return [nameLabel, playerImageView]
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        views.forEach { contentView.addSubview($0) }
        views.forEach { $0.freeConstraints() }
        
        
        _ = nameLabel.then {
            $0.textAlignment = .center
            // Anchors
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: screenSize.width * 0.15).isActive = true
            $0.widthAnchor.constraint(equalToConstant: screenSize.width * 0.25).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        

        
        _ = playerImageView.then {
            // Anchors
            $0.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -10).isActive = true
            $0.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
