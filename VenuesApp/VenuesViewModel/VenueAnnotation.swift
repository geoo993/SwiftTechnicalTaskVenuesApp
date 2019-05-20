//
//  VenueAnnotation.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
import VenuesModel
import MapKit

public class VenueAnnotation: NSObject, MKAnnotation {
    public let title: String?
    public var imageUrl: String?
    public let id: String
    public let name: String
    public let address: String
    public let coordinate: CLLocationCoordinate2D
    public init(venue: Venue) {
        self.id = venue.id
        self.title = venue.name
        self.name = venue.name
        self.address = venue.address
        self.coordinate = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
        self.imageUrl = nil
        super.init()
    }
    
    public var subtitle: String? {
        return address
    }
}
