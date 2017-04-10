///
/// Board.swift
///

import Foundation
import GameKit

enum BoardType: String {
    case Highway, City, Tropical
    
    static var all: [String] {
        return [
            BoardType.Highway.rawValue,
            BoardType.City.rawValue,
            BoardType.Tropical.rawValue
        ]
    }
    
    var images: [String] {
        switch self {
        case .Highway:
            return ["building", "airport", "barn", "bicycle", "boat", "bus", "car", "gas station", "rv", "motel", "motorcycle", "police car", "power line", "restaurant", "restroom", "river", "silo", "subway", "telephone", "train", "truck", "animal", "stop sign", "billboard", "speed limit"]
        case .City:
            return ["ambulance", "bank", "bar", "bus", "car", "coffee", "crosswalk", "garbage", "hotel", "hydrant", "laundromat", "mailbox", "manhole", "map", "museum", "newspaper", "park", "parking meter", "police car", "free space", "statue", "stoplight", "taxi", "tourist", "vendor"]
        case .Tropical:
            return ["bathing suit", "beach chair", "beach", "boat", "coconut", "cooler", "flower", "frozen drink", "ice cream", "jet ski", "lei", "lifeguard", "palm tree", "rock", "sandals", "sandcastle", "seagull", "seashell", "sunglasses", "sunscreen", "surfboard", "towel", "umbrella", "waterfall", "free space"]
        }
    }
}

struct Board {
    
    var images = [Int:String]()
    var name: String
    var filled: [Int] = [13]
    var winningCombos = [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12, 13, 14 ,15], [16, 17, 18, 19, 20], [21, 22, 23, 24, 25], [1, 6, 11, 16, 21], [2, 7, 12, 17, 22], [3, 8, 13, 18, 23], [4, 9, 14, 19, 24], [5, 10, 15, 20, 25], [1, 7, 13, 19, 25], [5, 9, 13, 17, 21]]
    //var individualID: Int?
    
    init(boardType: BoardType) {
        self.name = "\(boardType.rawValue) Bingo"
        let _images = shuffle(images: boardType.images)
        for (index, image) in _images.enumerated() {
            let i = index + 1
            self.images[i] = i == 13 ? "free space" : image
        }
    }
    
    func checkForWin() -> Bool {
        for combo in winningCombos {
            let filledList = Set(filled)
            let comboSet = Set(combo)
            let winner = comboSet.isSubset(of: filledList)
            if winner {
                return true
            }
        }
        return false
    }
    
}





func shuffle(images: [String]) -> [String] {
    return GKRandomSource().arrayByShufflingObjects(in: images) as! [String]
}

func freeSpace(images: inout [String]) -> [String] {
    for (index, image) in images.enumerated() {
        if image == "free space" && index != 12 {
            swap(&images[index], &images[12])
        }
    }
    return images
}

