//
//  AnnotationType.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 19/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
import VenuesModel
import MapKit

extension AnnotationType {
    /// Get marker or pin annotation views 
    public func getPinAnnotationView(in mapView: MKMapView, with annotation: MKAnnotation, image: UIImage? = nil) -> MKAnnotationView? {
        switch self {
        case .pin:
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: self.rawValue)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: self.rawValue)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let disclosureView =  UIButton(type: .detailDisclosure)
                disclosureView.tintColor = UIColor.eventogyTheme
                view.rightCalloutAccessoryView = disclosureView as UIView
                view.image = nil
                view.pinTintColor = UIColor.eventogyTheme
                let detailLabel = UILabel()
                detailLabel.numberOfLines = 0
                detailLabel.backgroundColor = .clear
                detailLabel.font = detailLabel.font.withSize(12)
                if let subtitle = annotation.subtitle {
                    detailLabel.text = subtitle
                }
                view.detailCalloutAccessoryView = detailLabel
            }
            return view
        case .marker:
            var view: MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: self.rawValue)
                as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: self.rawValue)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let disclosureView =  UIButton(type: .detailDisclosure)
                disclosureView.tintColor = UIColor.eventogyTheme
                view.rightCalloutAccessoryView = disclosureView as UIView
                view.image = nil
                view.glyphImage = image
                view.markerTintColor = UIColor.eventogyTheme
                
                let detailLabel = UILabel()
                detailLabel.numberOfLines = 0
                detailLabel.backgroundColor = .clear
                detailLabel.font = detailLabel.font.withSize(12)
                if let subtitle = annotation.subtitle {
                    detailLabel.text = subtitle
                }
                view.detailCalloutAccessoryView = detailLabel
            }
            return view
        }
    }
}
