///
/// GameOverview.swift
///

import UIKit

class GameOverviewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let lastPhotoLabel = UILabel()
    let playerLabel = UILabel()
    let playersTableView = UITableView()
    let startGameButton = UIButton()
    let waitingForLabel = UILabel()
    

    var currentUserIsLeader = false
    
    var game: Game? {
        didSet {
            if let game = game {
                title = "\(game.boardType) Bingo"
                players = game.players
                currentUserIsLeader = game.currentUserIsLeader
            }
        }
    }
    
    var players = [Player]()
    
    var views: [UIView] {
        return [lastPhotoLabel, playerLabel, playersTableView, startGameButton, waitingForLabel]
    }
        
    override func viewDidLoad() {
        
        playersTableView.delegate = self
        playersTableView.dataSource = self
        
        views.forEach(view.addSubview)
        views.forEach { $0.freeConstraints() }
        
        _ = playerLabel.then {
            $0.text = "Player"
            $0.textAlignment = .center
            // Anchors
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: screen.width * 0.15).isActive = true
            $0.widthAnchor.constraint(equalToConstant: screen.width * 0.25).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: screen.height * 0.15).isActive = true
        }
        
        _ = lastPhotoLabel.with {
            $0.text = "Last Photo"
            $0.textAlignment = .center
            // Anchors
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: screen.width * 0.6).isActive = true
            $0.widthAnchor.constraint(equalToConstant: screen.width * 0.25).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: screen.height * 0.15).isActive = true
        }
        
        _ = playersTableView.then {
            $0.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseID)
            $0.separatorColor = .white
            // Anchors
            $0.topAnchor.constraint(equalTo: playerLabel.bottomAnchor, constant: 10).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        }
        
        
        
        if currentUserIsLeader {
            _ = startGameButton.then {
                if game?.gameProgress == .notStarted {
                    $0.isHidden = false
                    $0.setTitle("Start", for: .normal)
                    $0.setTitleColor(.white, for: .normal)
                    $0.backgroundColor = .blue
                    // Start game
                    $0.addTarget(self, action: #selector(self.startGame(_:)), for: UIControlEvents.touchUpInside)
                    // Anchors
                    $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                    $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
                    $0.widthAnchor.constraint(equalToConstant: 150).isActive = true
                    $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true
                } else {
                    $0.isHidden = true
                }
                
            }
        } else {
            guard
                let game = game,
                let waitingForPlayer = players.filter({ $0.id == game.leaderId }).first
            else { return }
            
            _ = waitingForLabel.then {
                $0.text = "Waiting for \(waitingForPlayer.kindName) to start the game."
                $0.textAlignment = .center
                $0.numberOfLines = 0
                // Anchors
                $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
                $0.widthAnchor.constraint(equalToConstant: screen.width * 0.75).isActive = true
                $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true
            }
        }
    }
    
    func startGame(_ sender: UIButton!) {
        sender.removeFromSuperview()
        guard let game = game else { return }
        FirebaseManager.shared.start(game: game)
    }
    
    func pushBoardCollectionVC(board: Board, game: Game, player: Player) {
        let boardCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "boardCollectionVC") as! BoardCollectionVC
        boardCollectionVC.board = board
        boardCollectionVC.game = game
        boardCollectionVC.player = player
        self.navigationController?.pushViewController(boardCollectionVC, animated: true)
        
    }
    
}


extension GameOverviewVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "player", for: indexPath) as! PlayerCell
        cell.selectionStyle = .none
        cell.game = game!
        FirebaseManager.shared.getLastPic(game: game!, userid: players[indexPath.row].id) { (imageString) in
            let imageURL = URL(string: imageString)
            self.players[indexPath.row].lastPic = imageURL
            cell.player = self.players[indexPath.row]
        }
        return cell
        
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let game = game else { return }
        let player = players[indexPath.row]
        FirebaseManager.shared.getBoard(for: game, userid: player.id) { (board) in
            if let board = board {
                self.pushBoardCollectionVC(board: board, game: game, player: player)
            }
        }
        
        
    }
    
}
