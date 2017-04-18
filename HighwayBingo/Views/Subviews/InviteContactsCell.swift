///
/// ContactCell.swift
///

import UIKit

class ContactCell: UITableViewCell {
    
    let nameLabel = UILabel()
    
    static let reuseID = "contact"
    
    var game: Game?
    var contact: Contact? {
        didSet {
            guard let contact = contact else { return }
            nameLabel.text = contact.fullName
        }
    }
    
    var views: [UIView] {
        return [nameLabel]
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        views.forEach { contentView.addSubview($0) }
        views.forEach { $0.freeConstraints() }
        
        _ = nameLabel.then {
            $0.font = UIFont(name: "BelleroseLight", size: 20)
            // Anchors
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
