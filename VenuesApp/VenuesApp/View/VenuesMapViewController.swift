//
//  VenuesMapViewController.swift
//  VenuesApp
//
//  Created by GEORGE QUENTIN on 17/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import UIKit
import MapKit

class VenuesMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    // Mark: - Main properties
    let mainColor = UIColor.eventogyTheme
    var venues : [String]?
    
    // Mark: - Search bar
    let search = UISearchController(searchResultsController: nil)
    var searchBarFiltered:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupSearchBar()
    }
    
    func setupNavBar() {
        if let navigationController = self.navigationController {
            navigationController.navigationItem.largeTitleDisplayMode = .never
            navigationController.navigationBar.barTintColor = mainColor
        }
    }

    func setupSearchBar() {
        search.searchBar.delegate = self
        search.searchBar.placeholder = "Search for..."
        search.searchBar.backgroundColor = mainColor
        search.searchBar.barTintColor = mainColor
        search.searchBar.barStyle = .black
        search.searchBar.tintColor = .white
        search.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.searchController = search
    }
    
    func searchVenues(of place: String) {
        
    }
    
    func filterVenues(for searchText: String) {
        searchBarFiltered = venues?
            .filter( { $0.lowercased().contains( searchText.lowercased() )}) ?? [String]()
        
    }

}

// MARK: UISearchBarDelegate
extension VenuesMapViewController : UISearchBarDelegate {

    /// Show Cancel button
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    /// Stop editing search bar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        dismissKeyboard(with: searchBar)
    }
    
    /// Hide Cancel
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        dismissKeyboard(with: searchBar)
        
        guard let place = searchBar.text else {
            //Notification "White spaces are not permitted"
            return
        }
        
        searchVenues(of: place)
     
    }
    
    /// Cancel Search and clear textfield
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        dismissKeyboard(with: searchBar)
        
        // Remove focus from the search bar.
        searchBar.endEditing(true)
        
    }
    
    /// Update when textfield changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterVenues(for: searchText)
    }
    
    /// dismiss keyboard (run in main thread)
    func dismissKeyboard(with view: UIView) {
        DispatchQueue.main.async {
            view.resignFirstResponder()
        }
    }
}
