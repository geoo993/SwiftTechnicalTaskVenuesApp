//
//  Photo.swift
//  VenuesModel
//
//  Created by GEORGE QUENTIN on 25/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

public struct PhotoResponse {
    public let photos: [Photo]
    enum CodingKeys: String, CodingKey {
        case response
    }
    enum PhotosCodingKeys: String, CodingKey {
        case photos
    }
    enum ItemCodingKeys: String, CodingKey {
        case items
    }
}
extension PhotoResponse: Decodable
{
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let photosGroup = try container.nestedContainer(keyedBy: PhotosCodingKeys.self, forKey: .response)
        let items = try photosGroup.nestedContainer(keyedBy: ItemCodingKeys.self, forKey: .photos)
        photos = try items.decode([Photo].self, forKey: .items)
    }
}

public struct Photo: Hashable {
    public var id: String
    public var prefix: String
    public var suffix: String
    enum CodingKeys: String, CodingKey {
        case id, prefix, suffix
    }
}
extension Photo: Decodable
{
    public init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.prefix = data["prefix"] as? String ?? ""
        self.suffix = data["suffix"] as? String ?? ""
    }
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        prefix = try container.decode(String.self, forKey: .prefix)
        suffix = try container.decode(String.self, forKey: .suffix)
    }
}

extension Photo {
    public var url: String {
        return prefix + "200x200" + suffix
    }
}
