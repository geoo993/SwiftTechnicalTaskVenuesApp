//
//  EventogyVenuesFoursquareAPIAppTests.swift
//  EventogyVenuesFoursquareAPIAppTests
//
//  Created by GEORGE QUENTIN on 17/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import XCTest
import VenuesServices
import VenuesModel
@testable import EventogyVenuesApp

class EventogyVenuesFoursquareAPIAppTests: XCTestCase {

    var httpClient: HttpClient!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        httpClient = HttpClient()
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFourSquareAPIReturnsVenueCategoriesData() {
        // Given
        let urlString =
            "https://api.foursquare.com/v2/venues/categories" +
        "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)" +
        "&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323"
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        var nextError: Error?
        
        // When
        guard let url = URL(string: urlString) else {
            fatalError("URL can't be empty or have spacing")
        }
        httpClient.fetchData(url: url) { (success, error) in
            nextData = success
            nextError = error
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(nextData)
        XCTAssertNil(nextError)
    }
    func testFourSquareAPICategoriesDataCastToJsonWithResponse() {
        // Given
        let urlString =
            "https://api.foursquare.com/v2/venues/categories" +
        "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)" +
        "&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323"
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        
        // When
        httpClient.fetchData(url: URL(string: urlString)!) { (success, error) in
            nextData = success
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        
        // check data is not nil
        XCTAssertNotNil(nextData)
        
        // Check json is not nil
        let json = try? JSONSerialization.jsonObject(with: nextData!)
        XCTAssertNotNil(json)
        
        // Check the first value is not nil
        let dictionary = json as? [String: Any]
        XCTAssertNotNil(dictionary)
        
        // check that we have a response dictionary
        let categoriesResponse = dictionary?["response"] as? [String: Any]
        XCTAssertNotNil(categoriesResponse)
    }
    
    func testFetchVenueCategories() {
        // Given
        let urlString =
            "https://api.foursquare.com/v2/venues/categories" +
                "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)" +
        "&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323"
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        
        // When
        httpClient.fetchData(url: URL(string: urlString)!) { (success, error) in
            nextData = success
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        
        let json = try? JSONSerialization.jsonObject(with: nextData!)
        XCTAssertNotNil(json)
        
        guard
            let dictionary = json as? [String: Any],
            let categoriesResponse = dictionary["response"] as? [String: Any]
            else {
                fatalError("Decoding error")
        }
        
        let mainCategories = categoriesResponse["categories"] as? [[String: AnyObject]]
        XCTAssertNotNil(mainCategories)
        
        // Check that we can get at least one category
        let categorieResponse = mainCategories?.first
        XCTAssertNotNil(categorieResponse)
        
        guard let categorieResult = categorieResponse else {
            fatalError("Decoding error")
        }
        
        let id = categorieResult["id"] as! String
        XCTAssertNotNil(id)
        
        let name = categorieResult["name"] as! String
        XCTAssertNotNil(name)
        
        let shortName = categorieResult["shortName"] as! String
        XCTAssertNotNil(shortName)
    }
    
    
    func testFourSquareAPIReturnsVenuesExploreData() {
        // Given
        //let place = "Southbank Center, London (Waterloo), SE1 8"
        let latitude: Double = 51.506663
        let longitude: Double = -0.116318
        let urlString =
            "https://api.foursquare.com/v2/venues/explore" +
            "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)" +
            "&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323" +
        "&limit=\(10)&ll=\(latitude),\(longitude)&radius=\(250)&section=food"
        
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        var nextError: Error?
        
        // When
        guard let url = URL(string: urlString) else {
            fatalError("URL can't be empty or have spacing")
        }
        httpClient.fetchData(url: url) { (success, error) in
            nextData = success
            nextError = error
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(nextData)
        XCTAssertNil(nextError)
    }
    
    func testFourSquareAPIVenuesDataCastToJsonWithResponse() {
        // Given
        let latitude: Double = 51.506663
        let longitude: Double = -0.116318
        let urlString =
            "https://api.foursquare.com/v2/venues/explore" +
                "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)" +
                "&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323" +
        "&limit=\(10)&ll=\(latitude),\(longitude)&radius=\(250)&section=food"
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        
        // When
        httpClient.fetchData(url: URL(string: urlString)!) { (success, error) in
            nextData = success
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        
        // check data is not nil
        XCTAssertNotNil(nextData)
        
        // Check json is not nil
        let json = try? JSONSerialization.jsonObject(with: nextData!)
        XCTAssertNotNil(json)
        
        // Check the first value is not nil
        let dictionary = json as? [String: Any]
        XCTAssertNotNil(dictionary)
        
        // check that we have a response dictionary
        let categoriesResponse = dictionary?["response"] as? [String: Any]
        XCTAssertNotNil(categoriesResponse)
    }
    
    
    func testFetchVenuesOfQueryAtLocation() {
        // Given
        let latitude: Double = 51.506663
        let longitude: Double = -0.116318
        let query = "food"
        let urlString =
            "https://api.foursquare.com/v2/venues/explore" +
                "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)" +
                "&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323" +
        "&limit=\(10)&ll=\(latitude),\(longitude)&radius=\(500)&section=\(query)"
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        var nextError: Error?
        // When
        // When
        httpClient.fetchData(url: URL(string: urlString)!) { (success, error) in
            nextData = success
            nextError = error
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(nextData)
        XCTAssertNil(nextError)
        
        let json = try? JSONSerialization.jsonObject(with: nextData!)
        XCTAssertNotNil(json)
        
        guard
            let dictionary = json as? [String: Any],
            let venuesResponse = dictionary["response"] as? [String: Any]
            else {
                fatalError("Decoding error")
        }
 
        let groups = venuesResponse["groups"] as? [[String: AnyObject]]
        XCTAssertNotNil(groups)
        
        // Check that we can get at least one venue from query
        let firstGroup = groups?.first
        XCTAssertNotNil(firstGroup)
        
        let items = firstGroup?["items"] as? [[String: AnyObject]]
        XCTAssertNotNil(items)
        
        let firstItem = items?.first
        XCTAssertNotNil(firstItem)
        
        let venue = firstItem?["venue"] as? [String: AnyObject]
        XCTAssertNotNil(venue)
        
        let id = venue?["id"] as? String
        XCTAssertNotNil(id)
        
        let name = venue?["name"] as? String
        XCTAssertNotNil(name)
        
        let location = venue?["location"] as? [String: AnyObject]
        XCTAssertNotNil(location)
        
        let formattedAddress = location?["formattedAddress"] as? [String]
        XCTAssertNotNil(formattedAddress)
        
        let address = formattedAddress?.joined(separator: "\n")
        XCTAssertNotNil(address)
        
        let country = location?["country"] as? String
        XCTAssertNotNil(country)
        
        let distance = location?["distance"] as? Double
        XCTAssertNotNil(distance)
        
        let lat = location?["lat"] as? Double
        XCTAssertNotNil(lat)
        
        let lng = location?["lng"] as? Double
        XCTAssertNotNil(lng)
    }
    
    
    func testFourSquareAPIReturnsVenuePhotosData() {
        
        // Given
        let venueId = "5033e5d1e4b011c548922311"
        let urlString =
            "https://api.foursquare.com/v2/venues/\(venueId.lowercased())/photos" +
                "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)" +
                "&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323" +
        "&limit=\(10)"
        
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        var nextError: Error?
        
        // When
        guard let url = URL(string: urlString) else {
            fatalError("URL can't be empty or have spacing")
        }
        httpClient.fetchData(url: url) { (success, error) in
            nextData = success
            nextError = error
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(nextData)
        XCTAssertNil(nextError)
    }
    
    func testFourSquareAPIPhotosDataCastToJsonWithResponse() {
        // Given
        let venueId = "5033e5d1e4b011c548922311"
        let urlString =
            "https://api.foursquare.com/v2/venues/\(venueId.lowercased())/photos" +
                "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)" +
                "&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323" +
        "&limit=\(10)"
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        
        // When
        httpClient.fetchData(url: URL(string: urlString)!) { (success, error) in
            nextData = success
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        
        // check data is not nil
        XCTAssertNotNil(nextData)
        
        // Check json is not nil
        let json = try? JSONSerialization.jsonObject(with: nextData!)
        XCTAssertNotNil(json)
        
        // Check the first value is not nil
        let dictionary = json as? [String: Any]
        XCTAssertNotNil(dictionary)
        
        // check that we have a response dictionary
        let photosResponse = dictionary?["response"] as? [String: Any]
        XCTAssertNotNil(photosResponse)
    }
    
    func testFetchVenuePhotosWithVenueID() {
        // Given
        let venueId = "5033e5d1e4b011c548922311"
        let urlString =
            "https://api.foursquare.com/v2/venues/\(venueId.lowercased())/photos" +
                "?client_id=\(Constants.FOURSQUARE_CLIENT_ID.rawValue)" +
                "&client_secret=\(Constants.FOURSQUARE_CLIENT_SECRET.rawValue)&v=20180323" +
        "&limit=\(10)"
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        
        // When
        httpClient.fetchData(url: URL(string: urlString)!) { (success, error) in
            nextData = success
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(nextData)
        
        // Check json is not nil
        let json = try? JSONSerialization.jsonObject(with: nextData!)
        XCTAssertNotNil(json)
        
        guard
            let dictionary = json as? [String: Any],
            let photosResponse = dictionary["response"] as? [String: Any]
            else {
                fatalError("Decoding error")
        }
        
        let photos = photosResponse["photos"] as? [String: AnyObject]
        XCTAssertNotNil(photos)
        
        let items = photos?["items"] as? [[String: AnyObject]]
        XCTAssertNotNil(items)
        
        // Check that we can get at least one item photo
        let firstItem = items?.first
        XCTAssertNotNil(firstItem)
        
        let photoUrlPrefix = firstItem?["prefix"] as? String
        XCTAssertNotNil(photoUrlPrefix)
        
        let photoUrlSuffix = firstItem?["suffix"] as? String
        XCTAssertNotNil(photoUrlSuffix)
        
    }
}
