//
//  VenueOverlay.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//


import MapKit

class VenueOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(venue: Venue) {
        coordinate = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
        boundingMapRect = MKMapRect(x: 0, y: 0, width: 0, height: 0)
        super.init()
    }
}
