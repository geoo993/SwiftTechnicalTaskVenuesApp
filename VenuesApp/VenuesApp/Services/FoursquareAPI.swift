//
//  FoursquareAPI.swift
//  EventogyVenuesApp
//
//  Created by GEORGE QUENTIN on 18/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

extension Notification.Name {
    static let downloadImageNotification = Notification.Name("DownloadImageNotification")
}

final class FoursquareAPI {
    
    static let shared = FoursquareAPI()
    private let FOURSQUARE_URL = "https://api.foursquare.com/v2/venues/search"
    private let CLIENT_ID = "24YBQ3FNIYLF2XGRUIJPRI3M1TKLHPRUK5BUNCGQJEO3KA12"
    private let CLIENT_SECRET = "TC1RV2V1T2U1OLRUBL1EAAO1EB3DNRGO1SBUEML4SADWWCEY"
    private let VERSION = "20180323"
    private let persistencyManager = PersistencyManager()
    private init() {
        // Get data of transactions
        NotificationCenter.default
            .addObserver(self, selector: #selector(downloadTransactionData(with:)), name: .downloadImageNotification, object: nil)
    }
    
    private var placeHolderVenue: [String: Any] {
        return ["id":"", "name":"", "categories": Category(name: "", iconUrl: ""),
                "country":"", "latitude":0.0, "longitude":0.0] as [String : Any]
    }
    // MARK: - mock Venues data
    func mockVenueData() -> [Venue] {
        // Venue(data: "id":"", "name":"", "category":"", "country":"", "iconUrl":"", "description":"", "latitude":0.0, "longitude":0.0)
        return [
            Venue(data: [
                "id":"4de50c65fa7651589f3c2cf3",
                "name":"", "category":"Hotel", "country":"United Kingdom",
                "iconUrl":"hotel.png", "description":"Nobody here",
                "latitude":0.0, "longitude":0.0])
        ]
    }
    
    // MARK: - Networking to fetch Venues data
    private enum SearchType {
        case venuesInArea, venuesOfInterest
    }
    func fetchVenues(with spanRadius: Double, at location: CLLocationCoordinate2D, completion: @escaping ([Venue]) -> () ) {
        let urlString =
        "https://api.foursquare.com/v2/venues/search" +
        "?client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=\(VERSION)&limit=\(50)" +
        "&ll=\(location.latitude),\(location.longitude)&radius=\(spanRadius)&intent=checkin"
        fetchVenues(with: urlString, type: .venuesInArea, completion: completion)
    }
    
    func fetchVenues(using query: String, with spanRadius: Double, at location: CLLocationCoordinate2D, completion: @escaping ([Venue]) -> () ) {
        let urlString =
        "https://api.foursquare.com/v2/venues/search" +
        "?client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=\(VERSION)&limit=\(10)" +
        "&ll=\(location.latitude),\(location.longitude)&radius=\(spanRadius)&checkin=browse&query=\(query)"
        fetchVenues(with: urlString, type: .venuesOfInterest, completion: completion)
    }
    
    private func fetchVenues(with urlString: String, type: SearchType, completion: @escaping ([Venue]) -> ()) {
        guard let url = URL(string: urlString) else { return }
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
                
                var venues = [Venue]()
                switch type {
                case .venuesInArea: this.getVenuesOfArea(with: &venues, response: venuesResponse)
                case .venuesOfInterest: this.getVenuesOfArea(with: &venues, response: venuesResponse)
                }
                this.persistencyManager.saveVenuesData(with: data)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(venues)
                })
            } catch let err {
                fatalError("Could not fetch Venues Data with URL: \(err)")
            }
        }.resume()
    }
    
    private func getVenuesOfArea(with venues: inout [Venue], response: [String: Any]) {
        for dict in response["venues"] as! [[String: AnyObject]] {
            var data = placeHolderVenue
            data["id"] = dict["id"] as! String
            data["name"] = dict["name"] as! String
            var categories = [Category]()
            for catergory in dict["categories"] as! [[String: AnyObject]] {
                let categoryName = catergory["name"] as! String
                if let icon = catergory["icon"] as? [String: AnyObject] {
                    let prefix = icon["prefix"] as! String
                    let suffix = icon["suffix"] as! String
                    categories.append(Category(name: categoryName, iconUrl: prefix + suffix))
                }
            }
            data["categories"] = categories
            if let location = dict["location"] as? [String: AnyObject] {
                data["country"] = location["country"] as! String
                data["latitude"] = location["lat"] as! Double
                data["longitude"] = location["lng"] as! Double
            }
            venues.append(Venue(data: data))
        }
    }
    
    private func getVenuesOfInterest(with venues: inout [Venue], response: [String: Any]) {
        for dict in response["venues"] as! [[String: AnyObject]] {
            
        }
    }
    
    // MARK: - Cache and load venues images
    @objc func downloadTransactionData(with notification: Notification) {
        guard let userInfo = notification.userInfo,
            let imageView = userInfo["imageView"] as? UIImageView,
            let imageUrl = userInfo["iconUrl"] as? String,
            let filename = URL(string: imageUrl)?.lastPathComponent else {
                return
        }
        print(imageUrl)
        if let savedImage = persistencyManager.getImage(with: filename) {
            imageView.image = savedImage
            return
        }
        DispatchQueue.global().async { [weak self] () -> Void in
            guard let this = self else { return }
            let downloadedImage = this.persistencyManager.downloadImage(imageUrl) ?? UIImage()
            DispatchQueue.main.async {
                imageView.image = downloadedImage
                this.persistencyManager.saveImage(downloadedImage, filename: filename)
            }
        }
    }
}
