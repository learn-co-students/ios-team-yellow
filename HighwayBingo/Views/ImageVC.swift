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
    
    private let storage = FIRStorage.storage(url: Secrets.Firebase.storageUrl).reference()
    
    var cellTitle: String = ""
    var game: Game?
    var player: Player?
    var delegate: ImageVCDelegate?
    var index: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CELL TITLE: \(cellTitle)")
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

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("*****GETTING CALLED!*****")
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
        WatsonAPIClient.verifyImage(image: imageData) {
            let search = self.cellTitle
            print("SEARCH: \(search)")
            let lowercasedSearch = search.lowercased()
            for match in WatsonAPIClient.possibleMatches {
                if match.contains(lowercasedSearch) {
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

                    break
                } else {
                    self.setUpVerificationButton()
                    self.loadingSpinner.stopAnimating()
                    self.loadingSpinner.isHidden = true
                    self.statusLabel.isHidden = false
                    self.statusLabel.text = "FALSE"
                    self.statusLabel.textColor = UIColor.red
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func setUpVerificationButton() {
        print("SETTING UP BUTTON")
        view.addSubview(verificationButton)
        verificationButton.translatesAutoresizingMaskIntoConstraints = false
        verificationButton.isUserInteractionEnabled = true
        verificationButton.setTitle("Ask Friends to Verify", for: .normal)
        verificationButton.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        verificationButton.setTitleColor(UIColor.red, for: .normal)
        verificationButton.backgroundColor = UIColor.gray
        verificationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        verificationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        verificationButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        verificationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func verifyButtonTapped(_ sender: UIButton) {
        guard let game = game, let player = player else {return}
        let location = self.storage.child("images/\(game.id)/\(player.id)/\(self.cellTitle).jpg")
        guard let image = self.imageView.image else {return}
        FirebaseManager.shared.saveImage(image, at: location) { imageUrl in
            guard let url = imageUrl, let game = self.game, let player = self.player  else { return }
            let playerIDs = game.playerIds
            FirebaseManager.shared.sendVerification(to: playerIDs, from: player.kindName, game: game, imageURL: url, imageName: self.cellTitle)

        }
    }
//    _ = inviteButton.then {
//    $0.isUserInteractionEnabled = false
//    $0.setTitle("Send", for: .normal)
//    $0.setTitleColor(.black, for: .normal)
//    $0.setTitle("Sent", for: .disabled)
//    $0.setTitleColor(.white, for: .disabled)
//    $0.titleLabel?.font = UIFont(name: "BelleroseLight", size: 20)
//    // Border
//    $0.purpleBorder()
//    // Create Game and send Invitations when touched
//    $0.addTarget(self, action: #selector(self.createGameAndSendInvitations(_:)), for: UIControlEvents.touchUpInside)
//    // Anchors
//    $0.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
//    $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
//    $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
//    $0.topAnchor.constraint(equalTo: margin.bottomAnchor, constant: -80).isActive = true
//    }

    
    @IBAction func retakeTapped(_ sender: Any) {
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


