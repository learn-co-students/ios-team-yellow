///
/// Contact.swift
///

import Contacts

struct Contact: Equatable, Hashable {
    
    var firstName: String
    var lastName: String
    var phoneNumber: String
    
    var fullName: String {
        return lastName.isEmpty ? firstName : "\(firstName) \(lastName)"
    }
    
    init?(_ cnContact: CNContact) {
        self.firstName = cnContact.givenName
        self.lastName = cnContact.familyName
        self.phoneNumber = cnContact.phoneNumbers.first?.value.stringValue ?? ""
        if firstName.isEmpty || phoneNumber.isEmpty { return nil }
    }
    
    var hashValue: Int {
        return self.fullName.hashValue
    }
    
    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.fullName == rhs.fullName && lhs.phoneNumber == rhs.phoneNumber
    }
}
