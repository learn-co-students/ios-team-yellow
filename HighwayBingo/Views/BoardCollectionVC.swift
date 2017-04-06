//
//  BoardCollectionVC.swift
//  HighwayBingo
//
//  Created by William Leahy on 4/4/17.
//  Copyright © 2017 Oliver . All rights reserved.
//

import UIKit
import GameKit
import MobileCoreServices

private let reuseIdentifier = "boardCell"

class BoardCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate let itemsPerRow: CGFloat = 5
    fileprivate let sectionInsets = UIEdgeInsets(top: -10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var board: Board?
    var tapped: [Int] = []
    var winningCombos = [[1, 2, 3, 4, 5,], [6, 7, 8, 9, 10], [11, 12, 13, 14 ,15], [16, 17, 18, 19, 20], [21, 22, 23, 24, 25], [1, 6, 11, 16, 21], [2, 7, 12, 17, 22], [3, 8, 13, 18, 23], [4, 9, 14, 19, 24], [5, 10, 15, 20, 25], [1, 7, 13, 19, 25], [5, 9, 13, 17, 21]]

    override func viewDidLoad() {
        super.viewDidLoad()
        createCityBingo()
        shuffle()
        freeSpace()
        collectionView.delegate = self
        collectionView.dataSource = self
    }


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
        let name = board?.images[indexPath.item]
        if let name = name {
            cell.title = name
        }
        if let board = board {
            let image = UIImage(named: board.images[indexPath.item])
            cell.cellImageView.image = image
        }
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        cell.id = indexPath.item + 1
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            if let cell = collectionView.cellForItem(at: indexPath) as? BingoCollectionViewCell {
                let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "imageVC") as! ImageViewController
                imageVC.cellTitle = cell.title
                print(cell.title)
                self.navigationController?.pushViewController(imageVC, animated: false)
                //checkForWin()
                print("Cell \(cell.id) was tapped")
            }
        }
        
        
        
    }
    
    
    func checkForWin() {
        for combo in winningCombos {
            let tappedList = Set(tapped)
            let comboSet = Set(combo)
            let winner = comboSet.isSubset(of: tappedList)
            
            if winner == true {
                print("WINNER")
            } else {
                print("NO WINNER YET!")
            }
        }
    }
    
    func shuffle() -> [String]? {
        if let board = board {
            board.images = GKRandomSource().arrayByShufflingObjects(in: board.images) as! [String]
            return board.images
        } else {
            return nil
        }
        
    }
    
    func freeSpace() {
        if let board = board {
            for (index, image) in board.images.enumerated() {
                if image == "free space" && index != 12 {
                    swap(&board.images[index], &board.images[12])
                }
            }
        }
    }
    
    func createHighwayBingo() {
        let images = ["building", "airport", "barn", "bicycle", "boat", "bus", "car", "gas station", "rv", "motel", "motorcycle", "police car", "power line", "restaurant", "restroom", "river", "silo", "subway", "telephone", "train", "truck", "animal", "stop sign", "billboard", "speed limit"]
        self.board = Board(images: images, name: "Highway Bingo")
    }
    
    func createCityBingo() {
        let images = ["ambulance", "bank", "bar", "bus", "car", "coffee", "crosswalk", "garbage", "hotel", "hydrant", "laundromat", "mailbox", "manhole", "map", "museum", "newspaper", "park", "parking meter", "police car", "free space", "statue", "stoplight", "taxi", "tourist", "vendor"]
        self.board = Board(images: images, name: "City Bingo")
    }
    
    func createTropicalBingo() {
        let images = ["bathing suit", "beach chair", "beach", "boat", "coconut", "cooler", "flower", "frozen drink", "ice cream", "jet ski", "lei", "lifeguard", "palm tree", "rock", "sandals", "sandcastle", "seagull", "seashell", "sunglasses", "sunscreen", "surfboard", "towel", "umbrella", "waterfall", "free space"]
        self.board = Board(images: images, name: "Tropical Bingo")
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
