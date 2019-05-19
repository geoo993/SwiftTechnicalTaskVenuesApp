//
//  AnnotationType.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 19/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
import MapKit

enum AnnotationType: String {
    case marker = "Marker"
    case pin = "Pin"
}

extension AnnotationType {
    func getPinAnnotationView(in mapView: MKMapView, with annotation: VenueAnnotation) -> MKAnnotationView? {
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
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
                view.image = nil
                view.pinTintColor = UIColor.eventogyTheme
                let detailLabel = UILabel()
                detailLabel.numberOfLines = 0
                detailLabel.font = detailLabel.font.withSize(12)
                detailLabel.text = annotation.subtitle
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
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
                view.image = nil
                view.glyphImage = UIImage(named: "Flag")
                view.markerTintColor = UIColor.eventogyTheme
                
                let detailLabel = UILabel()
                detailLabel.numberOfLines = 0
                detailLabel.font = detailLabel.font.withSize(12)
                detailLabel.text = annotation.subtitle
                view.detailCalloutAccessoryView = detailLabel
            }
            return view
        }
    }
}
