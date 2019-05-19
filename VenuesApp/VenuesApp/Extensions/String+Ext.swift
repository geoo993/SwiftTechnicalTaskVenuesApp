//
//  String+Ext.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 19/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import Foundation
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
