//
//  Category.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 19/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

public struct CategoryResponse {
    
    public let categories: [Category]
    enum CodingKeys: String, CodingKey {
        case response
    }
    enum CategoriesLevelOneCodingKeys: String, CodingKey {
        case categories
    }
}
extension CategoryResponse: Decodable
{
    struct Caterories: Decodable {
        let categories: [Category]
        enum CodingKeys: String, CodingKey { case categories }
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let categoryList = try container.decode([Category].self, forKey: .categories)
            categories = categoryList
        }
    }
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let categoriesOne = try container.nestedContainer(keyedBy: CategoriesLevelOneCodingKeys.self, forKey: .response)
        let categoryList = try categoriesOne.decode([Category].self, forKey: .categories)
        let categoriesListChildren = try categoriesOne.decode([Caterories].self, forKey: .categories)
        categories = categoryList + categoriesListChildren.compactMap({ $0.categories.compactMap({ $0 }) }).flatMap({ $0 })
    }
}

public struct Category: Hashable {
    public var id: String
    public var name: String
    public var shortName: String
    enum CodingKeys: String, CodingKey {
        case id, name, shortName
    }
}
extension Category: Decodable
{
    public init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.name = (data["name"] as? String ?? "").capitalizingFirstLetter()
        self.shortName = (data["shortName"] as? String ?? "").capitalizingFirstLetter()
    }
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        shortName = try container.decode(String.self, forKey: .shortName)
    }
}
public func ==(cat1: Category, cat2: Category) -> Bool {
    return cat1.id == cat2.id && cat1.name == cat2.name
}

extension Category: CustomStringConvertible {
    public var description: String {
        return
            " id: \(id)\n" +
            " name: \(name)\n" +
            " shortName: \(shortName)\n"
    }
}
