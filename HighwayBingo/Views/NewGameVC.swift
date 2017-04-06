///
/// NewGameVC.swift
///

import Then
import UIKit

protocol InviteFriendDelegate: class {
    func invite(_ friend: FacebookUser)
}

class NewGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource, InviteFriendDelegate {
    
    let inviteButton = UIButton()
    let inviteLabel = UILabel()
    let search = UITextField()
    let friendsTableView = UITableView()
    let friendsToInviteStackView = UIStackView()
    
    var facebookFriends = [FacebookUser]()
    let firebaseManager = FirebaseManager.shared
    var friendsMatchingSearch = [FacebookUser]()
    var friendsToInvite = [FacebookUser]() {
        didSet {
            addFriendToStackView()
        }
    }
    
    var views: [UIView] {
        return [friendsTableView, friendsToInviteStackView, inviteButton, inviteLabel, search]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FacebookManager.getFriends() { self.facebookFriends = $0 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        views.forEach(view.addSubview)
        views.forEach { $0.freeConstraints() }
        
        _ = inviteLabel.then {
            $0.text = "INVITE FRIENDS"
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant: screen.height * 0.35).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
        
        _ = search.then {
            $0.placeholder = "Search"
            $0.underline()
            // Sends alert when changed
            $0.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant: screen.height * 0.55).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.45).isActive = true
        }
        
        _ = inviteButton.then {
            $0.setTitle("SEND", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = .blue
            // Create Game and send Invitations when touched
            $0.addTarget(self, action: #selector(self.createGameAndSendInvitations(_:)), for: UIControlEvents.touchUpInside)
            // Anchors
            $0.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: search.bottomAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.45).isActive = true
        }
        
        _ = friendsTableView.then {
            $0.register(FacebookFriendCell.self, forCellReuseIdentifier: FacebookFriendCell.reuseID)
            // Anchors
            $0.topAnchor.constraint(equalTo: search.bottomAnchor, constant: 20).isActive = true
            $0.widthAnchor.constraint(equalTo: search.widthAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
        }
        
        _ = friendsToInviteStackView.then {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 25
            // Anchors
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: inviteLabel.bottomAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: search.topAnchor).isActive = true
        }
    }
    
    func textFieldChanged(_: UITextField) {
        reloadFriendsTableView()
    }
    
    // Called from FacebookFriendCell.swift
    //
    func invite(_ friend: FacebookUser) {
        friendsToInvite.append(friend)
        reloadFriendsTableView()
    }
    
    func addFriendToStackView() {
        guard let friend = friendsToInvite.last else { return }
        let _ = UILabel().then {
            $0.text = friend.name
            friendsToInviteStackView.addArrangedSubview($0)
        }
    }
    
    func createGameAndSendInvitations(_ sender: UIButton!) {
        let gameId = FirebaseManager.shared.createGame()
        FirebaseManager.shared.sendInvitations(for: gameId, to: friendsToInvite)
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
        cell.delegate = self
        cell.friend = friendsMatchingSearch[indexPath.row]
        return cell
    }
}
