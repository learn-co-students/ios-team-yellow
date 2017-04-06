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
typealias Params = [String : String]

extension FIRDatabaseReference {
    var invitations: FIRDatabaseReference {
        return child("notifications").child("invitations")
    }
}

final class FirebaseManager {
    
    static let shared = FirebaseManager()
    private init() {}
    
    static private let db = FIRDatabase.database().reference()
    
    private let storage = FIRStorage.storage(url: "gs://highwaybingo.appspot.com").reference()
    
    private let userId = UserDefaults.standard.string(forKey: "userId")!
    
    private enum Child {
        static var users: FIRDatabaseReference { return db.child("users") }
        static var games: FIRDatabaseReference { return db.child("games") }
    }
    
    private var currentUserNode: FIRDatabaseReference {
        return Child.users.child(userId)
    }
    
    // Creates a game with the Current User as the Leader, and adds the Game to the User in Firebase
    //
    func createGame() -> GameID {
        let game = Child.games.childByAutoId()
        game.setValue(["leader" : userId])
        let gameId = game.key
        currentUserNode.child("games").updateChildValues([gameId : true])
        return gameId
    }
    
    // Creates a game with the Current User as the Leader, and adds the Game to the User in Firebase
    //
    func createOrUpdate(_ user: FIRUser) {
        let name = user.displayName!
        currentUserNode.updateChildValues(["name": name])
        guard let imageUrl = user.photoURL else { return }
        let location = storage.child("images/\(userId).jpg")
        getImage(url: imageUrl) { image in
            guard let image = image else { return }
            self.saveImage(image, at: location) { imageUrl in
                guard let imageUrl = imageUrl else { return }
                self.currentUserNode.updateChildValues(["imageUrl": imageUrl])
            }
        }
    }

    // The Crux of App Setup
    // Fetches the User based off the userId in UserDefaults, then calls fetchGames, which in turn calls fetchPlayers
    // When this data is collected the HomeVC can be presented
    //
    func fetchCurrentUser(handler: @escaping (Player) -> ()) {
        currentUserNode.observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value)
            var player = Player(id: self.userId, from: json)
            self.fetchGames(player.gameIds) { games in
                player.games = games
                handler(player)
            }
        }) { (error) in
            print("FirebaseManager -> error fetching current user\n\t\(error.localizedDescription)")
        }
    }
    
    func fetchGames(_ gameIds: [GameID], handler: @escaping ([Game]) -> ()) {
        Child.games.observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value).dictionaryValue
            let filtered = json.filter({ gameIds.contains($0.key) })
            let games = filtered.map { Game(id: $0.key, json: $0.value) }
            self.fetchPlayersFor(games) { gamesWithPlayers in handler(gamesWithPlayers) }
        }) { (error) in
            print("FirebaseManager -> error fetching games\n\t\(error.localizedDescription)")
        }
    }
    
    func fetchPlayersFor(_ games: [Game], handler: @escaping ([Game]) -> ()) {
        let playerIds = Set(games.flatMap({ $0.playerIds }))
        Child.users.observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value).dictionaryValue
            let players = json.filter({ playerIds.contains($0.key) }).map({ Player(id: $0.key, from: $0.value) })
            let gamesWithPlayers = games.map { $0.update(with: players) }
            handler(gamesWithPlayers)
        }) { (error) in
            print("FirebaseManager -> error fetching games\n\t\(error.localizedDescription)")
        }
    }

    // Saves an image in Firebase Storage, we'll use it for Player and Game Cell images
    //
    private func saveImage(_ image: UIImage, at location: FIRStorageReference, handler: @escaping (String?) -> ()) {
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { handler(nil); return }
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        location.put(data, metadata: metaData) { (metadata, error) in
            guard let url = metadata?.downloadURL() else { handler(nil); return }
            let urlString = String(describing: url)
            handler(urlString)
        }
    }

    // Sends an invitation to a group of User, each will be saved under users/<userId>/notifications/invitations/
    //
    func sendInvitations(for gameId: GameID, to users: [FacebookUser]) {
        users.forEach { Child.users.child($0.id).invitations.updateChildValues([gameId: true]) }
    }
}


func getImage(url: URL, handler: @escaping (UIImage?) -> ()) {
    Alamofire.request(url).responseImage { response in
        let image = response.result.value
        handler(image)
    }
}
