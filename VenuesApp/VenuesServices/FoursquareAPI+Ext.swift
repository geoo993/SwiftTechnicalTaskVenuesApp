//
//  FoursquareAPI+Ext.swift
//  VenuesServices
//
//  Created by GEORGE QUENTIN on 23/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
import VenuesModel

extension FoursquareAPI {
    func handleCategoriesResult(data: Data?, error: Error?, completion: @escaping (NetworkResult<VenuesModel.Category>) -> ()) {
        if error != nil {
            completion(NetworkResult.error("Error getting categories from Foursquare: \(String(describing: error))."))
        }
        do {
            guard
                // 1
                let data = data else {
                    completion(NetworkResult.error("Data result of categories corrupted."))
                    return
            }
            
            // 2
            let json = try JSONSerialization.jsonObject(with: data)
            guard
                // 3
                let dictionary = json as? [String: Any],
                // 4
                let categoriesResponse = dictionary["response"] as? [String: Any]
                else {
                    completion(NetworkResult.error("JSON decoding error of categories."))
                    return
            }
            //print(categoriesResponse)
            
            var categories = [VenuesModel.Category]()
            fetchNestedCategories(with: &categories, response: categoriesResponse)
            let uniqueCategories = Array(Set<VenuesModel.Category>(categories))
            DispatchQueue.main.async(execute: { () -> Void in
                completion(NetworkResult.data(uniqueCategories))
            })
        } catch let err {
            completion(NetworkResult.error("Could not fetch Categories Data with URL: \(err)"))
        }
    }
    func fetchNestedCategories(with categories: inout [VenuesModel.Category], response: [String: Any]) {
        if let mainCategories = response["categories"] as? [[String: AnyObject]] {
            for dict in mainCategories {
                fetchNestedCategories(with: &categories, response: dict)
                var categoryData = ["id":"", "name":"", "shortName": ""] as [String : Any]
                categoryData["id"] = dict["id"] as! String
                categoryData["name"] = dict["name"] as! String
                categoryData["shortName"] = dict["shortName"] as! String
                categories.append(Category(data:categoryData))
            }
        }
    }
    func handleVenuesResult(data: Data?, error: Error?, completion: @escaping (NetworkResult<VenuesModel.Venue>) -> ()) {
        if error != nil {
            completion(NetworkResult.error("Error getting venues from Foursquare: \(String(describing: error))."))
        }
        do {
            
            guard
                // 1
                let data = data else {
                    completion(NetworkResult.error("Data result of venues corrupted = nil."))
                    return
            }
            
            // 2
            let json = try JSONSerialization.jsonObject(with: data)
            guard
                // 3
                let dictionary = json as? [String: Any],
                // 4
                let venuesResponse = dictionary["response"] as? [String: Any]
                else {
                    completion(NetworkResult.error("JSON decoding error of venues locations."))
                    return
            }
            //print(venuesResponse)
            var venues = [Venue]()
            for groups in venuesResponse["groups"] as! [[String: AnyObject]] {
                for items in groups["items"] as! [[String: AnyObject]] {
                    if let venue = items["venue"] as? [String: AnyObject] {
                        var venueData = ["id":"", "name":"", "address":"",
                                         "country":"", "distance":0.0,
                                         "latitude":0.0, "longitude":0.0] as [String : Any]
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
                completion(NetworkResult.data(venues))
            })
        } catch let err {
            completion(NetworkResult.error("Could not fetch Venues Data with URL: \(err)"))
        }
    }
    func handlePhotosResult(data: Data?, error: Error?, completion: @escaping (NetworkResult<String>) -> ()) {
        if error != nil {
            completion(NetworkResult.error("Error getting venue photos from Foursquare: \(String(describing: error))."))
        }
        do {
            guard
                // 1
                let data = data else {
                    completion(NetworkResult.error("Data result of photos corrupted = nil."))
                    return
            }
            // 2
            let json = try JSONSerialization.jsonObject(with: data)
            guard
                // 3
                let dictionary = json as? [String: Any],
                // 4
                let photosResponse = dictionary["response"] as? [String: Any]
                else {
                    completion(NetworkResult.error("JSON decoding error of venue photos."))
                    return
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
                completion(NetworkResult.data(photosData))
            })
        } catch let err {
            completion(NetworkResult.error("Could not fetch venue photos Data with URL: \(err)"))
        }
    }
}
