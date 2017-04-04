///
/// FacebookFriendCell.swift
///

import UIKit
import Then

class FacebookFriendCell: UITableViewCell {
    
    let nameLabel = UILabel()
    
    var friend: FacebookUser? {
        didSet {
            guard let friend = friend else { return }
            nameLabel.text = friend.name
        }
    }
    
    static let reuseID = "facebookFriend"
    
    var views: [UIView] {
        return [nameLabel]
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
