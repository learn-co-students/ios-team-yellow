///
/// FacebookUser.swift
///

import SwiftyJSON

struct FacebookUser {
    
    let id: String
    let name: String
    let picture: URL?
    
    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        let urlString = json["picture"]["data"]["url"].stringValue
        self.picture = URL(string: urlString)
    }
}
