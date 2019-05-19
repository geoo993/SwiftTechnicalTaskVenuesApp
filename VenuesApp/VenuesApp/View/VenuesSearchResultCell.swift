//
//  VenuesSearchResultCell.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

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
  
    func setVenue(with venue: Venue) {
        venueLabel.text = venue.name.capitalizingFirstLetter()
        if let category = venue.categories.first {
            venueCategoryLabel.text = category.name.capitalizingFirstLetter()
            venueImageContainer.layer.cornerRadius = venueImageContainer.frame.height / 2
            venueImageView.layer.cornerRadius = venueImageView.frame.height / 2
            venueImageView.image = UIImage(named: "place-marker")
            
//            NotificationCenter.default
//                .post(name: .downloadImageNotification, object: self,
//                      userInfo: ["imageView": venueImageView as Any, "iconUrl" : category.iconUrl])
        }
    }
}
