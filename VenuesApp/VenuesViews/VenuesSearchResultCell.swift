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
class VenuesSearchResultCell: UITableViewCell {
    @IBInspectable var selectedColor: UIColor = UIColor.lightGray
    @IBInspectable var hightlightedColor: UIColor = UIColor.darkGray
    
    @IBOutlet weak var venueImageView: UIImageView!
    @IBOutlet weak var venueImageContainer: UIView!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var venueCategoryLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
