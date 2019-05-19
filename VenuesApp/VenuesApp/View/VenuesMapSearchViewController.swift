//
//  VenuesMapSearchViewController.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import UIKit
import MapKit

private enum Constants {
    static let cellIdentifier = "SearchResultCell"
}

class VenuesMapSearchViewController: UIViewController {

    @IBOutlet weak var tableView: VenuesSearchResultTableView!
    @IBOutlet weak var tableViewBackground: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    // Mark: - Main properties
    var categories : [Category]?
    
    // Mark: - Search bar
    let search = UISearchController(searchResultsController: nil)
    private var searchActive: Bool = false
    private var searchBarFiltered: [Category] = []
    var searchVenuesOf: (_ category: String) -> () = { cat in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupSearchBar()
        setupTableView()
    }

    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
    }

    // Mark: Setup navigation controller
    private func setupNavBar() {
        if let navigationController = self.navigationController {
            navigationController.navigationItem.largeTitleDisplayMode = .never
            navigationController.navigationBar.barTintColor = UIColor.eventogyTheme
        }
    }
    
    // Mark: Setup search bar
    private func setupSearchBar() {
        search.searchBar.delegate = self
        search.searchBar.placeholder = "Search for..."
        search.searchBar.backgroundColor = UIColor.eventogyTheme
        search.searchBar.barTintColor = UIColor.eventogyTheme
        search.searchBar.barStyle = .black
        search.searchBar.tintColor = .white
        search.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.searchController = search
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
    }
    func setupTableView() {
        self.tableView.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8.0)
        self.tableViewBackground.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8.0)
    }
    func updateTableView(hidden: Bool) {
        self.tableView.isHidden = hidden
        self.tableViewBackground.isHidden = hidden
    }
    
    // Mark: Select, Search Update venues
    func updateCategories(with categories: [Category]) {
        self.categories = categories
        self.tableView.reloadData()
    }
    
    func filterVenues(for searchText: String) {
        if let filter = categories?
            .filter( { $0.name.lowercased().contains( searchText.lowercased() )})
            .sorted(by: { $0.name < $1.name }) {
            searchBarFiltered = filter
        }
        if(searchBarFiltered.count == 0){
            searchActive = false
            updateTableView(hidden: true)
        } else {
            updateTableView(hidden: false)
            searchActive = true
        }
        self.tableView.reloadData()
    }
    
    // Mark: dismiss keyboard (run in main thread)
    private func dismissKeyboard(with view: UIView) {
        DispatchQueue.main.async {
            view.resignFirstResponder()
        }
    }
}

// MARK: SearchBar Delegate
extension VenuesMapSearchViewController : UISearchBarDelegate {
    
    /// Called when the user click on the view (outside the SearchBar).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch:UITouch = touches.first else
        {
            return
        }
        
        if touch.view != tableView
        {
            self.search.searchBar.endEditing(true)
            updateTableView(hidden: true)
        }
    }
 
    /// Show Cancel button
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        searchBar.setShowsCancelButton(true, animated: true)
        updateTableView(hidden: false)
    }
    
    /// Stop editing search bar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.setShowsCancelButton(false, animated: true)
        dismissKeyboard(with: searchBar)
        updateTableView(hidden: true)
    }
    
    /// Hide Cancel
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
        guard let category = searchBar.text else {
            return
        }
        searchVenuesOf(category)
    }
    
    /// Cancel Search and clear textfield
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = String()
        searchBar.endEditing(true)
        
        guard let canceled = searchBar.text else {
            return
        }
        filterVenues(for: canceled)
    }
    
    /// Update when textfield changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableViewClearCellsOnEditing()
        filterVenues(for: searchText)
    }
}

// MARK: UITableView Delegate
extension VenuesMapSearchViewController : UITableViewDelegate {
    func tableViewClearCellsOnEditing() {
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? VenuesSearchResultCell else { return }
        cell.contentView.backgroundColor = cell.selectedColor
        
        if let category = searchBarFiltered.enumerated().first(where: { $0.offset == indexPath.row })?.element {
            self.search.searchBar.text = category.name
            self.search.searchBar.endEditing(true)
            searchVenuesOf(category.name)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.contentView.backgroundColor = .clear
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? VenuesSearchResultCell else { return }
        cell.contentView.backgroundColor = cell.hightlightedColor
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.contentView.backgroundColor = .clear
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
        self.viewWillLayoutSubviews()
    }
}

// MARK: UITableView DataSource
extension VenuesMapSearchViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchActive ? searchBarFiltered.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? VenuesSearchResultCell,
            let venueOfInterest = searchBarFiltered.enumerated().first(where: { $0.offset == indexPath.row })?.element {
            if(searchActive){
                cell.setCategory(with: venueOfInterest)
                return cell
            }
            return UITableViewCell()
        }
 
        return UITableViewCell()
    }
    
}
