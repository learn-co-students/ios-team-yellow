///
/// DataStore.swift
///

import SwiftyJSON

final class DataStore {
    
    static let shared = DataStore()
    
    var currentPlayers = [Player]()
    
    var currentUser = Player()
    
    var currentUserGames = [Game]()
    
    private init() {}
    
    func fetchCurrentUser(handler: @escaping () -> ()) {
        FirebaseManager.shared.fetchCurrentUser() { user in
            DataStore.shared.currentUser = user
            handler()
        }
    }
}
