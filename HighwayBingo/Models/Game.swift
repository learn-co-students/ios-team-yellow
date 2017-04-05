///
/// Game.swift
///

import SwiftyJSON

struct Game {
    
    let id: String
    //let board: Board?
    var players = [Player]()
    let playerIds: [String]
    
    init(id: String, json: JSON) {
        self.playerIds = json.dictionaryValue.map { $0.value.stringValue }
        self.id = id
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
        return "ID: \(id), PlayerIDs: \(playerIds)"
    }
}
