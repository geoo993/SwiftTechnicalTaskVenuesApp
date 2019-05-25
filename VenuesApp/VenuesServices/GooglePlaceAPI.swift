//
//  GooglePlaceAPI.swift
//  VenuesServices
//
//  Created by GEORGE QUENTIN on 20/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import VenuesModel
import CoreLocation
import UIKit

public final class GooglePlaceAPI: HttpClient, GooglePlaceAPINetworkRequest {
    public static let shared = GooglePlaceAPI()
    
    private init() {
        super.init()
        // Get data of transactions
        NotificationCenter.default
            .addObserver(PersistencyManager.shared,
                         selector: #selector(PersistencyManager.shared.downloadTransactionData(with:)),
                         name: .downloadImageNotification, object: nil)
    }

    // MARK: - Fetch locations in UK
    public func fetchLocations(of place: String, completion: @escaping (NetworkResult<VenuesModel.Place>) -> () ) {
        // input — The text input specifying which place to search for (for example, a name, address, or phone number).
        let urlString =
            "https://maps.googleapis.com/maps/api/place/findplacefromtext/" +
                "json?input=\(place)&inputtype=textquery" +
                "&fields=formatted_address,name,geometry" +
        "&key=\(Constants.GOOGLE_API_KEY.rawValue)"
        let encodingUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: encodingUrl) else { return }
        fetchData(url: url) { [weak self] (data, error)  in
            guard let this = self else { return }
            this.handleLocationsResult(data: data, error: error, completion: completion)
        }
    }
    
    private func handleLocationsResult(data: Data?, error: Error?,
                                       completion: @escaping (NetworkResult<VenuesModel.Place>) -> ()) {
            if error != nil {
                completion(NetworkResult.error("Error getting locations from National Statistics: \(String(describing: error))."))
            }
            do {
                guard
                    // 1
                    let data = data else {
                        completion(NetworkResult.error("Data result of locations corrupted = nil."))
                        return
                }
                // 2
                let decoder = JSONDecoder()
                let candidate = try decoder.decode(Candidate.self, from: data)
              
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(NetworkResult.data(candidate.places))
                })
            } catch let err {
                completion(NetworkResult.error("Could not fetch UK location Data with URL: \(err)"))
            }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(PersistencyManager.shared, name: .downloadImageNotification, object: nil)
    }
}
