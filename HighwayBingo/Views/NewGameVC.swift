///
/// NewGameVC.swift
///

import Then
import SwiftGifOrigin
import UIKit

protocol InviteFriendDelegate: class {
    func invite(_ friend: FacebookUser)
    func limitFriends()
}

class NewGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource, InviteFriendDelegate {
    
    let boardTypeImageView = UIImageView()
    let boardTypeTintView = UIView()
    let boardTypeLabel = UILabel()
    let friendsTableView = UITableView()
    let friendsToInviteStackView = UIStackView()
    let inviteButton = UIButton()
    let inviteLabel = UILabel()
    let leftArrow = UIImageView()
    let rightArrow = UIImageView()
    let search = UITextField()
    let selectBoardLabel = UILabel()
    let maxFriendsLabel = UILabel()
    
    let boardTypes = BoardType.all
    var currentBoardType = BoardType.Highway
    var facebookFriends = [FacebookUser]()
    let firebaseManager = FirebaseManager.shared
    var friendsMatchingSearch = [FacebookUser]()
    var friendsToInvite = [FacebookUser]() {
        didSet {
            addFriendToStackView()
        }
    }
    
    var views: [UIView] {
        return [boardTypeImageView, boardTypeTintView, boardTypeLabel, leftArrow, rightArrow, friendsTableView, selectBoardLabel, friendsToInviteStackView, inviteButton, inviteLabel, search, maxFriendsLabel]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FacebookManager.getFriends() { self.facebookFriends = $0 }
        title = "New Game"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        fixTableViewInsets()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maxFriendsLabel.isHidden = true
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self

        views.forEach(view.addSubview)
        views.forEach { $0.freeConstraints() }
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        view.addGestureRecognizer(dismissKeyboardTap)
        
        let navigationBarHeight: CGFloat = navigationController!.navigationBar.frame.height
        
        _ = inviteLabel.then {
            $0.font = UIFont(name: "BelleroseLight", size: 24)
            $0.text = "Invite Friends"
            // Anchors
            $0.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationBarHeight + 30).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        _ = friendsToInviteStackView.then {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 10
            // Anchors
            $0.leadingAnchor.constraint(equalTo: inviteLabel.trailingAnchor, constant: 15).isActive = true
            $0.topAnchor.constraint(equalTo: inviteLabel.topAnchor, constant: 5).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        _ = search.then {
            $0.placeholder = "Search"
            $0.underline()
            $0.font = UIFont(name: "BelleroseLight", size: 20)
            // Sends alert when changed
            $0.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: inviteLabel.bottomAnchor, constant: 25).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 25).isActive = true
        }
        
        _ = maxFriendsLabel.then {
            $0.text = "Maximum Number of Invitees is 4"
            $0.font = UIFont(name: "BelleroseLight", size: 20)
            $0.textColor = UIColor.red
            $0.textAlignment = .center
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: inviteLabel.bottomAnchor, constant: 50).isActive = true
            $0.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        _ = friendsTableView.then {
            $0.register(FacebookFriendCell.self, forCellReuseIdentifier: FacebookFriendCell.reuseID)
            $0.separatorColor = .white
            // Anchors
            $0.topAnchor.constraint(equalTo: search.bottomAnchor, constant: 5).isActive = true
            $0.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: search.widthAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.topAnchor, constant: screen.height * 0.375).isActive = true
        }
        
        _ = selectBoardLabel.then {
            $0.font = UIFont(name: "BelleroseLight", size: 24)
            $0.text = "Select Game Type"
            // Anchors
            $0.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: friendsTableView.bottomAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        _ = boardTypeImageView.then {
            $0.loadGif(name: currentBoardType.rawValue.lowercased())
            // Anchors
            $0.topAnchor.constraint(equalTo: selectBoardLabel.bottomAnchor, constant: 10).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -110).isActive = true
        }
        
        _ = boardTypeTintView.then {
            $0.topAnchor.constraint(equalTo: boardTypeImageView.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: boardTypeImageView.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: boardTypeImageView.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: boardTypeImageView.trailingAnchor).isActive = true
        }
        
        _ = boardTypeLabel.then {
            $0.text = currentBoardType.rawValue.uppercased()
            $0.textAlignment = .center
            $0.textColor = .white
            $0.font = UIFont(name: "Fabian", size: 60)
            // Anchors
            $0.centerXAnchor.constraint(equalTo: boardTypeImageView.centerXAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: boardTypeImageView.centerYAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
        
        let leftArrowTap = UITapGestureRecognizer(target: self, action: #selector(self.cycleBoardTypeLeft(_:)))
    
        _ = leftArrow.then {
            $0.image = #imageLiteral(resourceName: "arrow-left")
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(leftArrowTap)
            // Anchors
            $0.centerYAnchor.constraint(equalTo: boardTypeImageView.centerYAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        let rightArrowTap = UITapGestureRecognizer(target: self, action: #selector(self.cycleBoardTypeRight(_:)))
        
        _ = rightArrow.then {
            $0.image = #imageLiteral(resourceName: "arrow-right")
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(rightArrowTap)
            // Anchors
            $0.centerYAnchor.constraint(equalTo: boardTypeImageView.centerYAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        _ = inviteButton.then {
            $0.setTitle("Send", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitle("Sent", for: .disabled)
            $0.setTitleColor(.white, for: .disabled)
            $0.titleLabel?.font = UIFont(name: "BelleroseLight", size: 20)
            // Border
            $0.purpleBorder()
            // Create Game and send Invitations when touched
            $0.addTarget(self, action: #selector(self.createGameAndSendInvitations(_:)), for: UIControlEvents.touchUpInside)
            // Anchors
            $0.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.topAnchor.constraint(equalTo: margin.bottomAnchor, constant: -80).isActive = true
        }
    }
    
    func addFriendToStackView() {
        guard let friend = friendsToInvite.last else { return }
        
        let friendImageView = UIImageView()
        let friendView = UIView()
        
        [friendImageView, friendView].forEach { $0.freeConstraints() }
        
        let _ = friendView.then {
            $0.heightAnchor.constraint(equalToConstant: 60).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        if let url = friend.imageUrl {
            let _ = friendImageView.then {
                $0.kfSetPlayerImageRound(with: url, diameter: 40)
                friendView.addSubview($0)
                // Anchors
                $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
                $0.centerXAnchor.constraint(equalTo: friendView.centerXAnchor).isActive = true
                $0.centerYAnchor.constraint(equalTo: friendView.centerYAnchor).isActive = true
            }
        }
        
        friendsToInviteStackView.addArrangedSubview(friendView)
    }
    
    func changeBoardImageViewStyles() {
        inviteButton.isUserInteractionEnabled = true
        boardTypeTintView.backgroundColor = currentBoardType.tint
        leftArrow.isHidden = true
        rightArrow.isHidden = true
        boardTypeLabel.textColor = .black
    }
    
    func cycleBoardTypeLeft(_: UIImageView) {
        guard var i = boardTypes.index(of: currentBoardType) else { return }
        i = i == boardTypes.startIndex ? boardTypes.endIndex - 1 : i - 1
        transitionBoardType(index: i)
    }
    
    func cycleBoardTypeRight(_: UIImageView) {
        guard var i = boardTypes.index(of: currentBoardType) else { return }
        i = i + 1 == boardTypes.endIndex ? boardTypes.startIndex : i + 1
        transitionBoardType(index: i)
    }
    
    func transitionBoardType(index: Int) {
        currentBoardType = boardTypes[index]
        boardTypeImageView.loadGif(name: currentBoardType.rawValue.lowercased())
        boardTypeLabel.text = currentBoardType.rawValue.uppercased()
    }

    func createGameAndSendInvitations(_ sender: UIButton!) {
        disableButton(sender)
        changeBoardImageViewStyles()
        let gameId = FirebaseManager.shared.createGame(currentBoardType, participants: friendsToInvite)
        let from = DataStore.shared.currentUser.kindName
        FirebaseManager.shared.sendInvitations(to: friendsToInvite, from: from, for: gameId, boardType: currentBoardType)
    }
    
    func disableButton(_ sender: UIButton) {
        sender.isEnabled = false
        sender.backgroundColor = UIColor(red:0.76, green:0.14, blue:1.00, alpha:1.0)
    }
    
    func dismissKeyboard(_:UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    // Called from FacebookFriendCell.swift
    //
    func invite(_ friend: FacebookUser) {
        friendsToInvite.append(friend)
        search.text = ""
        reloadFriendsTableView()
    }
    
    func textFieldChanged(_: UITextField) {
        reloadFriendsTableView()
    }
    
    func limitFriends() {
        if friendsToInvite.count == 4 {
            search.removeFromSuperview()
            maxFriendsLabel.isHidden = false
        }
    }

}


private typealias FriendsTableView = NewGameVC
extension FriendsTableView {
    
    func reloadFriendsTableView() {
        guard let searchText = search.text else { return }
        friendsMatchingSearch = facebookFriends.filter { $0.name.contains(searchText) && !friendsToInvite.contains($0) }
        friendsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsMatchingSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "facebookFriend", for: indexPath) as! FacebookFriendCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.friend = friendsMatchingSearch[indexPath.row]
        return cell
    }
    
    func fixTableViewInsets() {
        let zContentInsets = UIEdgeInsets.zero
        friendsTableView.contentInset = zContentInsets
        friendsTableView.scrollIndicatorInsets = zContentInsets
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
