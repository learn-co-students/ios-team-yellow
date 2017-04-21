///
/// WatsonAPIClient.swift
///

import Foundation
import Alamofire

class WatsonAPIClient {
    
    static var possibleMatches = [String]()
    
    class func verifyImage (image: Data, completion: @escaping () -> ()) {
        possibleMatches.removeAll()
        let urlString = "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=db215296900399c3b1de5ebd4745321297703ab6&version=2016-05-20"
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(image, withName: "images_file", mimeType: "image/png")
        }, to: urlString) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    let JSON = response.result.value as? [String:Any] ?? [:]
                    let imagesArray = JSON["images"] as? [[String:Any]] ?? [[:]]
                    for image in imagesArray {
                        let classifiersArray = image["classifiers"] as? [[String:Any]] ?? [[:]]
                        for classifier in classifiersArray {
                            let classesArray = classifier["classes"] as? [[String:Any]] ?? [[:]]
                            for item in classesArray {
                                let possibleMatch = item["class"] as? String ?? ""
                                self.possibleMatches.append(possibleMatch)
                            }
                        }
                    }
                    completion()
                })
            case .failure(let encodingError):
                print("WatsonAPIClient -> \(encodingError)")
            }
        }
    }
}
