///
/// Player.swift
///

import SwiftyJSON

struct Player {
    
    var gameIds: [GameID]
    var games = [Game]()
    let id: String
    let kindName: String
    let name: String
    let notifications: [Notification]
    
    init(id: String, from json: JSON) {
        self.gameIds = json["games"].dictionaryValue.map { $0.key }
        self.id = id
        self.name = json["name"].stringValue
        self.kindName = name.firstWord
        let invitations = json["notifications"]["invitations"].dictionaryValue.map(Invitation.init)
        // let verifications = json["notifications"]["verifications"].arrayValue.map(Verification.init)
        self.notifications = invitations
    }
    
    init() {
        self.gameIds = []
        self.id = "n/a"
        self.kindName = "n/a"
        self.name = "n/a"
        self.notifications = []
    }
}

extension Player: CustomStringConvertible {
    var description: String {
        return "Name: \(name), ID: \(id)\nGames: \(games)"
    }
}
