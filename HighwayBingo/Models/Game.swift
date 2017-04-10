///
/// Game.swift
///

import SwiftyJSON

struct Game {
    
    typealias Participating = [String : Accepted]
    
    let currentUserIsLeader: Bool
    let gameProgress: GameProgress
    let id: String
    let leaderId: String
    var players = [Player]()
    var participants: Participating
    let boardType: BoardType
    var boards = [String:Board]()
    
    var playerIds: [String] {
        return participants.map { $0.key }
    }
    
    enum GameProgress: String {
        case notStarted, inProgress, ended
    }
    
    init(id: String, json: JSON, userId: String) {
        self.gameProgress = GameProgress(rawValue: json["status"].stringValue)!
        self.id = id
        self.leaderId = json["leader"].stringValue
        self.currentUserIsLeader = userId == leaderId
        self.participants = json["participants"].dictionaryValue.reduce(Participating()) { (dict, invitation) in
            dict += [invitation.key : invitation.value.boolValue]
        }
        self.participants[leaderId] = true
        self.boardType = BoardType(rawValue: json["boardType"].stringValue)!
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
        return "GAME \(id), Players Count: \(participants.count), Is Leader: \(currentUserIsLeader)"
    }
}
