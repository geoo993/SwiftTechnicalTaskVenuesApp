//
//  FoursquareAPI.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import VenuesModel
import CoreLocation

public final class FoursquareAPI: HttpClient, FoursquareAPINetworkRequest {
    /*
    public static let shared = FoursquareAPI()
 */
    
    private init() {
        super.init()
        // Get data of transactions
        NotificationCenter.default
            .addObserver(PersistencyManager.shared,
                         selector: #selector(PersistencyManager.shared.downloadTransactionData(with:)),
                         name: .downloadImageNotification, object: nil)
    }

    // MARK: - Fetch search categories of venues
    public func fetchVenueCategories(completion: @escaping (NetworkResult<VenuesModel.Category>) -> () ) {
        let urlString =
            "https://api.foursquare.com/v2/venues/categories" +
        "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323"
        guard let url = URL(string: urlString) else { return }
        fetchData(url: url) { [weak self] (data, error)  in
            guard let this = self else { return }
            this.handleCategoriesResult(data: data, error: error, completion: completion)
        }
    }
     // MARK: - fetch Venues at location of interest
    public func fetchVenues(using query: String, with spanRadius: Double,
                            at location: CLLocationCoordinate2D,
                            completion: @escaping (NetworkResult<Venue>) -> () ) {
        let section = query.lowercased().replacingOccurrences(of: " ", with: "")
        let urlString =
        "https://api.foursquare.com/v2/venues/explore" +
    "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323" +
        "&limit=\(20)&ll=\(location.latitude),\(location.longitude)&radius=\(spanRadius)&section=\(section)"
        guard let url = URL(string: urlString) else {
            return
        }
        fetchData(url: url) { [weak self] (data, error)  in
            guard let this = self else { return }
            this.handleVenuesResult(data: data, error: error, completion: completion)
        }
    }
    // MARK: - Fetch photos of venue with Venue id
    public func fetchVenuePhotos(using venueId: String, completion: @escaping (NetworkResult<String>) -> () ) {
        let urlString =
            "https://api.foursquare.com/v2/venues/\(venueId.lowercased())/photos" +
            "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323" +
            "&limit=\(10)"
        guard let url = URL(string: urlString) else { return }
        fetchData(url: url) { [weak self] (data, error)  in
            guard let this = self else { return }
            this.handlePhotosResult(data: data, error: error, completion: completion)
        }
    }
    // MARK: - Open foursquare website with Venue id
    public func openWeb(of venueId: String) {
        if let encodedAddress =
            ("https://www.foursquare.com/v/"+venueId).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodedAddress) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}
