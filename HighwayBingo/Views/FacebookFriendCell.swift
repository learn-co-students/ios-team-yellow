///
/// FacebookFriendCell.swift
///

import UIKit
import Then

class FacebookFriendCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let addButton = UIButton()
    
    weak var delegate: InviteFriendDelegate?
    
    var friend: FacebookUser? {
        didSet {
            guard let friend = friend else { return }
            nameLabel.text = friend.name
        }
    }
    
    static let reuseID = "facebookFriend"
    
    var views: [UIView] {
        return [addButton, nameLabel]
    }
    
    var margins: UILayoutGuide {
        return contentView.layoutMarginsGuide
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        views.forEach { contentView.addSubview($0) }
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        _ = nameLabel.then {
            $0.leftAnchor.constraint(equalTo: margins.leftAnchor).isActive = true
        }
        
        _ = addButton.then {
            $0.setTitle("ADD", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.addTarget(self, action: #selector(self.inviteFriend(_:)), for: UIControlEvents.touchUpInside)
            $0.backgroundColor = .blue
            $0.rightAnchor.constraint(equalTo: margins.rightAnchor).isActive = true
        }
    }
    
    func inviteFriend(_ sender: UIButton!) {
        guard let friend = friend else { return }
        delegate?.invite(friend)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
