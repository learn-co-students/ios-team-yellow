///
/// FacebookFriendCell.swift
///

import UIKit
import Then

class FacebookFriendCell: UITableViewCell {
    
    let addButton = UIButton()
    let nameLabel = UILabel()
    let friendImageView = UIImageView()
    
    static let reuseID = "facebookFriend"
    
    weak var delegate: InviteFriendDelegate?
    
    var friend: FacebookUser? {
        didSet {
            guard let friend = friend else { return }
            nameLabel.text = friend.name
            if let url = friend.imageUrl { friendImageView.kfSetPlayerImageRound(with: url, diameter: 40) }
        }
    }
    
    var views: [UIView] {
        return [addButton, friendImageView, nameLabel]
    }
    
    var margins: UILayoutGuide {
        return contentView.layoutMarginsGuide
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        views.forEach { contentView.addSubview($0) }
        views.forEach { $0.freeConstraints() }
        
        _ = friendImageView.then {
            // Anchors
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        _ = nameLabel.then {
            $0.font = UIFont(name: "BelleroseLight", size: 20)
            // Anchors
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 5).isActive = true
        }
        
        _ = addButton.then {
            $0.setTitle("Add", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = UIFont(name: "BelleroseLight", size: 20)
            // Border
            $0.purpleBorder()
            // Call delegate method when tapped
            $0.addTarget(self, action: #selector(self.inviteFriend(_:)), for: UIControlEvents.touchUpInside)
            // Anchors
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 50).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        }
    }
    
    func inviteFriend(_ sender: UIButton!) {
        guard let friend = friend else { return }
        delegate?.invite(friend)
        delegate?.limitFriends()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
