//
//  NetworkRequest.swift
//  VenuesModel
//
//  Created by GEORGE QUENTIN on 20/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

public enum NetworkResult<T> {
    case data([T])
    case error(String)
}

public protocol GooglePlaceAPINetworkRequest {
    func fetchLocations(of place: String, completion: @escaping (NetworkResult<VenuesModel.Place>) -> () )
}

public protocol FoursquareAPINetworkRequest {
    func fetchVenueCategories(completion: @escaping (NetworkResult<VenuesModel.Category>) -> () )
    func fetchVenuePhotos(using venueId: String, completion: @escaping (NetworkResult<String>) -> () )
    func openWeb(of venueId: String)
}

