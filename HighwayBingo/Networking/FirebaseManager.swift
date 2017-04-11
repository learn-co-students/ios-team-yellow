///
/// FirebaseManager.swift
///

import Alamofire
import AlamofireImage
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Foundation
import SwiftyJSON


typealias Accepted = Bool
typealias GameID = String
typealias Params = [String : Any]


extension FIRDatabaseReference {
    var invitations: FIRDatabaseReference {
        return child("messages").child("invitations")
    }
    
    var verifications: FIRDatabaseReference {
        return child("messages").child("verifications")
    }
}


final class FirebaseManager {
    
    static let shared = FirebaseManager()
    private init() {}
    
    static private let db = FIRDatabase.database().reference()
    
    private let storage = FIRStorage.storage(url: Secrets.Firebase.storageUrl).reference()
    
    private let currentUserId = UserDefaults.standard.string(forKey: "userId")!
    
    private enum Child {
        static var users: FIRDatabaseReference { return db.child("users") }
        static var games: FIRDatabaseReference { return db.child("games") }
        static var boards: FIRDatabaseReference { return db.child("boards") }
    }
    
    private var currentUserNode: FIRDatabaseReference {
        return Child.users.child(currentUserId)
    }
    
    
    //// APP SETUP ////
    
    // Fetches user based off id in UserDefaults, fetches games and players
    func fetchCurrentUser(handler: @escaping (Player) -> ()) {
        currentUserNode.observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value)
            var player = Player(id: self.currentUserId, from: json)
            self.fetchGames(player.gameIds) { games in
                DataStore.shared.currentUserGames = games
                handler(player)
            }
        }) { (error) in
            print("FirebaseManager -> error fetching current user\n\t\(error.localizedDescription)")
        }
    }
    
    func fetchGames(_ gameIds: [GameID], handler: @escaping ([Game]) -> ()) {
        Child.games.observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value).dictionaryValue
            let games = json.filter({ gameIds.contains($0.key) })
                .map { Game(id: $0.key, json: $0.value, userId: self.currentUserId) }
            self.fetchPlayersFor(games) { gamesWithPlayers in handler(gamesWithPlayers) }
        }) { (error) in
            print("FirebaseManager -> error fetching games\n\t\(error.localizedDescription)")
        }
    }
    
    func fetchPlayersFor(_ games: [Game], handler: @escaping ([Game]) -> ()) {
        let playerIds = Set(games.flatMap({ $0.participants.map({ $0.key }) }))
        Child.users.observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value).dictionaryValue
            let players = json.filter({ playerIds.contains($0.key) })
                .map({ Player(id: $0.key, from: $0.value) })
            let gamesWithPlayers = games.map { $0.update(with: players) }
            handler(gamesWithPlayers)
        }) { (error) in
            print("FirebaseManager -> error fetching games\n\t\(error.localizedDescription)")
        }
    }
    
    
    //// USER ////
    
    // Creates a user and looks for their image
    func createOrUpdate(_ user: FIRUser) {
        let name = user.displayName!
        currentUserNode.updateChildValues(["name": name])
        guard let imageUrl = user.photoURL else { return }
        let location = storage.child("images/\(currentUserId).jpg")
        getImage(url: imageUrl) { image in
            guard let image = image else { return }
            self.saveImage(image, at: location) { imageUrl in
                guard let url = imageUrl else { return }
                self.currentUserNode.updateChildValues(["imageUrl" : String(describing: url)])
            }
        }
    }
    
    
    //// GAME ////
    
    // Creates a game with a leader and invited participants
    func createGame(_ boardType: BoardType, participants: [FacebookUser]) -> GameID {
        let params = gameParams(boardType: boardType.rawValue, participants: participants)
        let game = Child.games.childByAutoId()
        game.setValue(params)
        let gameId = game.key
        currentUserNode.child("games").updateChildValues([gameId : true])
        participants.forEach { Child.users.child($0.id).child("games").updateChildValues([gameId : false]) }
        return gameId
    }
    
    func gameParams(boardType: String, participants: [FacebookUser]) -> Params {
        var participantsDict = participants.reduce(Params()) { $0.0 += [$0.1.id : false] }
        participantsDict[currentUserId] = true
        return [
            "boardType" : boardType,
            "leader" : currentUserId,
            "status" : Game.GameProgress.notStarted.rawValue,
            "participants": participantsDict
        ]
    }
    
    func incrementGameStatus(_ game: Game) {
        switch game.gameProgress {
        case Game.GameProgress.notStarted:
            Child.games.child(game.id).updateChildValues(["status" : Game.GameProgress.inProgress.rawValue])
        default:
            Child.games.child(game.id).updateChildValues(["status" : Game.GameProgress.ended.rawValue])
        }
    }
    
    func removeGame(_ gameId: GameID, for userId: String) {
        Child.users.child(userId).invitations.child(gameId).removeValue()
        Child.users.child(userId).child("games").child(gameId).removeValue()
        Child.games.child(gameId).child("participants").child(userId).removeValue()
    }
    
    // Increment game status and remove non-participating users
    func start(game: Game) {
        let images = getBoardImages(game: game)
        let id = game.id
        game.participants.forEach { (userId, accepted) in
            if accepted {
                Child.boards.child(id).child(userId).setValue(images)
            } else {
                removeGame(id, for: userId)
            }
        }
        incrementGameStatus(game)
    }
    
    
    //// BOARD ////
    
    func getBoardImages(game: Game) -> [String:String] {
        let boardType = game.boardType
        let board = Board(boardType: boardType)
        let images = board.images
        var convertedImages = [String:String]()
        images.forEach { convertedImages[String($0.0)] = $0.1 }
        return convertedImages
    }
    
    
    func getBoard(for game: Game, userid: String, handler: @escaping (Board?) -> ()) {
        let boardType = game.boardType
        Child.boards.child(game.id).child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value).arrayValue
            let board = Board(boardType: boardType, images: json)
            handler(board)
        }) { (error) in
            print("FirebaseManager -> error fetching boards\n\t\(error.localizedDescription)")
        }
    }
    
    func getBoardID(for game: Game, userid: String, handler: @escaping (String) -> ()) {
        let boardType = game.boardType
        Child.boards.child(game.id).child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
            let id = JSON(snapshot.key).stringValue
            handler(id)
        }) { (error) in
            print("FirebaseManager -> error fetching boards\n\t\(error.localizedDescription)")
        }
    }
    
    
    //// IMAGES ////
    
    // Updates the image url in Firebase Database
    func updateImage(imageURL: URL, game: Game, userid: String, index: String) {
        Child.boards.child(game.id).child(userid).updateChildValues([index : String(describing: imageURL)])
    }
    
    // Retrieves the name of the image
    func getBoardImage(game: Game, userid: String, index: String, completion: @escaping (String) -> ()) {
        Child.boards.child(game.id).child(userid).child(index).observeSingleEvent(of: .value, with: { (snapshot) in
            let imageName = snapshot.value as! String
            completion(imageName)
        })
    }
    
    // Downloads the image from a url
    func downloadImage(url: String, completion: @escaping (UIImage) -> ()) {
        let url = URL(string: url)
        let session = URLSession.shared
        if let url = url {
            let dataTask = session.dataTask(with: url) { (data, response, error) in
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        completion(image)
                    }
                }
            }
            dataTask.resume()
        }
    }
    

    func addLastPic(imageURL: URL, game: Game, userid: String) {
        Child.games.child(game.id).child("participants").child(userid).child("last pic").setValue(String(describing: imageURL))
    }
    
    func getLastPic(game: Game, userid: String, completion: @escaping (String) -> ()) {
        Child.games.child(game.id).child("participants").child(userid).child("last pic").observeSingleEvent(of: .value, with: { (snapshot) in
            let imageName = snapshot.value as? String ?? ""
            completion(imageName)
        })
    }

    
    

    


    //// INVITATIONS ////
    
    func acceptInvitation(gameId: GameID) {
        currentUserNode.invitations.child(gameId).removeValue()
        Child.games.child(gameId).child("participants").updateChildValues([currentUserId : true])
        currentUserNode.child("games").updateChildValues([gameId : true])
    }
    
    func denyInvitation(gameId: GameID) {
        removeGame(gameId, for: currentUserId)
    }
    
    // Updates game statuses to true or discards them based on response
    func respondToInvitation(id: GameID, accept: Accepted) {
        accept ? acceptInvitation(gameId: id) : denyInvitation(gameId: id)
    }
    
    // Sends an invitation to a group of users
    func sendInvitations(to users: [FacebookUser], from: String, for gameId: GameID, boardType: BoardType) {
        let params = ["from" : from, "title": boardType.rawValue]
        users.forEach { Child.users.child($0.id).invitations.child(gameId).updateChildValues(params) }
    }
    
    ///VERIFICATIONS///
    
    func sendVerification(to users: [String], from: String, game: Game, imageURL: URL, imageName: String) {
        let params = ["from":from, "imageName":imageName, "imageURL":String(describing: imageURL)]
        users.forEach {Child.users.child($0).verifications.child(game.id).updateChildValues(params)}
    }
}


private typealias FirebaseStorageManager = FirebaseManager
extension FirebaseStorageManager {
    
    // Saves player and game images in Firebase Storage
     func saveImage(_ image: UIImage, at location: FIRStorageReference, handler: @escaping (URL?) -> ()) {
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { handler(nil); return }
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        location.put(data, metadata: metaData) { (metadata, error) in
            let url = metadata?.downloadURL()
            handler(url)
        }
    }
}


func getImage(url: URL, handler: @escaping (UIImage?) -> ()) {
    Alamofire.request(url).responseImage { response in
        let image = response.result.value
        handler(image)
    }
}
