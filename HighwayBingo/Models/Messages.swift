///
/// Messages.swift
///

import SwiftyJSON

protocol Message {
    var displayText: String { get }
    var id: String { get }
    var from: String { get }
}

struct Invitation: Message {

    let id: String
    let gameTitle: String
    let from: String
    
    var displayText: String {
        return "\(from) invited you to play \(gameTitle)"
    }
    
    init(_ from: (key: String, value: JSON)) {
        self.id = from.key
        self.gameTitle = from.value["name"].stringValue
        self.from = from.value["from"].stringValue
    }
}

struct Verification: Message {
    
    let id: String
    let imageName: String
    let from: String
    
    var displayText: String {
        return "\(from) asked you to verify \(imageName)"
    }
    
    init(_ from: (key: String, value: JSON)) {
        self.id = from.key
        self.imageName = from.value["imageName"].stringValue
        self.from = from.value["from"].stringValue
    }
}
