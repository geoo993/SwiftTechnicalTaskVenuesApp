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
            let decoder = JSONDecoder()
            let categoryResponse = try decoder.decode(CategoryResponse.self, from: data)
            let uniqueCategories = Array(Set<VenuesModel.Category>(categoryResponse.categories))
            DispatchQueue.main.async(execute: { () -> Void in
                completion(NetworkResult.data(uniqueCategories))
            })
        } catch let err {
            completion(NetworkResult.error("Could not fetch Categories Data with URL: \(err)"))
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
            let decoder = JSONDecoder()
            let venueResponse = try decoder.decode(VenueResponse.self, from: data)
            
            DispatchQueue.main.async(execute: { () -> Void in
                completion(NetworkResult.data(venueResponse.venues))
            })
        } catch let err {
            completion(NetworkResult.error("Could not fetch Venues Data with URL: \(err)"))
        }
    }
    func handlePhotosResult(data: Data?, error: Error?, completion: @escaping (NetworkResult<VenuesModel.Photo>) -> ()) {
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
            
            let decoder = JSONDecoder()
            let photoResponse = try decoder.decode(PhotoResponse.self, from: data)
            
            DispatchQueue.main.async(execute: { () -> Void in
                completion(NetworkResult.data(photoResponse.photos))
            })
        } catch let err {
            completion(NetworkResult.error("Could not fetch venue photos Data with URL: \(err)"))
        }
    }
}
