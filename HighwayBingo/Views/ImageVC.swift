///
/// ImageVC.swift
///

import UIKit
import MobileCoreServices

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    var cellTitle: String = ""
    
    
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
                    break
                } else {
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


