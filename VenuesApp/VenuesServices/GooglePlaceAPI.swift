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

public final class GooglePlaceAPI {
    public static let shared = GooglePlaceAPI()
    
    private let GOOGLE_API_KEY = "AIzaSyALcJxBXNfCiUfrVS3lwx9fVLvbsJ3OFhg"

    private init() {
        // Get data of transactions
        NotificationCenter.default
            .addObserver(PersistencyManager.shared,
                         selector: #selector(PersistencyManager.shared.downloadTransactionData(with:)),
                         name: .downloadImageNotification, object: nil)
    }
    private var placePlaceholder: [String: Any] {
        return ["name":"", "address":"", "latitude":0.0, "longitude":0.0] as [String : Any]
    }
    // MARK: - Fetch locations in UK
    public func fetchLocations(of place: String, completion: @escaping ([VenuesModel.Place]) -> () ) {
        // input — The text input specifying which place to search for (for example, a name, address, or phone number).
        let urlString =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/" +
        "json?input=\(place)&inputtype=textquery" +
        "&fields=formatted_address,name,geometry" +
        "&key=\(GOOGLE_API_KEY)"
        let encodingUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: encodingUrl) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] (dataresult, response, error) in
            guard let this = self else {
                completion([])
                return
            }
            if error != nil {
                fatalError("Error getting locations from National Statistics: \(String(describing: error)).")
            }
            do {
                guard
                    // 1
                    let data = dataresult else {
                        fatalError("Data result of locations corrupted = nil.")
                }
                // 2
                let json = try JSONSerialization.jsonObject(with: data)
                guard
                    // 3
                    let dictionary = json as? [String: Any],
                    // 4
                    let locationsResponse = dictionary["candidates"] as? [Any]
                    else {
                        fatalError("JSON decoding error of of locations.")
                }
                print(dictionary)
                
                var places = [VenuesModel.Place]()
                for placeResponse in locationsResponse as! [[String: AnyObject]] {
                    var locationData = this.placePlaceholder
                    locationData["name"] = placeResponse["name"] as! String
                    locationData["address"] = placeResponse["formatted_address"] as! String
                    if let geometry = placeResponse["geometry"] as? [String: AnyObject] {
                        if let location = geometry["location"] as? [String: AnyObject] {
                            locationData["latitude"] = location["lat"] as! Double
                            locationData["longitude"] = location["lng"] as! Double
                        }
                    }
                    places.append(Place(data: locationData))
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(places)
                })
            } catch let err {
                fatalError("Could not fetch UK location Data with URL: \(err)")
            }
        }.resume()
    }
}
