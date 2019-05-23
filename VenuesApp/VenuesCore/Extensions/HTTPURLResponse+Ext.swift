//
//  HTTPURLResponse+Ext.swift
//  VenuesCore
//
//  Created by GEORGE QUENTIN on 23/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

extension HTTPURLResponse {
    public convenience init?(url: URL, statusCode: Int) {
        self.init(url: url, statusCode: statusCode,
             httpVersion: nil, headerFields: nil)
    }
}
