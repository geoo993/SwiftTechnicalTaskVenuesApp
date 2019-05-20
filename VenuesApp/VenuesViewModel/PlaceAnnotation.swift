//
//  PlaceAnnotation.swift
//  VenuesViewModel
//
//  Created by GEORGE QUENTIN on 20/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
import VenuesModel
import MapKit

public class PlaceAnnotation: NSObject, MKAnnotation {
    public let title: String?
    public let address: String
    public let coordinate: CLLocationCoordinate2D
    public init(place: Place) {
        self.title = place.name
        self.address = place.address
        self.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        
        super.init()
    }
    public var subtitle: String? {
        return address
    }
}
