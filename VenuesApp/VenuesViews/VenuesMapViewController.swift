//
//  VenuesMapViewController.swift
//  VenuesApp
//
//  Created by GEORGE QUENTIN on 17/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
import VenuesModel
import VenuesViewModel
import VenuesServices
import UIKit
import MapKit

class VenuesMapViewController: VenuesMapSearchViewController {
    
    // Mark: the maximum span radius for Foursquare is 100,000 meters.
    private let spanDistance = Measurement<UnitLength>(value: 1.2, unit: .miles)
    
    // Mark: Locatiion properties
    private let locationManager = LocationManager.shared
    var currentPlace: Place?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorizationStatus()
        setupLocationManager()
        setupMapView()
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
        venueImageView.isHidden = true
        
        // Go to the selected place location
        if let place = currentPlace {
            let location = CLLocationCoordinate2D(latitude: place.latitude,
                                                  longitude: place.longitude)
             centerOnRegion(with: location, searchType: .categories)
             mapView.addAnnotation(PlaceAnnotation(place: place))
        }
        // fetch the nearby venues of selected venue of interest
        searchVenuesOf = { [weak self] category in
            guard let this = self, let place = this.currentPlace else { return }
            let location = CLLocationCoordinate2D(latitude: place.latitude,
                                                       longitude: place.longitude)
            this.centerOnRegion(with: location, searchType: .venues(category: category))
        }
    }

    // MARK: Setup Location Manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
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
                this.mapView.addAnnotation(VenueAnnotation(venue: venue))
            }
            this.venuesOfInterest = venuesData
        }
    }
    
    // MARK: Fetch photos of selected venue using venueId
    func searchVenuePhotos(of venue: VenueAnnotation) {
        FoursquareAPI.shared.fetchVenuePhotos(using: venue.id, completion: { [weak self] photosData in
            guard let this = self, let photoUrl = photosData.first else { return }
            venue.imageUrl = photoUrl
            this.setVenueImage(with: photoUrl)
        })
    }
    
    func setVenueImage(with imageUrl: String) {
        NotificationCenter.default
            .post(name: .downloadImageNotification, object: self,
                  userInfo: ["venueImageView": venueImageView as Any, "iconUrl" : imageUrl])
    }
    
    func removeAnotations() {
        self.mapView.annotations.forEach {
            if ($0 is MKUserLocation) == false && ($0 is PlaceAnnotation) == false {
                self.mapView.removeAnnotation($0)
            }
        }
    }
}

// MARK: MapView Delegate
extension VenuesMapViewController: MKMapViewDelegate {
    
    // MARK: - Annotate loactions with pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is PlaceAnnotation:
            let annotation = annotation as! PlaceAnnotation
            let annotaionImage = UIImage(named: "Flag", in: ViewsBundle.bundle, compatibleWith: nil)
            return AnnotationType.marker.getPinAnnotationView(in: mapView, with: annotation, image: annotaionImage)
        case is VenueAnnotation:
            let annotation = annotation as! VenueAnnotation
            return AnnotationType.pin.getPinAnnotationView(in: mapView, with: annotation)
        default: return nil
        }
    }
    
    // MARK: - Show image of selected venue
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let venueAnnotaion = view.annotation as? VenueAnnotation {
            venueImageView.isHidden = false
            if let imageUrl = venueAnnotaion.imageUrl {
                setVenueImage(with: imageUrl)
            } else {
                searchVenuePhotos(of: venueAnnotaion)
            }
        }
    }
    
    // MARK: - Hide image of selected venue
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        venueImageView.isHidden = true
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
        //defer { currentLocation = locations.last?.coordinate }
        if currentPlace == nil {
            // if we do not have a currentLocation then set to default user location
            if let userLocation = locations.last {
                currentPlace = Place(data:
                    ["name": "User", "address":"My Address",
                    "latitude": userLocation.coordinate.latitude, "longitude": userLocation.coordinate.longitude])
                centerOnRegion(with: userLocation.coordinate, searchType: .categories)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
