///
/// Game.swift
///

import SwiftyJSON

struct Game {
    
    typealias Participating = [String : Accepted]
    
    let gameProgress: GameProgress
    let id: String
    let leaderId: String
    //let board: Board?
    var players = [Player]()
    var participants: Participating
    let title: String
    
    var playerIds: [String] {
        return participants.map { $0.key }
    }
    
    enum GameProgress: String {
        case notStarted, inProgress, ended
    }
    
    init(id: String, json: JSON) {
        self.gameProgress = GameProgress(rawValue: json["status"].stringValue)!
        self.id = id
        self.leaderId = json["leader"].stringValue
        self.participants = json["participants"].dictionaryValue.reduce(Participating()) { (dict, invitation) in
            dict += [invitation.key : invitation.value.boolValue]
        }
        self.participants[leaderId] = true
        self.title = json["title"].stringValue
    }
}

extension Game {
    func update(with players: [Player]) -> Game {
        var gameCopy = self
        gameCopy.players = players.filter { playerIds.contains($0.id) }
        return gameCopy
    }
}

extension Game: CustomStringConvertible {
    var description: String {
        return "GAME \(id)\n\tPlayers (:invitation): \(participants)"
    }
}
