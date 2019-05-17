//
//  NSAttributedString+Ext.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 17/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import UIKit

extension NSAttributedString {

    var attributes: [NSAttributedString.Key: Any] {
        guard length > 0 else { return [:] }
        return attributes(at: 0,
                          longestEffectiveRange: nil,
                          in: NSRange(location: 0, length: length))
    }
    var font: UIFont {
        guard attributes.keys.contains(.font) else { return UIFont.systemFont(ofSize: 17) }
        return attributes[NSAttributedString.Key.font] as! UIFont
    }
    var backgroundColor: UIColor? {
        guard attributes.keys.contains(.backgroundColor) else { return nil }
        return attributes[NSAttributedString.Key.backgroundColor] as? UIColor
    }
    
    var textColor: UIColor? {
        guard attributes.keys.contains(.foregroundColor) else { return nil }
        return attributes[NSAttributedString.Key.foregroundColor] as? UIColor
    }
    
}
