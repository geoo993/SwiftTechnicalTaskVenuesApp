//
//  Venue.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
struct Category: Codable {
    let name: String
    let iconUrl: String
}
struct Venue: Codable {
    let id: String
    let name: String
    let categories: [Category]
    let country: String
    let latitude: Double
    let longitude: Double
    init(data: [String: Any]) {
        self.id = data["id"] as! String
        self.name = data["name"] as! String
        self.categories = data["categories"] as! [Category]
        self.country = data["country"] as! String
        self.latitude = data["latitude"] as! Double
        self.longitude = data["longitude"] as! Double
    }
}

extension Venue: CustomStringConvertible {
    var description: String {
        return
            " id: \(id)\n" +
                " name: \(name)\n" +
                " country: \(country)\n" +
                " category: \(categories.first?.name ?? "")\n" +
                " iconUrl: \(categories.first?.iconUrl ?? "")\n" +
                " latitude: \(latitude)\n" +
                " longitude: \(longitude)\n\n"
    }
}
