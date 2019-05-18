//
//  VenuesMapSearchViewController.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import UIKit

class VenuesMapSearchViewController: UIViewController {

    // Mark: - Main properties
    private let mainColor = UIColor.eventogyTheme
    var venues : [String]?
    
    // Mark: - Search bar
    private let search = UISearchController(searchResultsController: nil)
    private var searchBarFiltered:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupSearchBar()
    }
    
    // Mark: Setup navigation controller
    private func setupNavBar() {
        if let navigationController = self.navigationController {
            navigationController.navigationItem.largeTitleDisplayMode = .never
            navigationController.navigationBar.barTintColor = mainColor
        }
    }
    
    // Mark: Setup search bar
    private func setupSearchBar() {
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
    
    // Mark: Search venues based on interest
    func searchVenues(of interest: String) {
        print("Interested in ", interest)
    }
    
    func filterVenues(for searchText: String) {
        searchBarFiltered = venues?
            .filter( { $0.lowercased().contains( searchText.lowercased() )}) ?? [String]()
    }
    
    /// dismiss keyboard (run in main thread)
    private func dismissKeyboard(with view: UIView) {
        DispatchQueue.main.async {
            view.resignFirstResponder()
        }
    }
}

// MARK: SearchBar Delegate
extension VenuesMapSearchViewController : UISearchBarDelegate {
    
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
}
