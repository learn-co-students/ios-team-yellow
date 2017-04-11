///
/// Player.swift
///

import SwiftyJSON

struct Player {
    
    var gameIds: [GameID]
    let id: String
    let kindName: String
    let name: String
    let messages: [Message]
    let imageUrl: URL?
    
    init(id: String, from json: JSON) {
        self.gameIds = json["games"].dictionaryValue.map { $0.key }
        self.id = id
        self.imageUrl = URL(string: json["imageUrl"].stringValue)
        self.name = json["name"].stringValue
        self.kindName = name.firstWord
        let invitations = json["messages"]["invitations"].dictionaryValue.map(Invitation.init)
        // let verifications = json["messages"]["verifications"].arrayValue.map(Verification.init)
        self.messages = invitations
    }
}

extension Player: CustomStringConvertible {
    
    var description: String {
        return "Name: \(kindName), ID: \(id)\n\tGames count: \(gameIds.count)\n\tMessages count: \(messages.count)"
    }
    
    init() {
        self.gameIds = []
        self.id = "n/a"
        self.kindName = "n/a"
        self.name = "n/a"
        self.messages = []
        self.imageUrl = nil
    }
}
