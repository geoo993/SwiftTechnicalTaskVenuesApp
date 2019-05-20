//
//  Venue.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
import VenuesCore

public struct Venue: Codable {
    public let id: String
    public let name: String
    public let address: String
    public let country: String
    public let distance: Double
    public let latitude: Double
    public let longitude: Double
    public init(data: [String: Any]) {
        self.id = data["id"] as! String
        self.name = (data["name"] as! String).capitalizingFirstLetter()
        self.address = data["address"] as! String
        self.country = (data["country"] as! String).capitalizingFirstLetter()
        self.distance = data["distance"] as! Double
        self.latitude = data["latitude"] as! Double
        self.longitude = data["longitude"] as! Double
    }
}

extension Venue: CustomStringConvertible {
    public var description: String {
        return
            " id: \(id)\n" +
                " name: \(name)\n" +
                " address: \(address)\n" +
                " country: \(country)\n" +
                " distance: \(distance)\n" +
                " latitude: \(latitude)\n" +
                " longitude: \(longitude)\n\n"
    }
}
