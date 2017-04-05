//
//  BoardCollectionVC.swift
//  HighwayBingo
//
//  Created by William Leahy on 4/4/17.
//  Copyright © 2017 Oliver . All rights reserved.
//

import UIKit

private let reuseIdentifier = "boardCell"

class BoardCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate let itemsPerRow: CGFloat = 5
    fileprivate let sectionInsets = UIEdgeInsets(top: -10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = ["building", "airport", "barn", "bicycle", "boat", "bus", "car", "gas station", "rv", "motel", "motorcycle", "police car", "power line", "restaurant", "restroom", "river", "silo", "subway", "telephone", "train", "truck", "horse", "horse", "horse", "horse"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        //collectionView.backgroundColor = UIColor.gray
        

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 25
    }
    
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BingoCollectionViewCell
        if let image = UIImage(named: images[indexPath.item]) {
             cell.cellImageView.image = image
        }
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        cell.id = indexPath.item + 1
        let name = images[indexPath.item]
        cell.titleLabel.text = name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            if let cell = collectionView.cellForItem(at: indexPath) as? BingoCollectionViewCell {
                print(cell.id)
            }
        }
        
    }

}

    extension BoardCollectionVC : UICollectionViewDelegateFlowLayout {
    
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let availableWidth = collectionView.frame.width / (itemsPerRow + 1)
            
            
            let width = availableWidth
            let height = width 
            
            return CGSize(width: width, height: height)
            
            
        }
        
//        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//            return sectionInsets
//            
//        }
        
//        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//            return sectionInsets.left
//        }
    
    }
