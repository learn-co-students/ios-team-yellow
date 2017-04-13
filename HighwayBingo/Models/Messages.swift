///
/// Messages.swift
///

import SwiftyJSON

protocol Message {
    var displayHeading: String { get }
    var id: String { get }
    var fromPlayerName: String { get }
    var gameId: String { get }
}

struct Invitation: Message {

    let id: String
    let gameId: String
    let gameTitle: String
    let fromPlayerName: String
    
    var displayHeading: String {
        return "\(fromPlayerName) invited you to play"
    }
    
    init(_ data: (key: String, value: JSON)) {
        self.id = data.key
        self.gameId = data.value["gameId"].stringValue
        self.gameTitle = "\(data.value["title"].stringValue) Bingo"
        self.fromPlayerName = data.value["from"].stringValue
    }
}

struct Verification: Message {
    
    let id: String
    let imageName: String
    let imageUrl: URL
    let imageIndex: String
    let gameId: String
    let fromPlayerId: String
    let fromPlayerName: String
    
    var displayHeading: String {
        return "\(fromPlayerName) asked you to verify the image below is a \(imageName)"
    }
    
    init?(_ data: (key: String, value: JSON)) {
        self.id = data.key
        self.fromPlayerId = data.value["fromPlayerId"].stringValue
        self.fromPlayerName = data.value["fromPlayerName"].stringValue
        self.gameId = data.value["gameId"].stringValue
        self.imageIndex = data.value["imageIndex"].stringValue
        self.imageName = data.value["imageName"].stringValue
        guard let url = URL(string: data.value["imageUrl"].stringValue) else { return nil }
        self.imageUrl = url
    }
}
