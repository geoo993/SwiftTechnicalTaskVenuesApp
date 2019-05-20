//
//  FoursquareAPI.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import VenuesModel
import CoreLocation
import UIKit

public final class FoursquareAPI {
    
    public static let shared = FoursquareAPI()
    
    private let FOURSQUARE_URL = "https://api.foursquare.com/v2/venues/search"
    private let CLIENT_ID = "24YBQ3FNIYLF2XGRUIJPRI3M1TKLHPRUK5BUNCGQJEO3KA12"
    private let CLIENT_SECRET = "TC1RV2V1T2U1OLRUBL1EAAO1EB3DNRGO1SBUEML4SADWWCEY"
    private let VERSION = "20180323"
    private init() {
        // Get data of transactions
        NotificationCenter.default
            .addObserver(PersistencyManager.shared,
                         selector: #selector(PersistencyManager.shared.downloadTransactionData(with:)),
                         name: .downloadImageNotification, object: nil)
    }
    
    private var venuePlaceholder: [String: Any] {
        return ["id":"", "name":"", "address":"",
                "country":"", "distance":0.0, "latitude":0.0, "longitude":0.0] as [String : Any]
    }
    
    private var categoryPlaceholder: [String: Any] {
        return ["id":"", "name":"", "shortName": ""] as [String : Any]
    }
    // MARK: - mock Venues data
    func mockVenueData() -> [Venue] {
        return [
            Venue(data: [
                "id":"4de50c65fa7651589f3c2cf3",
                "name":"", "address":"London road", "country":"United Kingdom", "distance": 189.0,
                "latitude":0.0, "longitude":0.0])
        ]
    }
    // MARK: - Fetch search categories of venues
    public func fetchVenueCategories(completion: @escaping ([VenuesModel.Category]) -> () ) {
        let urlString =
            "https://api.foursquare.com/v2/venues/categories" +
        "?client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=\(VERSION)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] (dataresult, response, error) in
            guard let this = self else {
                completion([])
                return
            }
            if error != nil {
                fatalError("Error getting categories from Foursquare: \(String(describing: error)).")
            }
            do {
                
                guard
                    // 1
                    let data = dataresult else {
                        fatalError("Data result of categories corrupted = nil.")
                }
                
                // 2
                let json = try JSONSerialization.jsonObject(with: data)
                guard
                    // 3
                    let dictionary = json as? [String: Any],
                    // 4
                    let categoriesResponse = dictionary["response"] as? [String: Any]
                    else {
                        fatalError("JSON decoding error of categories.")
                }
                //print(categoriesResponse)
                
                var categories = [VenuesModel.Category]()
                this.fetchNestedCategories(with: &categories, response: categoriesResponse)
                let uniqueCategories = Array(Set<VenuesModel.Category>(categories))
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(uniqueCategories)
                })
            } catch let err {
                fatalError("Could not fetch Categories Data with URL: \(err)")
            }
            }.resume()
    }
    public func fetchNestedCategories(with categories: inout [VenuesModel.Category], response: [String: Any]) {
        if let mainCategories = response["categories"] as? [[String: AnyObject]] {
            for dict in mainCategories {
                fetchNestedCategories(with: &categories, response: dict)
                var categoryData = categoryPlaceholder
                categoryData["id"] = dict["id"] as! String
                categoryData["name"] = dict["name"] as! String
                categoryData["shortName"] = dict["shortName"] as! String
                categories.append(Category(data:categoryData))
            }
        }
    }
     // MARK: - fetch Venues at location of interest
    public func fetchVenues(using query: String, with spanRadius: Double, at location: CLLocationCoordinate2D, completion: @escaping ([Venue]) -> () ) {
        let section = query.lowercased().replacingOccurrences(of: " ", with: "")
        let urlString =
        "https://api.foursquare.com/v2/venues/explore" +
        "?client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=\(VERSION)" +
        "&limit=\(20)&ll=\(location.latitude),\(location.longitude)&radius=\(spanRadius)&section=\(section)"
        fetchVenues(with: urlString, completion: completion)
    }
    private func fetchVenues(with urlString: String, completion: @escaping ([Venue]) -> ()) {
        guard let url = URL(string: urlString) else {
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] (dataresult, response, error) in
            guard let this = self else {
                completion([])
                return
            }
            if error != nil {
                fatalError("Error getting venues from Foursquare: \(String(describing: error)).")
            }
            do {
                
                guard
                    // 1
                    let data = dataresult else {
                        fatalError("Data result of venues corrupted = nil.")
                    }
                
                // 2
                let json = try JSONSerialization.jsonObject(with: data)
                guard
                    // 3
                    let dictionary = json as? [String: Any],
                    // 4
                    let venuesResponse = dictionary["response"] as? [String: Any]
                    else {
                        fatalError("JSON decoding error of venues locations.")
                }
                //print(venuesResponse)
                var venues = [Venue]()
                for groups in venuesResponse["groups"] as! [[String: AnyObject]] {
                    for items in groups["items"] as! [[String: AnyObject]] {
                        if let venue = items["venue"] as? [String: AnyObject] {
                            var venueData = this.venuePlaceholder
                            venueData["id"] = venue["id"] as! String
                            venueData["name"] = venue["name"] as! String
                            if let location = venue["location"] as? [String: AnyObject],
                                let formattedAddress = location["formattedAddress"] as? [String] {
                                venueData["address"] = formattedAddress.joined(separator: "\n")
                                venueData["country"] = location["country"] as! String
                                venueData["distance"] = location["distance"] as! Double
                                venueData["latitude"] = location["lat"] as! Double
                                venueData["longitude"] = location["lng"] as! Double
                            }
                            venues.append(Venue(data: venueData))
                        }
                    }
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(venues)
                })
            } catch let err {
                fatalError("Could not fetch Venues Data with URL: \(err)")
            }
        }.resume()
    }
    // MARK: - Fetch photos of venue with Venue id
    public func fetchVenuePhotos(using venueId: String, completion: @escaping ([String]) -> () ) {
        let urlString =
            "https://api.foursquare.com/v2/venues/\(venueId.lowercased())/photos" +
            "?client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=\(VERSION)" +
            "&limit=\(10)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (dataresult, response, error) in
            if error != nil {
                fatalError("Error getting venue photos from Foursquare: \(String(describing: error)).")
            }
            do {
                guard
                    // 1
                    let data = dataresult else {
                        fatalError("Data result of photos corrupted = nil.")
                }
                // 2
                let json = try JSONSerialization.jsonObject(with: data)
                guard
                    // 3
                    let dictionary = json as? [String: Any],
                    // 4
                    let photosResponse = dictionary["response"] as? [String: Any]
                    else {
                        fatalError("JSON decoding error of venue photos.")
                }
                //print(photosResponse)
                
                // Returns photos for a specific venue. To assemble a photo URL, combine the response’s prefix + size + suffix. Ex: https://igx.4sqi.net/img/general/300x500/5163668_xXFcZo7sU8aa1ZMhiQ2kIP7NllD48m7qsSwr1mJnFj4.jpg
                var photosData = [String]()
                if let photos = photosResponse["photos"] as? [String: AnyObject] {
                    for items in photos["items"] as! [[String: AnyObject]] {
                        let prefix = items["prefix"] as! String
                        let suffix = items["suffix"] as! String
                        photosData.append(prefix + "200x200" + suffix)
                    }
                }

                DispatchQueue.main.async(execute: { () -> Void in
                    completion(photosData)
                })
            } catch let err {
                fatalError("Could not fetch venue photos Data with URL: \(err)")
            }
        }.resume()
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