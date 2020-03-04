//
//  Trip.swift
//  TaxiApp
//
//  Created by SanjayPathak on 04/03/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import Foundation
import CoreLocation

enum TripStatus: Int {
    case requested
    case accepted
    case inProgress
    case completed
}

struct Trip {

    // MARK: - Properties

    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    let passengerID: String
    var driverID: String?
    var status: TripStatus!

    // MARK: - Lifecycle

    init(passengerUID: String, dictionary: [String: Any]) {
        passengerID = passengerUID

        guard let startCoordinates = dictionary["startCoordinates"] as? NSArray else { return }
        guard let finishCoordinates = dictionary["destinationCoordinates"] as? NSArray else { return }

        guard let startCoordinateLatitude = startCoordinates[0] as? CLLocationDegrees else { return }
        guard let startCoordinateLongitude = startCoordinates[1] as? CLLocationDegrees else { return }

        guard let finishCoordinatesLatitude = finishCoordinates[0] as? CLLocationDegrees else { return }
        guard let finishCoordinatesLongitude = finishCoordinates[1] as? CLLocationDegrees else { return }

        pickupCoordinates = CLLocationCoordinate2D(latitude: startCoordinateLatitude,
                                                   longitude: startCoordinateLongitude)
        destinationCoordinates = CLLocationCoordinate2D(latitude: finishCoordinatesLatitude,
                                                        longitude: finishCoordinatesLongitude)

        if let driverID = dictionary["startCoordinates"] as? String {
            self.driverID = driverID
        }

        guard let tripStatusRawValue = dictionary["tripStatus"] as? Int else { return }
        status = TripStatus(rawValue: tripStatusRawValue)
    }
}
