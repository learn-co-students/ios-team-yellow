///
///  BoardCollectionVC.swift
///

import UIKit
import GameKit
import MobileCoreServices
import Kingfisher
import MessageUI

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
    var currentCellURL: String?
    
    let picView = UIImageView()
    let backgroundImage = UIImageView()
    
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        winnerView.layer.cornerRadius = 5

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        
        setUpPicView()
        
        
        
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
        if let board = board, var game = self.game, var player = player {
            let boardName = board.boardType.rawValue.lowercased()
            setUpBackgroundImage(image: boardName)
            //Retrieve Image From Firebase
            FirebaseManager.shared.getBoardImage(game: game, userid: player.id, index: index, completion: { (imageName) in
                if imageName.contains("https") {
                    //Set Up Cell if Image is Not a Stock Image
                    let firstURLComponents = imageName.components(separatedBy: ".jpg")
                    let firstHalf = firstURLComponents[0]
                    let secondURLComponents = firstHalf.components(separatedBy: "%2F")
                    let name = secondURLComponents.last
                    if let name = name {
                        let finalName = name.replacingOccurrences(of: "%20", with: " ")
                        cell.title = finalName.capitalized
                        cell.layer.borderColor = UIColor.green.cgColor
                        cell.layer.borderWidth = 2
                        cell.isFilled = true
                        cell.imageURL = imageName
                        board.filled.append(cell.id)
                        let winner = board.checkForWin()
                        if winner && game.gameProgress != .ended {
                            self.animateIn()
                            FirebaseManager.shared.incrementGameStatus(game)
                        }
                        let url = URL(string: imageName)
                        cell.cellImageView.kf.setImage(with: url)
                    }
                } else {
                    //Set Up Cell if Image is a Stock Image
                    let name = board.images[indexPath.item]
                    if let name = name {
                        cell.title = name.capitalized
                    }
                    cell.setUpCell()
                    cell.cellImageView.image = UIImage(named: imageName)
                }
            })
            
            //Check to See How Many Away From a Win and Update Firebase
            FirebaseManager.shared.getBoardID(for: game, userid: player.id) { (boardID) in
                let currentUserID = DataStore.shared.currentUser.id
                //If it is your board...
                if boardID == currentUserID {
                    let number = board.howManyAwayFromWin()
                    let gameId = game.id
                    FirebaseManager.shared.numberAwayFromWin(number, gameId: gameId)
                }
            }

        }
        cell.id = indexPath.item
        cell.setUpCell()
        
        return cell
    }
    
    //Decides what happens when a cell is selected
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            if let cell = collectionView.cellForItem(at: indexPath) as? BingoCollectionViewCell {
                currentCellURL = cell.imageURL
                if let game = game, let player = player {
                    if game.gameProgress != .ended {
                        FirebaseManager.shared.getBoardID(for: game, userid: player.id) { (boardID) in
                            let currentUserID = DataStore.shared.currentUser.id
                            //If it is your board...
                            if boardID == currentUserID {
                                self.selectedCell = cell
                                if cell.isFilled == true {
                                    self.updatePic(image: cell.cellImageView.image!)
                                } else {
                                    let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "imageVC") as! ImageViewController
                                    imageVC.cellTitle = cell.title
                                    imageVC.game = self.game
                                    imageVC.player = self.player
                                    imageVC.index = String(indexPath.item)
                                    imageVC.delegate = self
                                    self.navigationController?.pushViewController(imageVC, animated: false)
                                }
                                //If it is not your board...
                            } else {
                                self.updatePic(image: cell.cellImageView.image!)
                                self.setUpReportButton()
                                
                            }
                        }

                    } else {
                        self.updatePic(image: cell.cellImageView.image!)
                        
                    }
                }
            }
        }
    }

    //Add Image View to View Selected Picture on Opponent's Board
    func setUpPicView() {
        view.addSubview(picView)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        picView.addGestureRecognizer(dismissTap)
        picView.isHidden = true
        picView.isUserInteractionEnabled = true
        picView.backgroundColor = UIColor.white
        picView.purpleBorder()
        picView.translatesAutoresizingMaskIntoConstraints = false
        picView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        picView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        picView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        picView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
    }
    
    func setUpReportButton() {
        let reportButton = UIBarButtonItem.init(title: "Report", style: .plain, target: self, action: #selector(reportUser))
        navigationItem.rightBarButtonItem = reportButton
    }
    
    func reportUser(sender: UIBarButtonItem) {
        if let player = player {
            let reportAlert = UIAlertController(title: "Report User", message: "Are you sure you want to report \(player.kindName)?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                if let url = self.currentCellURL {
                    FirebaseManager.shared.reportUser(reportedUser: player.id, imageURL: url)
                }
                self.navigationItem.rightBarButtonItem = nil
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            reportAlert.addAction(yesAction)
            reportAlert.addAction(noAction)
            self.present(reportAlert, animated: true)
        }
    }
    
    
    
    func updatePic(image: UIImage) {
        picView.image = image
        picView.isHidden = false
        collectionView.isUserInteractionEnabled = false
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        collectionView.isUserInteractionEnabled = true
        picView.isHidden = true
        self.navigationItem.rightBarButtonItem = nil
        
    }
    
    func setUpBackgroundImage(image: String) {
        view.addSubview(backgroundImage)
        view.sendSubview(toBack: backgroundImage)
        backgroundImage.image = UIImage(named: image)
        backgroundImage.contentMode = .scaleToFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backgroundImage.heightAnchor.constraint(equalToConstant: screen.height).isActive = true
        backgroundImage.widthAnchor.constraint(equalToConstant: screen.width).isActive = true
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
    
            // Update how close player is to winning in Firebase
            guard let number = board?.howManyAwayFromWin(), let gameId = game?.id else { return }
            FirebaseManager.shared.numberAwayFromWin(number, gameId: gameId)
        }
    }
}

//Ability to Test Win without Taking Pictures

extension BoardCollectionVC {
    
    func displayWinner() {
        animateIn()
    }
    
    func testWin(cell: BingoCollectionViewCell) {
        if let board = board {
            board.filled.append(cell.id)
            cell.isFilled = true
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.green.cgColor
            let winner = board.checkForWin()
            if winner == true {
                displayWinner()
            }
        }
    }
}
