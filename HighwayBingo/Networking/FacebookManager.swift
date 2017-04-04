///
/// FacebookManager.swift
///

import FBSDKCoreKit
import SwiftyJSON

final class FacebookManager {
    
    static func getFriends(handler: @escaping ([FacebookUser]) -> ()) {
        
        let params = ["fields": "id, name, picture"]
        let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
        let connection = FBSDKGraphRequestConnection()
        
        connection.add(graphRequest, completionHandler: { (connection, result, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let json = JSON(result)["data"].arrayValue
                let friends = json.map(FacebookUser.init)
                handler(friends)
            }
        })
        connection.start()
    }
}
