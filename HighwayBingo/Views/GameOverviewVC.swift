///
/// GameOverview.swift
///

import UIKit


class GameOverviewVC: UIViewController, UITableViewDelegate, UITableViewDataSource, TransitionToPlayerBoardDelegate {
    
    let lastPhotoLabel = UILabel()
    let leaveGameButton = UIImageView()
    let playerLabel = UILabel()
    let playersTableView = UITableView()
    let startGameButton = UIButton()
    let waitingForLabel = UILabel()
    
    var currentUserIsLeader = false
    var allPlayersAccepted = true
    
    var game: Game? {
        didSet {
            if let game = game {
                title = "\(game.boardType) Bingo"
                players = game.gameProgress == .notStarted ? game.players : game.playersOrderedByRank
                currentUserIsLeader = game.currentUserIsLeader
            }
        }
    }
    
    
    var players = [Player]()
    
    var views: [UIView] {
        return [lastPhotoLabel, playerLabel, playersTableView, startGameButton, waitingForLabel, leaveGameButton]
    }
    
    override func viewDidLoad() {
        
        playersTableView.delegate = self
        playersTableView.dataSource = self
        
        views.forEach(view.addSubview)
        views.forEach { $0.freeConstraints() }
        
        let leaveGameTap = UITapGestureRecognizer(target: self, action: #selector(self.leaveGame(_:)))
        
        _ = leaveGameButton.then {
            $0.image = #imageLiteral(resourceName: "cancel")
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(leaveGameTap)
            // Anchors
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: navBarHeight + 30).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        _ = playerLabel.then {
            $0.text = "Player"
            $0.textAlignment = .center
            $0.font = UIFont(name: "BelleroseLight", size: 24)
            // Anchors
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: screen.width * 0.15).isActive = true
            $0.widthAnchor.constraint(equalToConstant: screen.width * 0.25).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.topAnchor.constraint(equalTo: leaveGameButton.topAnchor, constant: 20).isActive = true
        }
        
        _ = lastPhotoLabel.with {
            $0.text = "Last Photo"
            $0.textAlignment = .center
            $0.font = UIFont(name: "BelleroseLight", size: 24)
            // Anchors
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: screen.width * 0.6).isActive = true
            $0.widthAnchor.constraint(equalToConstant: screen.width * 0.25).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.topAnchor.constraint(equalTo: leaveGameButton.topAnchor, constant: 20).isActive = true
        }
        
        _ = playersTableView.then {
            $0.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseID)
            $0.separatorColor = .white
            // Anchors
            $0.topAnchor.constraint(equalTo: playerLabel.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true
        }
        
        if game?.gameProgress == .notStarted {
            if currentUserIsLeader {
                addStartGameButton()
            } else {
                addWaitingForLabel()
            }
        }
    }
    
    func addStartGameButton() {
        
        _ = startGameButton.then {
            $0.isHidden = false
            $0.setTitle("Start", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = UIFont(name: "BelleroseLight", size: 20)
            // Border
            $0.purpleBorder()
            // Start game
            for player in players {
                if game?.participants[player.id] == false {
                    allPlayersAccepted = false
                }
            }
            if allPlayersAccepted == false {
                $0.addTarget(self, action: #selector(self.displayAlert(_:)), for: .touchUpInside)
            } else {
                $0.addTarget(self, action: #selector(self.startGame(_:)), for: UIControlEvents.touchUpInside)
            }
            
            // Anchors
            $0.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.topAnchor.constraint(equalTo: margin.bottomAnchor, constant: -80).isActive = true
        }
    }
    
    func addWaitingForLabel() {
        
        guard let game = game, let leader = players.filter({ $0.id == game.leaderId }).first else { return }
        
        _ = waitingForLabel.then {
            $0.text = "Waiting for \(leader.kindName) to start the game."
            $0.textAlignment = .center
            $0.numberOfLines = 0
            // Anchors
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.widthAnchor.constraint(equalToConstant: screen.width * 0.75).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
        }
    }
    
    func leaveGame(_: UITapGestureRecognizer) {
        let leaveGameAlert = UIAlertController(title: "Leave game?", message: nil, preferredStyle: .alert)
        
        leaveGameAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            if let game = self.game {
                FirebaseManager.shared.leave(game: game) {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }))
        
        leaveGameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(leaveGameAlert, animated: true, completion: nil)
    }
    
    func startGame(_ sender: UIButton!) {
        sender.removeFromSuperview()
        guard let game = game else { return }
        FirebaseManager.shared.start(game: game)
    }
    
    func displayAlert(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Start Game?", message: "Not everyone has accepted the invite", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.startGame(sender)
        }
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }
}


extension GameOverviewVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "player", for: indexPath) as! PlayerCell
        cell.selectionStyle = .none
        cell.delegate = self
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
}
