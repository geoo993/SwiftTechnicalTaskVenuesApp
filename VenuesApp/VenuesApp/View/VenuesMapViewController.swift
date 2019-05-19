//
//  VenuesMapViewController.swift
//  VenuesApp
//
//  Created by GEORGE QUENTIN on 17/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import UIKit
import MapKit

class VenuesMapViewController: VenuesMapSearchViewController {
    
    // Mark: - Main properties
    private var venuesOfInterest = [Venue]()
    
    // the maximum span radius for Foursquare is 100,000 meters.
    private let spanDistance = Measurement<UnitLength>(value: 1.2, unit: .miles)
    
    // Mark: Locatiion properties
    private let locationManager = LocationManager.shared
    private var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorizationStatus()
        setupLocationManager()
        setupMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Setup Mapview
    func setupMapView() {
        // Set the map view's delegate
        mapView.delegate = self
        
        // Allow the map to display the user's location
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        searchVenuesOf = { [weak self] category in
            guard let this = self, let userLocation = this.currentLocation else { return }
            let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,
                                                       longitude: userLocation.coordinate.longitude)
            this.centerOnRegion(with: location, searchType: .venues(category: category))
        }
    }
    
    // MARK: Setup Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    // MARK: Check for Location Services
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways
            || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
        } else {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: Center user on region
    func centerOnRegion(with location: CLLocationCoordinate2D, searchType: SearchType) {
        /*
         struct MKCoordinateSpan
         You use the delta values in this structure to indicate the desired zoom level of the map, with smaller delta values corresponding to a higher zoom level.
         
         var longitudeDelta: CLLocationDegrees
         The amount of east-to-west distance (measured in degrees) to display for the map region.
         The number of kilometers spanned by a longitude range varies based on the current latitude.
         For example, one degree of longitude spans a distance of approximately 111 kilometers (69 miles) at the equator but shrinks to 0 kilometers at the poles.
         
         var latitudeDelta: CLLocationDegrees
         The amount of north-to-south distance (measured in degrees) to display on the map.
         Unlike longitudinal distances, which vary based on the latitude, one degree of latitude is always approximately 111 kilometers (69 miles).
 */
        let spanKilometers = spanDistance.converted(to: .kilometers).value
        let span = MKCoordinateSpan(latitudeDelta: spanKilometers.kilometersToEquatorLatitudeDegrees,
                                    longitudeDelta: spanKilometers.kilometersToPoleLatitudeDegrees)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    
        switch searchType {
        case .categories:
            searchVenueCategories(at: location)
        case .venues(let category):
            searchVenues(of: category, at: location)
        default: break
        }
    }
    
    // MARK: Fetch venues data at location
    func searchVenueCategories(at location: CLLocationCoordinate2D) {
        FoursquareAPI.shared.fetchVenueCategories(completion:{ [weak self] categoriesData in
            guard let this = self else { return }
            this.updateCategories(with: categoriesData)
        })
    }
    
    // MARK: Fetch venues of particular interest at location
    func searchVenues(of interest: String, at location: CLLocationCoordinate2D) {
        let metersRadius = spanDistance.converted(to: .meters).value
        FoursquareAPI.shared.fetchVenues(using: interest, with: metersRadius, at: location) { [weak self] venuesData in
            guard let this = self else { return }
            
            this.removeAnotations()
            for venue in venuesData {
                //print(venue.description)
                this.addAnnotation(venue: venue)
            }
            this.venuesOfInterest = venuesData
        }
    }
    
    func removeAnotations() {
        self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
            }
        }
    }
    func addAnnotation(venue: Venue) {
        mapView.addAnnotation(VenueAnnotation(venue: venue))
    }

}

// MARK: MapView Delegate
extension VenuesMapViewController: MKMapViewDelegate {
    
    // MARK: - Annotate loactions with pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? VenueAnnotation else { return nil }
        let annotationType = AnnotationType.pin
        return annotationType.getPinAnnotationView(in: mapView, with: annotation)
    }
 
    // // MARK: - Open selected venue on foursquare website
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotationTitle = view.annotation?.title,
            let title = annotationTitle,
            let annotationSubTitle = view.annotation?.subtitle,
            let subTitle = annotationSubTitle,
            let venue = venuesOfInterest.first(where: { $0.name == title && $0.address == subTitle }) {
            FoursquareAPI.shared.openWeb(of: venue.id)
        }
    }
    
}


// MARK: - CLLocationManagerDelegate
extension VenuesMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined         : print("notDetermined")        // location permission not asked for yet
        case .authorizedWhenInUse   : print("authorizedWhenInUse")  // location authorized
        case .authorizedAlways      : print("authorizedAlways")     // location authorized
        case .restricted            : print("restricted")           // TODO: handle
        case .denied                : print("denied")               // TODO: handle
        default: break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        if currentLocation == nil {
            // Zoom to center user on region
            if let userLocation = locations.last {
                centerOnRegion(with: userLocation.coordinate, searchType: .categories)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
