///
/// Board.swift
///

import Foundation

class Board {
    
    var images: [String]
    var name: String
    var boardID: Int
    var individualID: Int?
    
    init(images: [String], name: String, boardID: Int) {
        self.images = images
        self.name = name
        self.boardID = boardID
    }
}
