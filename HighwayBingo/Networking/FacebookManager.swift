///
/// FacebookManager.swift
///

import FBSDKCoreKit
import SwiftyJSON

final class FacebookManager {
    
    static let friendsFields = ["fields": "id, name, picture"]
    
    // Get Facebook friends of the current user ("/me/"), who DO have the app installed
    //
    static func getFriends(handler: @escaping ([FacebookUser]) -> ()) {
        let connection = FBSDKGraphRequestConnection()
        let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: friendsFields)
        
        connection.add(graphRequest, completionHandler: { (connection, result, error) in
            if let error = error {
                print("FacebookManager -> error in graph request\n\t\(error.localizedDescription)")
            } else {
                let json = JSON(result)["data"].arrayValue
                let friends = json.map(FacebookUser.init)
                handler(friends)
            }
        })
        connection.start()
    }
}
