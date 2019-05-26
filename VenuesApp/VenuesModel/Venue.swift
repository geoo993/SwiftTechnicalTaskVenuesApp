//
//  Venue.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
import VenuesCore

public struct VenueResponse {
    
    public let venues: [Venue]
    enum CodingKeys: String, CodingKey {
        case response
    }
    enum GroupsCodingKeys: String, CodingKey {
        case groups
    }
}
extension VenueResponse: Decodable
{
    struct Group: Decodable {
        let items: [Item]
        enum CodingKeys: String, CodingKey { case items }
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            items = try container.decode([Item].self, forKey: .items)
        }
    }
    struct Item: Decodable {
        let venue: Venue
        enum CodingKeys: String, CodingKey { case venue }
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            venue = try container.decode(Venue.self, forKey: .venue)
        }
    }
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let response = try container.nestedContainer(keyedBy: GroupsCodingKeys.self, forKey: .response)
        let groups = try response.decode([Group].self, forKey: .groups)
        venues = groups.compactMap({ $0.items.compactMap({ $0.venue }) }).flatMap({ $0 })
    }
}

public struct Venue {
    public let id: String
    public let name: String
    public let address: String
    public let country: String
    public let distance: Double
    public let latitude: Double
    public let longitude: Double
    enum CodingKeys: String, CodingKey {
        case id, name, location
    }
    enum LocationCodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
        case distance
        case address = "formattedAddress"
        case country
    }
}
extension Venue: Decodable
{
    public init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.name = (data["name"] as? String ?? "").capitalizingFirstLetter()
        self.address = data["address"] as? String ?? ""
        self.country = (data["country"] as? String ?? "").capitalizingFirstLetter()
        self.distance = data["distance"] as? Double ?? 0
        self.latitude = data["latitude"] as? Double ?? 0
        self.longitude = data["longitude"] as? Double ?? 0
    }
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let location = try container.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
        latitude = try location.decode(Double.self, forKey: .latitude)
        longitude = try location.decode(Double.self, forKey: .longitude)
        self.distance = try location.decode(Double.self, forKey: .distance)
        country = try location.decode(String.self, forKey: .country)
        let formattedAddress = try location.decode([String].self, forKey: .address)
        address = formattedAddress.joined(separator: "\n")
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
