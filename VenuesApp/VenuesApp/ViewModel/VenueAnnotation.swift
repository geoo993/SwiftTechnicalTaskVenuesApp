//
//  VenueAnnotation.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import MapKit

class VenueAnnotation: NSObject, MKAnnotation {
    let name: String
    let detail: String
    let coordinate: CLLocationCoordinate2D
    
    init(venue: Venue) {
        self.name = venue.name
        self.detail = venue.description
        self.coordinate = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
        super.init()
    }
}
