//
//  Place.swift
//  VenuesModel
//
//  Created by GEORGE QUENTIN on 20/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

public struct Place {
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public init(data: [String: Any]) {
        self.name = (data["name"] as! String).capitalizingFirstLetter()
        self.address = data["address"] as! String
        self.latitude = data["latitude"] as! Double
        self.longitude = data["longitude"] as! Double
    }
}
extension Place: CustomStringConvertible {
    public var description: String {
        return
                " name: \(name)\n" +
                " address: \(address)\n" +
                " latitude: \(latitude)\n" +
                " longitude: \(longitude)\n\n"
    }
}
