///
/// InviteContacts.swift
///

import Contacts
import Foundation
import Then
import UIKit

class InviteContacts: UIView, UITableViewDelegate, UITableViewDataSource {
    
    let exitButton = UIImageView()
    let descriptionLabel = UILabel()
    let contactsTableView = UITableView()
    
    var contacts = [Contact]()
    let controller = InviteContactsController()
    
    weak var inviteContactDelegate: InviteContactToDownloadAppDelegate?
    weak var keyboardDelegate: EnableDismissKeyboardGestureRecognizerDelegate?
    
    var views: [UIView] {
        return [exitButton, descriptionLabel, contactsTableView]
    }
    
    func exitView(_: UITapGestureRecognizer) {
        keyboardDelegate?.enableDismissKeyboardGestureRecognizer()
        removeFromSuperview()
    }

    init() {
        super.init(frame: .zero)
        
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        contactsTableView.separatorColor = .white
        
        views.forEach(self.addSubview)
        views.forEach { $0.freeConstraints() }
        
        let exitTap = UITapGestureRecognizer(target: self, action: #selector(self.exitView(_:)))
        
        _ = exitButton.then {
            $0.image = #imageLiteral(resourceName: "cancel")
            // Gesture Recognizer
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(exitTap)
            // Anchors
            $0.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        _ = descriptionLabel.then {
            $0.text = "Invite your friends to download AI - Spy"
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.font = UIFont(name: "BelleroseLight", size: 24)
            // Anchors
            $0.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: 10).isActive = true
            $0.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }
        
        _ = contactsTableView.then {
            $0.register(ContactCell.self, forCellReuseIdentifier: ContactCell.reuseID)
            // Anchors
            $0.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20).isActive = true
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
        DispatchQueue.global(qos: .background).async {
            self.controller.getContacts() { results in
                if let results = results {
                    self.contacts = results
                        .flatMap(Contact.init)
                        .removeDuplicates()
                        .sorted { $0.0.fullName < $0.1.fullName }
                    DispatchQueue.main.async {
                        self.contactsTableView.reloadData()
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private typealias ContactsTableView = InviteContacts
extension ContactsTableView {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.reuseID, for: indexPath) as! ContactCell
        cell.selectionStyle = .none
        cell.contact = contacts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        inviteContactDelegate?.invite(contact)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}


final class InviteContactsController {
    
    private let store = CNContactStore()
    
    private var authStatus: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    
    public func getContacts(handler: @escaping ([CNContact]?) -> ()) {
        if authStatus == .authorized {
            handler(contacts)
        } else {
            store.requestAccess(for: .contacts, completionHandler: { (authorized, error) in
                authorized ? handler(self.contacts) : handler(nil)
            })
        }
    }
    
    private lazy var contacts: [CNContact] = {
        
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey
            ] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        
        do {
            allContainers = try self.store.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try self.store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
}
