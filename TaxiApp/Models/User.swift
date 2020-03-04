//
//  User.swift
//  TaxiApp
//
//  Created by SanjayPathak on 25/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import Foundation
import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    let uid: String
    let fullname: String
    let email: String
    let accountType: AccountType
    var location: CLLocation?
}

extension User {
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = AccountType(rawValue: dictionary["accountType"] as? Int ?? 0) ?? AccountType.passenger
    }
}
