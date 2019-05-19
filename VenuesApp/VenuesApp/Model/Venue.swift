//
//  Venue.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

struct Venue: Codable {
    let id: String
    let name: String
    let address: String
    let country: String
    let distance: Double
    let latitude: Double
    let longitude: Double
    init(data: [String: Any]) {
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
    var description: String {
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
