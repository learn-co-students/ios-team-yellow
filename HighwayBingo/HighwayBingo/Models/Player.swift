///
/// Player.swift
///

import Alamofire
import AlamofireImage
import Firebase

struct Player {
    
    let name: String
    let id: String
    
    init(_ user: FIRUser) {
        self.name = user.displayName?.firstWord ?? ""
        self.id = user.providerID
    }
}
