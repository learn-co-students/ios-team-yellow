///
/// InstructionsVC.swift
///

import CHIPageControl
import Then
import UIKit

class InstructionsVC: UIViewController, UIScrollViewDelegate {
    
    let gameTitleLabel = UILabel()
    let stepLabel = UILabel()
    let instructionLabel = UILabel()
    
    let pageController = CHIPageControlPuya(frame: CGRect(x: 0, y:0, width: 100, height: 20))
    var page = 0
    
    var views: [UIView] {
        return [gameTitleLabel, stepLabel, instructionLabel, pageController]
    }
    
    let instructions = [
        "Create a new game by choosing a board and inviting up to 3 friends.",
        "Start the game with all friends that accepted the invitation.",
        "Take pictures of the objects in each space.  Photos are verified by Artificial Intelligence, but if that doesn't work, you can ask your friends too.\n\nThe first player to get 5 in a row wins."
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.39, green:0.65, blue:0.95, alpha:0.5)
        views.forEach(view.addSubview)
        views.forEach { $0.freeConstraints() }
        
        let _ = gameTitleLabel.then {
            $0.text = "AI - Spy"
            $0.font = UIFont(name: "Fabian", size: 42)
            $0.textAlignment = .center
            // Anchors
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: screen.height * 0.1).isActive = true
        }
        
        let _ = stepLabel.then {
            $0.font = UIFont(name: "BelleroseLight", size: 32)
            // Anchors
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: screen.height * 0.3).isActive = true
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        let _ = instructionLabel.then {
            $0.font = UIFont(name: "BelleroseLight", size: 20)
            $0.numberOfLines = 0
            $0.textAlignment = .center
            // Anchors
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 20).isActive = true
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        let _ = pageController.then {
            $0.numberOfPages = 3
            $0.radius = 10
            $0.tintColor = .black
            $0.currentPageTintColor = .white
            $0.padding = 20
            // Anchors
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -screen.height * 0.1).isActive = true
        }
        
        let _ = UISwipeGestureRecognizer(target: self, action: #selector(self.goBack(_:))).then {
            $0.direction = .right
            $0.numberOfTouchesRequired = 1
            view.addGestureRecognizer($0)
        }
        
        let _ = UISwipeGestureRecognizer(target: self, action: #selector(self.goForward(_:))).then {
            $0.direction = .left
            $0.numberOfTouchesRequired = 1
            view.addGestureRecognizer($0)
        }
        
        resetContent()
    }
    
    func goBack(_:UISwipeGestureRecognizer) {
        if page > 0 {
            page -= 1
            pageController.set(progress: page, animated: true)
            resetContent()
        }
    }
    
    func goForward(_:UISwipeGestureRecognizer) {
        if page == 2 {
            transitionToHomeVC()
        } else {
            page += 1
            pageController.set(progress: page, animated: true)
            resetContent()
        }
    }
    
    func resetContent() {
        stepLabel.text = String(page + 1)
        instructionLabel.text = instructions[page]
    }
    
    func transitionToHomeVC() {
        DispatchQueue.main.async { NotificationCenter.default.post(name: .showHomeVC, object: nil) }
    }
}
