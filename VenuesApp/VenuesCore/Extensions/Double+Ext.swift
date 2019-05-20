//
//  Double+Ext.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import Foundation

extension Double {
 
    public var kilometersToEquatorLatitudeDegrees: Double {
        return self / Double(110.567)
    }
    
    public var kilometersToPoleLatitudeDegrees: Double {
        return self / Double(111.699)
    }
}
