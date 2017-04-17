///
/// Game.swift
///

import SwiftyJSON


typealias AcceptedInvitation = Bool
typealias Participating = [String : AcceptedInvitation]
typealias MovesAway = (String, Int)
typealias Rank = (playerId: String, rankText: String)


struct Game {

    let currentUserIsLeader: Bool
    let gameProgress: GameProgress
    let id: String
    let leaderId: String
    var players = [Player]()
    var participants: Participating
    let boardType: BoardType
    var movesAway: [MovesAway]
    

    var playerIds: [String] {
        return participants.map { $0.key }
    }
    
    enum GameProgress: String {
        case notStarted, inProgress, ended
        
        var status: String {
            switch self {
            case .notStarted:
                return "Status: Not Started"
            case .inProgress:
                return "Status: In Progress"
            case .ended:
                return "Status: Game Over"
            }
        }
    }
    
    init(id: String, json: JSON, userId: String) {
        self.gameProgress = GameProgress(rawValue: json["status"].stringValue)!
        self.id = id
        self.leaderId = json["leader"].stringValue
        self.currentUserIsLeader = userId == leaderId
        self.movesAway = json["movesAway"].dictionaryValue.map({ ($0.key, $0.value.intValue) })
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

typealias PlayerRanker = Game
extension PlayerRanker {
    
    var playersOrderedByRank: [Player] {
        return playerPositions.flatMap({ rank in players.filter({ $0.id == rank.playerId}).first })
    }
    
    var playerPositions: [Rank] {
        let ordered = order(movesAway)
        return rank(ordered)
    }
    
    func order(_ arr: [MovesAway]) -> ([[MovesAway]]) {
        let uniqueValues = Array(Set(arr.map({ $0.1 })))
        let sorted = uniqueValues.sorted()
        return sorted.map({ val in arr.filter({ $0.1 == val }) })
    }
    
    func rank(_ arr: [[MovesAway]]) -> ([Rank]) {
        var ranks = ["1st", "2nd", "3rd", "4th"]
        return arr.flatMap { positions -> [(String, String)] in
            var rank = ranks.removeFirst()
            rank = positions.count > 1 ? "t-" + rank : rank
            return positions.map({ ($0.0, rank) })
        }
    }
}

extension Game: CustomStringConvertible {
    var description: String {
        return "GAME \(id), Players Count: \(participants.count), Is Leader: \(currentUserIsLeader)"
    }
}
