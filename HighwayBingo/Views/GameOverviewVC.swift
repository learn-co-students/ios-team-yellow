///
/// GameOverview.swift
///

import UIKit

class GameOverviewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let lastPhotoLabel = UILabel()
    let playerLabel = UILabel()
    let playersTableView = UITableView()
    
    var game: Game? {
        didSet {
            if let game = game {
                title = game.title
                players = game.players
            }
        }
    }
    
    var players = [Player]()
    
    var views: [UIView] {
        return [lastPhotoLabel, playerLabel, playersTableView]
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
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}


extension GameOverviewVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "player", for: indexPath) as! PlayerCell
        cell.selectionStyle = .none
        cell.player = players[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}
