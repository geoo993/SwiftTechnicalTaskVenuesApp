//
//  VenuesSearchResultCell.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
import VenuesModel
import UIKit

@IBDesignable
final class VenuesSearchResultCell: UITableViewCell {
    @IBInspectable private (set) var selectedColor: UIColor = UIColor.lightGray
    @IBInspectable private (set) var hightlightedColor: UIColor = UIColor.darkGray
    
    @IBOutlet private weak var venueImageView: UIImageView!
    @IBOutlet private weak var venueImageContainer: UIView!
    @IBOutlet private weak var venueLabel: UILabel!
    @IBOutlet private weak var venueCategoryLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setCategory(with category: VenuesModel.Category) {
        venueLabel.text = category.name
        venueCategoryLabel.text = category.shortName
        venueImageContainer.layer.cornerRadius = venueImageContainer.frame.height / 2
        venueImageView.layer.cornerRadius = venueImageView.frame.height / 2
    }
}
