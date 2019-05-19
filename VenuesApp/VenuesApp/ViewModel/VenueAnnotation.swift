//
//  VenueAnnotation.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import MapKit

class VenueAnnotation: NSObject, MKAnnotation {
    let title: String?
    var imageUrl: String?
    let name: String
    let foursquareId: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    init(venue: Venue) {
        self.title = venue.name
        self.foursquareId = venue.id
        self.name = venue.name
        self.address = venue.address
        self.coordinate = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
        self.imageUrl = nil
        super.init()
    }
    
    var subtitle: String? {
        return address
    }
    
    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        return mapItem
    }
}
