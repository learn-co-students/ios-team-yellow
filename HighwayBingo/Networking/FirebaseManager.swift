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

extension FIRDatabaseReference {
    var invitations: FIRDatabaseReference {
        return child("notifications").child("invitations")
    }
}

final class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    static private let db = FIRDatabase.database().reference()
    
    private let storage = FIRStorage.storage(url: "gs://highwaybingo.appspot.com").reference()
    
    private let userId = UserDefaults.standard.string(forKey: "userId")!
    
    enum Child {
        static var users: FIRDatabaseReference { return db.child("users") }
        static var games: FIRDatabaseReference { return db.child("games") }
    }
    
    private var currentUserNode: FIRDatabaseReference {
        return Child.users.child(userId)
    }
    
    private init() {}
  
    func createOrUpdate(_ user: FIRUser) {
        let name = user.displayName ?? "Anonymous"
        let params = ["name":name]
        
        if let imageUrl = user.photoURL {
            getPhoto(url: imageUrl) { image in
                if let image = image {
                    let location = self.storage.child("images/\(self.userId).jpg")
                    self.save(image, at: location, params: params)
                    return
                }
            }
        }
        currentUserNode.setValue(params)
    }
    
    func addGameToCurrentUser(gameId: GameID) {
        currentUserNode.child("games").updateChildValues([gameId:true])
    }
    
    private func save(_ image: UIImage, at location: FIRStorageReference, params: [String : String]) {
        guard let data = UIImageJPEGRepresentation(image, 0.8) else {
            currentUserNode.setValue(userId)
            return
        }
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        
        location.put(data, metadata: metaData) { (metadata, error) in
            if let imageUrl = metadata?.downloadURL() {
                let paramsWithImage = params += ["imageUrl" : String(describing: imageUrl)]
                self.currentUserNode.setValue(paramsWithImage)
            } else {
                print("FirebaseManager -> error saving photo")
                self.currentUserNode.setValue(params)
            }
        }
    }
    
    func createGame() -> GameID {
        let game = Child.games.childByAutoId()
        game.setValue(["leader":userId])
        let gameId = game.key
        addGameToCurrentUser(gameId: gameId)
        return gameId
    }
    
    func sendInvitations(for gameId: GameID, to users: [FacebookUser]) {
        let userIds = users.map { $0.id }
        userIds.forEach { id in
            Child.users.child(id).invitations.updateChildValues([gameId: true])
        }
    }
    
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
            self.fetchPlayers(for: games) { gamesWithPlayers in
                handler(gamesWithPlayers)
            }
        }) { (error) in
            print("FirebaseManager -> error fetching games\n\t\(error.localizedDescription)")
        }
    }
    
    func fetchPlayers(for games: [Game], handler: @escaping ([Game]) -> ()) {
        let playerIds = Set(games.flatMap({ $0.playerIds }))
        Child.users.observeSingleEvent(of: .value, with: { (snapshot) in
            let json = JSON(snapshot.value).dictionaryValue
            let filtered = json.filter({ playerIds.contains($0.key) })
            let players = filtered.map { Player(id: $0.key, from: $0.value) }
            let gamesWithPlayers = games.map { $0.update(with: players) }
            handler(gamesWithPlayers)
        }) { (error) in
            print("FirebaseManager -> error fetching games\n\t\(error.localizedDescription)")
        }
    }
    
    private func getPhoto(url: URL, handler: @escaping (UIImage?) -> ()) {
        Alamofire.request(url).responseImage { response in
            let image = response.result.value
            handler(image)
        }
    }
}
