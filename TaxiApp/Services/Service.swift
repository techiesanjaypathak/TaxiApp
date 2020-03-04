//
//  Service.swift
//  
//
//  Created by SanjayPathak on 18/02/20.
//

import Foundation
import Firebase
import CoreLocation
import GeoFire

let kDbRef = Database.database().reference()
let kRefUsers = kDbRef.child("Users")
let kRefDriverLocations = kDbRef.child("DriverLocations")
let kRefTrips = kDbRef.child("Trips")

class Service {

    static let shared = Service()

    func fetchUserData(uid: String, completion : @escaping (User) -> Void) {
        kRefUsers.child(uid).observeSingleEvent(of: .value) { (snapShot) in
            guard let userInfo = snapShot.value as? [String: Any] else { return }
            let user = User(uid: snapShot.key, dictionary: userInfo)
            completion(user)
        }
    }

    func fetchDrivers(location: CLLocation, completion: @escaping (User) -> Void) {
        let geoFire = GeoFire(firebaseRef: kRefDriverLocations)
        kRefDriverLocations.observe(.value) { (_) in
            geoFire.query(at: location, withRadius: 50.0).observe(.keyEntered, with: { (uid, location) in
                self.fetchUserData(uid: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }

    func uploadRide(startCoordinates: CLLocationCoordinate2D,
                    destinationCoordinates: CLLocationCoordinate2D,
                    completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let startCoordinates = [startCoordinates.latitude, startCoordinates.longitude]
        let destinationCoordinates = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        let values = [  "startCoordinates": startCoordinates,
                        "destinationCoordinates": destinationCoordinates,
                        "tripStatus": TripStatus.requested.rawValue
            ] as [String: Any]
        kRefTrips.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
}
