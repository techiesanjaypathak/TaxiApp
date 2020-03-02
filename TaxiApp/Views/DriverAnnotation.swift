//
//  DriverAnnotation.swift
//  TaxiApp
//
//  Created by SanjayPathak on 26/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    
    let uid:String
    dynamic var coordinate: CLLocationCoordinate2D
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateDriverPosition(withLocationCoordinate locationCoordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.coordinate = locationCoordinate
        }
    }
}
