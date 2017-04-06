///
/// GameOverview.swift
///

import UIKit

class GameOverviewVC: UIViewController {
    
    @IBOutlet weak var gameTitleLabel: UILabel!
    var game: Game?
    
    override func viewDidLoad() {
        if let gameTitle = game?.title {
            gameTitleLabel.text = gameTitle
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
