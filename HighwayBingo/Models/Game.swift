///
/// Game.swift
///

import SwiftyJSON

struct Game {
    
    typealias AcceptedInvitation = Bool
    typealias Participating = [String : AcceptedInvitation]
    
    let currentUserIsLeader: Bool
    let gameProgress: GameProgress
    let id: String
    let leaderId: String
    var players = [Player]()
    var participants: Participating
    let boardType: BoardType
    var boards = [String:Board]()
    
    //PlayerID:NumberFromWin
    var places = [String:Int]()
    
    
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
    
    //Game Rank Functions
    
    mutating func updatePlace(players: [Player]) {
        for player in players {
            places.updateValue(player.numberFromWin, forKey: player.id)
        }
    }
    
    func getPlaces(players: [Player], places: [String:Int]) {
        let newPlaces = places.sorted {$0.1 < $1.1}
        print(newPlaces)
        for (index, place) in newPlaces.enumerated() {
            for player in players {
                if player.id == place.key {
                    player.place[id] = index + 1
                    print("\(player.id): \(player.place)")
                }
            }
        }
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
