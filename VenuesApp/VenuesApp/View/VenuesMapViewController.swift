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
    // the maximum span radius for Foursquare is 100,000 meters.
    private let spanDistance = Measurement<UnitLength>(value: 0.8, unit: .miles)
    
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
        let metersRadius = spanDistance.converted(to: .meters).value
        FoursquareAPI.shared.fetchVenues(with: metersRadius, at: location.coordinate, completion: { [weak self] venuesData in
            guard let this = self else { return }
            for venue in venuesData {
                print(venue.description)
                this.annotate(venue: venue)
            }
            this.updateVenues(with: venuesData)
        })
    }
    
    // MARK: Center user on region
    func centerOnRegion(with location: CLLocation) {
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
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
        searchVenues(at: location)
    }
    
    func annotate(venue: Venue) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
        annotation.title = venue.name
        annotation.subtitle = venue.categories.first?.name ?? ""
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
