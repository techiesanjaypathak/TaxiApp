//
//  HomeController.swift
//  TaxiApp
//
//  Created by SanjayPathak on 14/02/20.
//  Copyright © 2020 Sanjay. All rights reserved.
//

import UIKit
import Firebase
import MapKit

private let reusableLocationCellIdentifier = "LocationCell"
private let driverAnnotation = "DriverAnnotation"

class HomeController: UIViewController {

    enum ActionButtonState {
        case showMenu
        case dismissLocationSelectionView

        init() {
            self = .showMenu
        }
    }

    // MARK: - Properties
    private let mapView = MKMapView()
    private let signOutButton: AuthButton = {
        let button = AuthButton()
        button.setTitle("Sign Out", for: .normal)
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
    private let actionButton: UIButton = {
       let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    private var actionButtonState = ActionButtonState()
    private let locationManager = LocationHandler.shared.locationManager
    private let locationInputActivationView: LocationInputActivationView = {
        let view = LocationInputActivationView()
        return view
    }()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                showLocationActivationView()
            }
        }
    }
    private var searchResults: [MKPlacemark] = []
    private var route: MKRoute?
    private let rideActionView = RideActionView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }

    // MARK: - API

    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            configure()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser?.uid == nil {
            presentLoginController()
        } else {
//            self.mapView.showAnnotations(mapView.annotations, animated: true)
            self.mapView.zoomToFit(annotations: mapView.annotations)
        }
    }

    // MARK: - Selectors

    @objc func signOut() {
        do {
            try Auth.auth().signOut()
            presentLoginController()
        } catch {
            debugPrint("Error signing out")
        }
    }

    @objc func actionButtonPressed() {
        switch actionButtonState {
        case .showMenu:
            print("DEBUG:: Show menu")
        case .dismissLocationSelectionView:
            removeAnnotationsAndOverlay()
//            self.mapView.showAnnotations(mapView.annotations, animated: true)
            self.mapView.zoomToFit(annotations: mapView.annotations)
            showLocationActivationView { _ in
                self.configureActionButton(state: .showMenu)
            }
            self.displayRideActionView(false)
        }
    }

    // MARK: - Helper Functions

    func configure() {
        configureUI()
        fetchUserData()
    }

    func configureUI() {
        configureMapView()
        view.addSubview(signOutButton)
        signOutButton.anchor(bottom: view.bottomAnchor, right: view.rightAnchor, paddingBottom: 40, paddingRight: 16)
        showActionButton()
    }

    func displayRideActionView(_ shouldShow: Bool) {
        if shouldShow {
            view.addSubview(rideActionView)
            setRideActionViewBelowScreen()
            UIView.animate(withDuration: 1) {
                self.rideActionView.anchor(left: self.view.leftAnchor,
                                           bottom: self.view.safeAreaLayoutGuide.bottomAnchor,
                                           right: self.view.rightAnchor,
                                           height: 250)
                self.view.layoutIfNeeded()
            }
        } else {
            self.rideActionView.removeFromSuperview()
        }
    }

    func setRideActionViewBelowScreen() {
        self.rideActionView.anchor(left: self.view.leftAnchor,
        bottom: self.view.safeAreaLayoutGuide.bottomAnchor,
        right: self.view.rightAnchor,
        paddingBottom: -250,
        height: 250)
        self.view.layoutIfNeeded()
    }

    func configureActionButton(state: ActionButtonState) {
        switch state {
        case .showMenu:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonState = .showMenu
        case .dismissLocationSelectionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonState = .dismissLocationSelectionView
        }
    }

    func showActionButton() {
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            left: view.safeAreaLayoutGuide.leftAnchor,
                            paddingTop: 10, paddingLeft: 10,
                            width: 50, height: 50)
    }

    func configureMapView() {
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }

    func presentLoginController() {
        let loginController = LoginController()
        let navigationController = UINavigationController(rootViewController: loginController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }

    func showLocationInputView() {
        locationInputActivationView.removeFromSuperview()
        locationInputView.delegate = self
        locationInputView.alpha = 0
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }, completion: { _ in
            self.view.addSubview(self.tableView)
            self.configureTableView()
            let tableHeight = self.view.frame.size.height - self.locationInputView.frame.size.height
            self.tableView.anchor(left: self.view.leftAnchor, right: self.view.rightAnchor, height: tableHeight)
            let topAnchorConstraint = self.tableView.topAnchor
                                        .constraint(equalTo: self.locationInputView.bottomAnchor,
                                                    constant: tableHeight)
            topAnchorConstraint.isActive = true
            // Here we need to call layoutIfNeeded on view once before and after to see the effect.
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5) {
                topAnchorConstraint.constant = 1
                self.view.layoutIfNeeded()
            }
        })
    }

    func removeLocationInputView(completion: ((Bool) -> Void)? = nil) {
        tableView.removeFromSuperview()
        locationInputView.removeFromSuperview()
        UIView.animate(withDuration: 0.1, animations: {
        }, completion: completion)
    }

    func showLocationActivationView(completion: ((Bool) -> Void)? = nil) {
        removeLocationInputView()
        locationInputActivationView.delegate = self
        locationInputActivationView.alpha = 0
        view.addSubview(locationInputActivationView)
        locationInputActivationView.anchor(top: actionButton.bottomAnchor,
                                           left: view.leftAnchor, right: view.rightAnchor,
                                           paddingTop: 0, paddingLeft: 20, paddingRight: 20,
                                           height: 40)
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputActivationView.alpha = 1
        }, completion: completion)
    }

    func configureTableView() {
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: reusableLocationCellIdentifier)
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

extension HomeController: LocationInputActivationViewDelegate {
    // MARK: - LocationInputActivationViewDelegate
    func locationInputActivationViewTouchAction() {
        showLocationInputView()
    }
}

extension HomeController: LocationInputViewDelegate {
    // MARK: - LocationInputViewDelegate
    func backAction() {
        showLocationActivationView()
    }

    func searchPlaces(forQueryString queryString: String) {
        self.searchLocalPlaces(naturalLanguageQuery: queryString)
    }
}

extension HomeController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : self.searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reusableLocationCellIdentifier,
                                                    for: indexPath) as? LocationTableViewCell {
            if indexPath.section == 0 {
                cell.title.text = "123 ABC Street"
                cell.subTitle.text = "123 ABC Street"
            } else {
                cell.placemark = searchResults[indexPath.row]
            }
                return cell
        } else {
            return UITableViewCell()
        }

    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let selectedPlacemark = searchResults[indexPath.row]
            guard let selectedCoordinate = selectedPlacemark.location?.coordinate else { return }

            removeLocationInputView { _ in
                self.rideActionView.delegate = self
                self.rideActionView.destinationPlacemark = selectedPlacemark
                self.displayRideActionView(true)

                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = selectedCoordinate
                self.mapView.addAnnotation(pointAnnotation)
                self.mapView.selectAnnotation(pointAnnotation, animated: true)

                let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
//                self.mapView.showAnnotations(annotations, animated: true)
                self.mapView.zoomToFit(annotations: annotations)
            }

            generatePolyline(toDestination: selectedPlacemark)
            configureActionButton(state: .dismissLocationSelectionView)
        }
    }
}

extension HomeController {
    // MARK: API Calls
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: uid, completion: { (user) in
            self.user = user
        })
    }

    func fetchDrivers() {
        guard let location = LocationHandler.shared.locationManager.location else { return }
        Service.shared.fetchDrivers(location: location, completion: { (driver) in
            var isDriverVisible: Bool {
                self.mapView.annotations.contains { (annotation) -> Bool in
                    if let driverAnnotation = annotation as? DriverAnnotation {
                        if driverAnnotation.uid == driver.uid {
                            guard  let coordinate = driver.location?.coordinate else {
                                return false
                            }
                            driverAnnotation.updateDriverPosition(withLocationCoordinate: coordinate)
                            return true
                        }
                    }
                    return false
                }
            }

            if !isDriverVisible {
                guard let driverLocation = driver.location else { return }
                let driverAnnotation = DriverAnnotation(uid: driver.uid, coordinate: driverLocation.coordinate)
                self.mapView.addAnnotation(driverAnnotation)
            }
        })
    }
}

extension HomeController: MKMapViewDelegate {
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: driverAnnotation)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .systemBlue
            lineRenderer.lineWidth = 5
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

extension HomeController {
    // MARK: - Map View Helper Methods
    func searchLocalPlaces(naturalLanguageQuery: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = naturalLanguageQuery

        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
                // Handle Error
            } else if response != nil {
                // Populate table
                var placemarks: [MKPlacemark] = []
                if let mapItems = response?.mapItems {
                    placemarks = mapItems.map { (item) in
                        item.placemark
                    }
                    self.searchResults = placemarks
                } else {
                    self.searchResults = []
                }
                self.tableView.reloadData()
            } else {
                // Load Empty Table View
                self.searchResults = []
                self.tableView.reloadData()
            }
        }
    }

    func generatePolyline(toDestination destination: MKPlacemark) {
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.destination = MKMapItem(placemark: destination)
        directionRequest.transportType = .automobile

        let direction = MKDirections(request: directionRequest)
        direction.calculate { (response, _) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }

    func removeAnnotationsAndOverlay() {
        mapView.annotations.forEach { (annotation) in
            if let pointAnnotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(pointAnnotation)
            }
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
}

extension HomeController: RideActionDelegate {
    func takeRide(_ sender: RideActionView) {
        guard let startCoordinate = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinate = sender.destinationPlacemark?.coordinate else { return }
        Service.shared.uploadRide(startCoordinates: startCoordinate,
                                  destinationCoordinates: destinationCoordinate,
                                  completion: { (err, _) in
            if let error = err {
                print("DEBUG: Error saving trip \(error)")
            } else {
                print("DEBUG: Trip details saved successfully.")
            }
        })
    }
}
