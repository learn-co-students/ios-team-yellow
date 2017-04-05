///
/// Player.swift
///

import SwiftyJSON

struct Player {
    
    let name: String
    let kindName: String
    var gameIds: [GameID] = []
    var games = [Game]()
    let id: String
    
    init(id: String, from json: JSON) {
        self.name = json["name"].stringValue
        self.kindName = name.firstWord
        self.gameIds = json["games"].dictionaryValue.map { $0.key }
        self.id = id
    }
    
    init() {
        self.name = "n/a"
        self.kindName = "n/a"
        self.id = "n/a"
    }
}

extension Player: CustomStringConvertible {
    var description: String {
        return "Name: \(name), ID: \(id)\nGames: \(games)"
    }
}
