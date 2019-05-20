//
//  VenueSearchLoactionController.swift
//  VenuesViews
//
//  Created by GEORGE QUENTIN on 20/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import UIKit
import CoreLocation
import VenuesModel
import VenuesServices

class VenueSearchLoactionController: UIViewController {
    // Mark: - Main properties
    private var places: [Place]?
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var searchMessageLabel: UILabel!
    @IBAction func search(_ sender: UIButton) {
        if let searchText = textfield.text {
            GooglePlaceAPI.shared.fetchLocations(of: searchText) { [weak self] (places) in
                if !places.isEmpty {
                    self?.places = places
                    self?.performSegue(withIdentifier: Constants.segueIdentifier, sender: self)
                } else {
                    self?.searchMessageLabel.isHidden = false
                }
            }
        }
    }
    // Mark: - Show navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchMessageLabel.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    // Mark: - Hide navigation bar and keyboard
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.textfield.endEditing(true)
        self.textfield.resignFirstResponder()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // Mark: - Launch the map screen after a location is found
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destination as? VenuesMapViewController,
            let places = self.places, let place = places.first {
            mapViewController.loadView()
            mapViewController.loadViewIfNeeded()
            mapViewController.view.setNeedsLayout()
            mapViewController.view.layoutIfNeeded()
            mapViewController.currentPlace = place
            mapViewController.viewDidLoad()
        }
    }
}

extension VenueSearchLoactionController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch:UITouch = touches.first else
        {
            return
        }
        if touch.view != textfield
        {
            self.textfield.endEditing(true)
            self.textfield.resignFirstResponder()
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchMessageLabel.isHidden = true
    }
   
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }

}
