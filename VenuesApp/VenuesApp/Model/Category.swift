//
//  Category.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 19/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

struct Category: Codable, Hashable {
    var id: String
    var name: String
    var shortName: String
    init(data: [String: Any]) {
        self.id = data["id"] as! String
        self.name = (data["name"] as! String).capitalizingFirstLetter()
        self.shortName = (data["shortName"] as! String).capitalizingFirstLetter()
    }
}
func ==(cat1: Category, cat2: Category) -> Bool {
    return cat1.id == cat2.id && cat1.name == cat2.name
}

extension Category: CustomStringConvertible {
    var description: String {
        return
            " id: \(id)\n" +
            " name: \(name)\n" +
            " shortName: \(shortName)\n"
    }
}
