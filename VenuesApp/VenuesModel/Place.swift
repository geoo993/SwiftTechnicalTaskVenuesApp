//
//  Place.swift
//  VenuesModel
//
//  Created by GEORGE QUENTIN on 20/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
public struct Candidate {
    public let places: [Place]
    enum CodingKeys: String, CodingKey
    {
        case places = "candidates"
    }
}
extension Candidate: Decodable
{
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        places = try container.decode([Place].self, forKey: .places)
    }
}

public struct Place {
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    
    enum CodingKeys: String, CodingKey
    {
        case name
        case address = "formatted_address"
        case geometry
    }
    enum GeometryCodingKeys: String, CodingKey {
        case location
    }
    enum LocationCodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}
extension Place: Decodable
{
    public init(data: [String: Any]) {
        self.name = (data["name"] as? String ?? "").capitalizingFirstLetter()
        self.address = data["address"] as? String ?? ""
        self.latitude = data["latitude"] as? Double ?? 0.0
        self.longitude = data["longitude"] as? Double ?? 0.0
    }
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        let geometry = try container.nestedContainer(keyedBy: GeometryCodingKeys.self, forKey: .geometry)
        let location = try geometry.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
        latitude = try location.decode(Double.self, forKey: .latitude)
        longitude = try location.decode(Double.self, forKey: .longitude)
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

