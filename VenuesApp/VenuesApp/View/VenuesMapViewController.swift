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
    private let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    func setupMapView() {
        // Set the map view's delegate
        mapView.delegate = self
        
        // Allow the map to display the user's location
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        
        //mapView.setRegion(region, animated: true)
        //mapView.add(polyLine())
        //mapView.addOverlays(multicolorPolyline())
        
    }
    
    func setupLocations() {
        locationManager.delegate = self
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
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
        
    }
}
