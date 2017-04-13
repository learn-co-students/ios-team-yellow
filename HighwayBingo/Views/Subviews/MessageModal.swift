///
/// MessageModal.swift
///

import UIKit

class MessageModal: UIView {
    
    var message: Message
    let acceptButton = UIButton()
    let denyButton = UIButton()
    let displayHeadingLabel = UILabel()
    let gameLabel = UILabel()
    var isInvitation = true
    let verificationImageView = UIImageView()
    
    var views: [UIView] {
        return [acceptButton, denyButton, displayHeadingLabel, gameLabel, verificationImageView]
    }
    
    init?(message: Message) {
        self.message = message
        super.init(frame: .zero)
        
        views.forEach(self.addSubview)
        views.forEach { $0.freeConstraints() }
        
        if let invitation = message as? Invitation {

            _ = gameLabel.then {
                $0.font = UIFont(name: "Fabian", size: 60)
                $0.text = invitation.gameTitle
                $0.numberOfLines = 0
                $0.textAlignment = .center
                // Anchors
                $0.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
                $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            }
            
        } else if let verification = message as? Verification {
            
            isInvitation = false
            
            _ = verificationImageView.then {
                $0.kfSetPlayerImage(with: verification.imageUrl)
                // Anchors
                $0.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.75).isActive = true
                $0.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.75).isActive = true
                $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            }
            
        } else { return nil }
        
        let gameLabelOrVerificationImageView = isInvitation ? gameLabel : verificationImageView
        
        _ = displayHeadingLabel.then {
            $0.text = message.displayHeading
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.font = UIFont(name: "BelleroseLight", size: 20)
            // Anchors
            $0.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: gameLabelOrVerificationImageView.topAnchor, constant: -30).isActive = true
        }
        
        _ = acceptButton.then {
            $0.setTitle("Accept", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.white, for: .disabled)
            $0.titleLabel?.font = UIFont(name: "BelleroseLight", size: 20)
            // Border
            $0.purpleBorder()
            // Accept Invitation
            $0.addTarget(self, action: #selector(self.accept(_:)), for: UIControlEvents.touchUpInside)
            // Anchors
            $0.topAnchor.constraint(equalTo: gameLabelOrVerificationImageView.bottomAnchor, constant: 30).isActive = true
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
            $0.addTarget(self, action: #selector(self.deny(_:)), for: UIControlEvents.touchUpInside)
            // Anchors
            $0.topAnchor.constraint(equalTo: gameLabelOrVerificationImageView.bottomAnchor, constant: 30).isActive = true
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 75).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 100).isActive = true
        }
    }
    
    func accept(_ sender: UIButton!) {
        if isInvitation {
            FirebaseManager.shared.acceptInvitation(messageId: message.id, gameId: message.gameId)
        } else {
            FirebaseManager.shared.acceptVerification(message: message)
        }
        dismissMessage(sender)
    }
    
    func deny(_ sender: UIButton!) {
        if isInvitation {
            FirebaseManager.shared.denyInvitation(gameId: message.gameId, messageId: message.id)
        } else {
            FirebaseManager.shared.denyVerification(messageId: message.id)
        }
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
