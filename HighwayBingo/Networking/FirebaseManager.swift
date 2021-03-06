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
        static var reported: FIRDatabaseReference { return db.child("reported") }
    }
    
    private var currentUserNode: FIRDatabaseReference {
        return Child.users.child(currentUserId)
    }
    
    
    
    // please make these class functions 
    
    
    
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
    
    func refreshFirebase(completion: @escaping (Bool) -> ()) {
        Child.games.observe(.value, with: { (snapshot) in
                completion(true)

        })
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
    
    func numberAwayFromWin(_ number: Int, gameId: GameID) {
        Child.games.child(gameId).child("movesAway").updateChildValues([currentUserId : number])
    }
    
    func removeGame(_ gameId: GameID, for userId: String) {
        Child.users.child(userId).invitations.child(gameId).removeValue()
        Child.users.child(userId).child("games").child(gameId).removeValue()
        Child.games.child(gameId).child("participants").child(userId).removeValue()
    }
    
    func leave(game: Game, handler: @escaping () -> ()) {
        let gameId = game.id
        //Delete Game from Database and Storage if Last Participant Leaves
        if game.participants.count == 1 {
            Child.games.child(gameId).removeValue()
            for player in game.players {
                for image in game.boardType.images {
                    storage.child("images/\(gameId)/\(player.id)/\(image.capitalized).jpg").delete(completion: { (error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                    })
                }
            }
        }
        switch game.gameProgress {
        case .notStarted:
            currentUserNode.invitations.child(gameId).removeValue()
            fallthrough
        //Removes Game/Board from Database
        default:
            Child.boards.child(gameId).child(currentUserId).removeValue()
            Child.games.child(gameId).child("participants").child(currentUserId).removeValue()
            currentUserNode.child("games").child(gameId).removeValue(completionBlock: { _ in
                handler()
            })
        }
    }
    
    // Increment game status and remove non-participating users
    func start(game: Game) {
        let images = getBoardImages(game: game)
        let id = game.id
        game.participants.forEach { (userId, accepted) in
            if accepted {
                // Set board images
                Child.boards.child(id).child(userId).setValue(images)
                // Set moves away
                Child.games.child(id).child("movesAway").updateChildValues([userId : 4])
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
    
    func acceptInvitation(messageId: String, gameId: GameID) {
        currentUserNode.invitations.child(messageId).removeValue()
        Child.games.child(gameId).child("participants").updateChildValues([currentUserId : true])
        currentUserNode.child("games").updateChildValues([gameId : true])
    }
    
    func denyInvitation(gameId: GameID, messageId: String) {
        currentUserNode.invitations.child(messageId).removeValue()
        removeGame(gameId, for: currentUserId)
    }
    
    // Sends an invitation to a group of users
    func sendInvitations(to users: [FacebookUser], from: String, for gameId: GameID, boardType: BoardType) {
        let uuid = UUID().uuidString
        let params = [
            "boardType": boardType.rawValue,
            "from" : from,
            "gameId" : gameId
        ]
        users.forEach { Child.users.child($0.id).invitations.child(uuid).updateChildValues(params) }
    }
    
    ///VERIFICATIONS///
    
    func sendVerification(to userIds: [String], from: Player, game: Game, imageURL: URL, imageName: String, imageIndex: String) {
        let uuid = UUID().uuidString
        let params = [
            "fromPlayerId" : from.id,
            "fromPlayerName" : from.kindName,
            "gameId" : game.id,
            "imageName" : imageName,
            "imageUrl": String(describing: imageURL),
            "imageIndex": imageIndex
        ]
        userIds.forEach { Child.users.child($0).verifications.child(uuid).updateChildValues(params) }
    }
    
    func acceptVerification(message: Message) {
        guard
            let ver = message as? Verification,
            let game = DataStore.shared.currentUserGames.filter({ $0.id == ver.gameId }).first
        else { return }
        // Replace imageName with imageUrl for player
        Child.boards.child(ver.gameId).child(ver.fromPlayerId).updateChildValues([ver.imageIndex : String(describing: ver.imageUrl)])
        // Remove verification message all users
        game.playerIds.forEach { Child.users.child($0).verifications.child(ver.id).removeValue() }
    }
    
    func denyVerification(messageId: String) {
        currentUserNode.verifications.child(messageId).removeValue()
    }
    
    ///REPORTED USERS///
    
    func reportUser(reportedUser: String, imageURL: String) {
        Child.reported.child(currentUserId).setValue(["\(reportedUser)" : "\(imageURL)"])
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
