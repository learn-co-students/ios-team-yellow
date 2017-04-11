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

    // commit version

class BoardCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageVCDelegate {
    
    fileprivate let itemsPerRow: CGFloat = 5
    fileprivate let sectionInsets = UIEdgeInsets(top: -10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet var winnerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func dismissButton(_ sender: UIButton) {
        animateOut()
    }
    
    var effect : UIVisualEffect!
    var board: Board?
    var game: Game?
    var player: Player?
    var selectedCell: BingoCollectionViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        winnerView.layer.cornerRadius = 5

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
        let index = String(indexPath.item)
        if var board = board, let game = self.game, let player = player {
            //Retrieve Image From Firebase
            FirebaseManager.shared.getBoardImage(game: game, userid: player.id, index: index, completion: { (imageName) in
                if imageName.contains("https") {
                    //Set Up Cell if Image is Not a Stock Image
                    let firstURLComponents = imageName.components(separatedBy: "2F")
                    let secondHalf = firstURLComponents[1]
                    let secondURLComponents = secondHalf.components(separatedBy: ".jpg")
                    let name = secondURLComponents[0]
                    cell.title = name
                    cell.layer.borderColor = UIColor.green.cgColor
                    cell.layer.borderWidth = 2
                    cell.isFilled = true
                    FirebaseManager.shared.downloadImage(url: imageName, completion: { (image) in
                        DispatchQueue.main.async {
                            cell.cellImageView.image = image
                            board.filled.append(cell.id)
                        }
                        
                    })
                } else {
                    //Set Up Cell if Image is a Stock Image
                    let name = board.images[indexPath.item]
                    if let name = name {
                        cell.title = name
                    }

                    cell.setUpCell()
                    cell.cellImageView.image = UIImage(named: imageName)
                }
            })
        }
        cell.id = indexPath.item + 1
        cell.setUpCell()
        
        return cell
    }
    
    //Decides what happens when a cell is selected
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            if let cell = collectionView.cellForItem(at: indexPath) as? BingoCollectionViewCell {
                selectedCell = cell
                let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "imageVC") as! ImageViewController
                imageVC.cellTitle = cell.title
                imageVC.game = game
                imageVC.player = player
                imageVC.index = String(indexPath.item)
                imageVC.delegate = self
                print(cell.title)
                self.navigationController?.pushViewController(imageVC, animated: false)
                print("Cell \(cell.id) was tapped")
            }
        }
    }
    
    // animates winner popup in
    
    func animateIn() {
        self.view.addSubview(winnerView)
        winnerView.center = self.view.center
        
        winnerView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        winnerView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            self.winnerView.alpha = 1
            self.winnerView.transform = CGAffineTransform.identity
        }
    }
    
    // animates winner popup out
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.winnerView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.winnerView.alpha = 0
            
            self.visualEffectView.effect = nil
        }) { (success : Bool) in
            self.winnerView.removeFromSuperview()
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
    
    
}

//Delegate method to update the cells

extension BoardCollectionVC {
    func updateCell(image: UIImage) {
        if let cell = selectedCell {
            cell.isFilled = true
            cell.layer.borderColor = UIColor.green.cgColor
            cell.layer.borderWidth = 2
            cell.cellImageView.image = image
            board?.filled.append(cell.id)
        }
        
    }
}
