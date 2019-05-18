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

    @IBOutlet weak var mapView: MKMapView!
    
    // Mark: - Main properties
    
    
    // Mark: Locatiion properties
    private let locationManager = LocationManager.shared
    private var currentLocation: CLLocation?
    private let regionRadius: CLLocationDistance = 1000
    
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
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        if let userLocation = mapView.userLocation.location {
            centerOnRegion(with: userLocation)
        }
        
        
        //mapView.setRegion(region, animated: true)
        //mapView.add(polyLine())
        //mapView.addOverlays(multicolorPolyline())
        
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
    
    // MARK: Fetch venues data at location
    func searchVenues(at location: CLLocation) {
        FoursquareAPI.shared.fetchVenues(at: location.coordinate, completion: { [weak self] venuesData in
            guard let this = self else { return }
            for venue in venuesData {
                print(venue.summary)
            }
        })
    }
    
    // MARK: Center user on region
    func centerOnRegion(with location: CLLocation) {
//        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
//                                                  latitudinalMeters: regionRadius,
//                                                  longitudinalMeters: regionRadius)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        searchVenues(at: location)
    }
    
    func annotate(on location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "George"
        annotation.subtitle = "Current location"
        mapView.addAnnotation(annotation)
    }

}

// MARK: MapView Delegate
extension VenuesMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for annotationView in views {
            if annotationView.annotation is MKUserLocation {
            }
        }
    }
    
    func addHeadingViewToAnnotationView(annotationView: MKAnnotationView) {

    }

}


// MARK: - CLLocationManagerDelegate
extension VenuesMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to center user on region
            if let userLocation = locations.last {
                print(userLocation.coordinate.longitude, userLocation.coordinate.latitude)
                centerOnRegion(with: userLocation)
            }
        }
        
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
}
