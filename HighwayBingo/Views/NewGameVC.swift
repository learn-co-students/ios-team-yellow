///
/// NewGameVC.swift
///

import Then
import UIKit

class NewGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let inviteLabel = UILabel()
    let search = UITextField()
    let friendsTableView = UITableView()
    
    var facebookFriends = [FacebookUser]()
    var friendsMatchingSearch = [FacebookUser]()
    
    var views: [UIView] {
        return [friendsTableView, inviteLabel, search]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FacebookManager.getFriends() { self.facebookFriends = $0 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        views.forEach(view.addSubview)
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        _ = inviteLabel.then {
            $0.text = "INVITE FRIENDS"
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant: screen.height * 0.4).isActive = true
        }
        
        _ = search.then {
            $0.placeholder = "Search"
            $0.underline()
            $0.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
            $0.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: margin.topAnchor, constant: screen.height * 0.5).isActive = true
            $0.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.45).isActive = true
        }
        
        _ = friendsTableView.then {
            $0.register(FacebookFriendCell.self, forCellReuseIdentifier: FacebookFriendCell.reuseID)
            $0.topAnchor.constraint(equalTo: search.bottomAnchor, constant: 20).isActive = true
            $0.widthAnchor.constraint(equalTo: search.widthAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
        }
    }
    
    func textFieldChanged(_ textField: UITextField) {
        guard let searchText = textField.text else { return }
        friendsMatchingSearch = facebookFriends.filter { $0.name.contains(searchText) }
        friendsTableView.reloadData()
    }
}


private typealias FriendsTableView = NewGameVC
extension FriendsTableView {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsMatchingSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "facebookFriend", for: indexPath) as! FacebookFriendCell
        cell.friend = friendsMatchingSearch[indexPath.row]
        return cell
    }
}
