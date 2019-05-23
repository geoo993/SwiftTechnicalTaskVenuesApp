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
                let json = try JSONSerialization.jsonObject(with: data)
                guard
                    // 3
                    let dictionary = json as? [String: Any],
                    // 4
                    let locationsResponse = dictionary["candidates"] as? [Any]
                    else {
                        completion(NetworkResult.error("JSON decoding error of of locations.")); return }
                //print(dictionary)
                
                var places = [VenuesModel.Place]()
                guard let locationResponses = locationsResponse as? [[String: AnyObject]] else { return }
                for placeResponse in locationResponses {
                    guard let name = placeResponse["name"] as? String,
                        let address = placeResponse["formatted_address"] as? String,
                        let geometry = placeResponse["geometry"] as? [String: AnyObject],
                        let location = geometry["location"] as? [String: AnyObject],
                        let latitude = location["lat"] as? Double,
                        let longitude = location["lng"] as? Double
                        else { completion(NetworkResult.error("JSON decoding error of of locations.")); return }
                    var locationData = ["name":"", "address":"", "latitude":0.0, "longitude":0.0] as [String : Any]
                    locationData["name"] = name
                    locationData["address"] = address
                    locationData["latitude"] = latitude
                    locationData["longitude"] = longitude
                    places.append(Place(data: locationData))
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(NetworkResult.data(places))
                })
            } catch let err {
                completion(NetworkResult.error("Could not fetch UK location Data with URL: \(err)"))
            }
    }

}
