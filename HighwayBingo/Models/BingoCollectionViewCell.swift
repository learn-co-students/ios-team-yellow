///
/// BingoCollectionViewCell.swift
///


import UIKit

class BingoCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    var image = UIImage()
    var title: String = "" {
        didSet {
            self.titleLabel.text = self.title
        }
    }
    var id: Int = 0
    var isFilled: Bool = false
    var imageURL: String?
    
    func setUpCell() {
        if id == 12 || isFilled == true {
            self.layer.borderColor = UIColor.green.cgColor
            self.layer.borderWidth = 2
        } else {
            purpleBorder()
        }
        self.backgroundColor = UIColor.white
    }
    
}
