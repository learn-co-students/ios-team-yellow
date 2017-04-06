//
//  BingoCollectionViewCell.swift
//  HighwayBingo
//
//  Created by TJ Carney on 4/5/17.
//  Copyright © 2017 Oliver . All rights reserved.
//

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
    
    func setUpCell() {
        if id == 13 {
            self.layer.borderColor = UIColor.green.cgColor
            self.layer.borderWidth = 2
        } else {
            self.layer.borderColor = UIColor.black.cgColor
            self.layer.borderWidth = 1
        }
        
    }
    
}
