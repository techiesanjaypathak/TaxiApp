//
//  LocationHandler.swift
//  TaxiApp
//
//  Created by SanjayPathak on 25/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {

    static let shared = LocationHandler()
    var locationManager: CLLocationManager!

    private override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        enableLocationServices()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }

    // MARK: - Location Services

    func enableLocationServices() {

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            debugPrint("Not determined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            debugPrint("Auth always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            debugPrint("Auth when in use")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}
