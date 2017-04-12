///
/// MessageModal.swift
///

import UIKit

class MessageModal: UIView {
    
    let message: Message
    
    let acceptButton = UIButton()
    let denyButton = UIButton()
    let displayHeadingLabel = UILabel()
    let gameLabel = UILabel()
    
    var views: [UIView] {
        return [acceptButton, denyButton, displayHeadingLabel, gameLabel]
    }
    
    init(message: Message) {
        self.message = message
        super.init(frame: .zero)
        
        views.forEach(self.addSubview)
        views.forEach { $0.freeConstraints() }
        
        _ = gameLabel.then {
            $0.font = UIFont(name: "Fabian", size: 60)
            $0.text = message.gameTitle
            $0.numberOfLines = 0
            $0.textAlignment = .center
            // Anchors
            $0.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }
        
        _ = displayHeadingLabel.then {
            $0.text = message.displayHeading
            $0.textAlignment = .center
            $0.font = UIFont(name: "BelleroseLight", size: 20)
            // Anchors
            $0.bottomAnchor.constraint(equalTo: gameLabel.topAnchor, constant: -30).isActive = true
            $0.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        }
        
        _ = acceptButton.then {
            $0.setTitle("Accept", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.white, for: .disabled)
            $0.titleLabel?.font = UIFont(name: "BelleroseLight", size: 20)
            // Border
            $0.purpleBorder()
            // Accept Invitation
            $0.addTarget(self, action: #selector(self.acceptInvitation(_:)), for: UIControlEvents.touchUpInside)
            // Anchors
            $0.topAnchor.constraint(equalTo: gameLabel.bottomAnchor, constant: 30).isActive = true
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -75).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 100).isActive = true
        }
        
        _ = denyButton.then {
            $0.setTitle("Deny", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.white, for: .disabled)
            $0.titleLabel?.font = UIFont(name: "BelleroseLight", size: 20)
            // Border
            $0.purpleBorder()
            // Deny Invitation
            $0.addTarget(self, action: #selector(self.denyInvitation(_:)), for: UIControlEvents.touchUpInside)
            // Anchors
            $0.topAnchor.constraint(equalTo: gameLabel.bottomAnchor, constant: 30).isActive = true
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 75).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 100).isActive = true
        }
    }
    
    func acceptInvitation(_ sender: UIButton!) {
        FirebaseManager.shared.respondToInvitation(id: message.id, accept: true)
        dismissMessage(sender)
    }
    
    func denyInvitation(_ sender: UIButton!) {
        FirebaseManager.shared.respondToInvitation(id: message.id, accept: false)
        dismissMessage(sender)
    }
    
    func dismissMessage(_ sender: UIButton) {
        sender.isEnabled = false
        sender.backgroundColor = UIColor(red:0.76, green:0.14, blue:1.00, alpha:1.0)
        UIView.animate(
            withDuration: 0.3,
            animations: { self.alpha = 0.0 },
            completion: { (value: Bool) in self.removeFromSuperview() }
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
