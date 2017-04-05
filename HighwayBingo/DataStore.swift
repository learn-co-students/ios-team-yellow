///
/// DataStore.swift
///

import SwiftyJSON

final class DataStore {
    
    static let shared = DataStore()
    
    var currentUser = Player()
    
    private init() {}
    
    func fetchCurrentUser(handler: @escaping () -> ()) {
        FirebaseManager.shared.fetchCurrentUser() { user in
            DataStore.shared.currentUser = user
            handler()
        }
    }
}
