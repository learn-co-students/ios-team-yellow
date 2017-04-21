///
/// ImageVC.swift
///

import UIKit
import MobileCoreServices
import FirebaseStorage
import FirebaseDatabase

protocol ImageVCDelegate {
    func updateCell(image: UIImage)
}

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

    let verificationButton = UIButton()
    let retakeButton = UIButton()
    
    private let storage = FIRStorage.storage(url: Secrets.Firebase.storageUrl).reference()
    
    var cellTitle: String = ""
    var game: Game?
    var player: Player?
    var delegate: ImageVCDelegate?
    var index: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRetakeButton()
        retakeButton.isHidden = true
        statusLabel.font = UIFont(name: "BelleroseLight", size: 24)
        loadingSpinner.isHidden = true
        statusLabel.isHidden = true
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageView.image = image
        //UIImageWriteToSavedPhotosAlbum(image, self, #selector(ImageViewController.image), nil)
        guard let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        let smallImage = newImage.resized(withPercentage: 0.25)
        guard let imageData = UIImagePNGRepresentation(smallImage!) else {return}
        loadingSpinner.startAnimating()
        loadingSpinner.isHidden = false
        statusLabel.isHidden = false
        statusLabel.textColor = UIColor.black
        statusLabel.text = "Thinking..."
        retakeButton.isHidden = true
        WatsonAPIClient.verifyImage(image: imageData) {
            let search = self.cellTitle
            let lowercasedSearch = search.lowercased()
            let searchArray = self.helpWatson(title: lowercasedSearch)
            outerloop: for match in WatsonAPIClient.possibleMatches {
                innerloop: for word in searchArray {
                    if match.contains(word) {
                        self.retakeButton.isHidden = true
                        self.verificationButton.isHidden = true
                        self.loadingSpinner.stopAnimating()
                        self.loadingSpinner.isHidden = true
                        self.statusLabel.isHidden = false
                        self.statusLabel.text = "TRUE"
                        self.statusLabel.textColor = UIColor.green
                        self.delegate?.updateCell(image: image)
                        guard let game = self.game, let player = self.player else {return}
                        let location = self.storage.child("images/\(game.id)/\(player.id)/\(self.cellTitle).jpg")
                        FirebaseManager.shared.saveImage(image, at: location) { imageUrl in
                            guard let url = imageUrl, let game = self.game, let player = self.player else { return }
                            FirebaseManager.shared.updateImage(imageURL: url, game: game, userid: player.id, index: self.index)
                            FirebaseManager.shared.addLastPic(imageURL: url, game: game, userid: player.id)
                        }
                        
                        break outerloop
                    } else {
                        self.retakeButton.isHidden = false
                        self.setUpVerificationButton()
                        self.loadingSpinner.stopAnimating()
                        self.loadingSpinner.isHidden = true
                        self.statusLabel.isHidden = false
                        self.statusLabel.text = "FALSE"
                        self.statusLabel.textColor = UIColor.red
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpVerificationButton() {
        verificationButton.isHidden = false
        view.addSubview(verificationButton)
        verificationButton.translatesAutoresizingMaskIntoConstraints = false
        verificationButton.isUserInteractionEnabled = true
        verificationButton.titleLabel?.font = UIFont(name: "BelleroseLight", size: 24)
        verificationButton.setTitle("Ask Friends to Verify", for: .normal)
        verificationButton.setTitleColor(UIColor.white, for: .normal)
        verificationButton.setTitle("Sent", for: .disabled)
        verificationButton.setTitleColor(UIColor.white, for: .disabled)
        verificationButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        verificationButton.backgroundColor = UIColor(red:0.76, green:0.14, blue:1.00, alpha:1.0)
        verificationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        verificationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        verificationButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        verificationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setUpRetakeButton() {
        view.addSubview(retakeButton)
        retakeButton.purpleBorder()
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.isUserInteractionEnabled = true
        retakeButton.contentVerticalAlignment = .center
        retakeButton.contentHorizontalAlignment = .center
        retakeButton.titleLabel?.font = UIFont(name: "BelleroseLight", size: 24)
        retakeButton.setTitle("Retake", for: .normal)
        retakeButton.setTitleColor(UIColor.green, for: .normal)
        retakeButton.addTarget(self, action: #selector(retakeTapped(_:)), for: .touchUpInside)
        retakeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        retakeButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10).isActive = true
        retakeButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        retakeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
    }
    
    func verifyButtonTapped(_ sender: UIButton) {
        disableButton(sender)
        guard let game = game, let player = player else {return}
        let location = self.storage.child("images/\(game.id)/\(player.id)/\(self.cellTitle).jpg")
        guard let image = self.imageView.image else {return}
        FirebaseManager.shared.saveImage(image, at: location) { imageUrl in
            guard let url = imageUrl, let game = self.game, let player = self.player  else { return }
            var playerIDs = game.playerIds
            let currentUserID = player.id
            playerIDs.remove(object: currentUserID)
            FirebaseManager.shared.sendVerification(
                to: playerIDs,
                from: player,
                game: game,
                imageURL: url,
                imageName: self.cellTitle,
                imageIndex: self.index
            )
        }
    }
    
    func disableButton(_ sender: UIButton) {
        sender.isEnabled = false
    }


    func retakeTapped(_ sender: UIButton) {
        verificationButton.isHidden = true
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension ImageViewController {
    
    func helpWatson(title: String) -> [String] {
        var searchArray = [String]()
        switch title {
        case "airport":
            searchArray = [title, "airplane", "aircraft"]
        case "barn":
            searchArray = [title, "gambrel", "farm building"]
        case "boat":
            searchArray = [title, "watercraft"]
        case "gas station":
            searchArray = [title, "convenience store", "booth"]
        case "rv":
            searchArray = [title, "recreational vehicle", "camping"]
        case "motel":
            searchArray = [title, "room", "hotel", "motor hotel"]
        case "police car":
            searchArray = [title, "cruiser"]
        case "power line":
            searchArray = [title, "wire"]
        case "restaurant":
            searchArray = [title, "dining", "store"]
        case "river":
            searchArray = [title, "valley", "waterside", "riverbank"]
        case "restroom":
            searchArray = [title, "doorplate", "washroom", "toilet"]
        case "water tower":
            searchArray = [title, "storage tank", "reservoir"]
        case "subway":
            searchArray = [title, "railway", "train"]
        case "stop sign":
            searchArray = [title, "octagon", "alizarine red color"]
        case "billboard":
            searchArray = [title, "signboard"]
        case "speed limit":
            searchArray = [title, "plating", "signboard"]
        case "bank":
            searchArray = [title, "automated teller machine"]
        case "bar":
            searchArray = [title, "tavern"]
        case "bus":
            searchArray = [title, "shuttle"]
        case "coffee":
            searchArray = [title, "paper cup", "mug"]
        case "crosswalk":
            searchArray = [title, "pedestrian crossing"]
        case "garbage":
            searchArray = [title, "trash", "wastepaper bin", "bag"]
        case "hotel":
            searchArray = [title, "doubletree"]
        case "hydrant":
            searchArray = [title, "lamp", "fountain", "sprinkler"]
        case "laundromat":
            searchArray = [title, "washhouse", "dryer", "washer", "dry cleaners"]
        case "mailbox":
            searchArray = [title, "lamp"]
        case "museum":
            searchArray = [title, "exhibition", "hall", "government building"]
        case "park":
            searchArray = [title, "nature", "campsite"]
        case "statue":
            searchArray = [title, "sculpture", "figure"]
        case "stoplight":
            searchArray = [title, "traffic light"]
        case "tourist":
            searchArray = [title, "person"]
        case "vendor":
            searchArray = [title, "newsstand", "booth"]
        case "streetlight":
            searchArray = [title, "lamp"]
        case "bathing suit":
            searchArray = [title, "undergarment"]
        case "beach chair":
            searchArray = [title, "desk chair"]
        case "beach":
            searchArray = [title, "seaside", "atoll"]
        case "frozen drink":
            searchArray = [title, "fruit drink"]
        case "jet ski":
            searchArray = [title, "water scooter"]
        case "lei":
            searchArray = [title, "people in polynesian dress"]
        case "sandal":
            searchArray = [title, "sandal"]
        case "sandcastle":
            searchArray = [title, "castle"]
        case "seagull":
            searchArray = [title, "bird"]
        case "seashell":
            searchArray = [title, "shell"]
        case "sunglasses":
            searchArray = [title, "sunglass"]
        case "surfboard":
            searchArray = [title, "surfing"]
        case "waterfall":
            searchArray = [title, "nature"]
        default:
            searchArray = [title]
        }
        return searchArray
    }
}
