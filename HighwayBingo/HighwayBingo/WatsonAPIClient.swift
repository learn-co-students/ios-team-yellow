//
//  WatsonAPIClient.swift
//  HighwayBingo
//
//  Created by TJ Carney on 4/3/17.
//  Copyright © 2017 Oliver . All rights reserved.
//

import Foundation
import Alamofire

class WatsonAPIClient {
    
    
    class func verifyImage (image: Data) {
        let urlString = "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=db215296900399c3b1de5ebd4745321297703ab6&version=2016-05-20"
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(image, withName: "images_file", mimeType: "image/png")
        }, to: urlString) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { progress in
                    print("progress is \(progress.fractionCompleted)")
                }
                
                upload.downloadProgress { progress in // main queue by default
                    print("Download Progress: \(progress.fractionCompleted)")
                }

                upload.responseJSON(completionHandler: { (response) in
                    debugPrint(response)
                    let JSON = response.result.value as? [String:Any] ?? [:]
                    print(JSON)
                
                    
                })
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
}



 
