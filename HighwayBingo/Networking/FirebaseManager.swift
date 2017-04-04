///
/// FirebaseManager.swift
///

import Alamofire
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Foundation

final class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    static private let db = FIRDatabase.database().reference()
    
    private let storage = FIRStorage.storage(url: "gs://highwaybingo.appspot.com").reference()
    
    enum Child {
        static var users: FIRDatabaseReference { return db.child("users") }
    }
    
    private init() {}
  
    func createOrUpdate(_ user: FIRUser) {
        let name = user.displayName ?? "Anonymous"
        let _id = user.uid
        let params = ["name":name, "_id": _id]
        
        if let imageUrl = user.photoURL {
            
            getPhoto(url: imageUrl) { image in
                if let image = image {
                    let location = self.storage.child("images/\(_id).jpg")
                    self.save(image, at: location, userParams: params) { success in
                        //if !success { Child.users.setValue(params) }
                        if !success { Child.users.child(_id).setValue(params) }
            
                    }
                }
            }
        }
    }
    
    typealias ImageDownloaded = Bool
    
    private func save(_ image: UIImage, at location: FIRStorageReference, userParams: [String : String], handler: @escaping (ImageDownloaded) -> ()) {
        
        guard let data = UIImageJPEGRepresentation(image, 0.8) else {
            handler(false)
            return
        }
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        
        location.put(data, metadata: metaData) { (metadata, error) in
            if let imageUrl = metadata?.downloadURL() {
                let paramsWithImage = userParams += ["imageUrl" : String(describing: imageUrl)]
                let id = paramsWithImage["_id"] ?? "No ID"
                Child.users.child(id).setValue(paramsWithImage)
                handler(true)
            } else {
                print("FirebaseManager -> error saving photo")
                handler(false)
            }
        }
    }
    
    private func getPhoto(url: URL, handler: @escaping (UIImage?) -> ()) {
        Alamofire.request(url).responseImage { response in
            let image = response.result.value
            handler(image)
        }
    }
}
