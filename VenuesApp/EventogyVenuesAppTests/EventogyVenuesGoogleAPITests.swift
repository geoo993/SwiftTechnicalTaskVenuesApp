//
//  EventogyVenuesGoogleAPIAppTests.swift
//  EventogyVenuesGoogleAPIAppTests
//
//  Created by GEORGE QUENTIN on 17/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import XCTest
import VenuesServices
import VenuesModel
@testable import EventogyVenuesApp

class EventogyVenuesGoogleAPIAppTests: XCTestCase {
   
    let googleAPIUrl =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/" +
            "json?input=southbank centre&inputtype=textquery" +
            "&fields=formatted_address,name,geometry" + "&key=\(Constants.GOOGLE_API_KEY.rawValue)"
   
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
    
    func testEncodedURL() {
        // Given
        let urlString = googleAPIUrl
        
        // When
        let encodingUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        // Then
        XCTAssertNotEqual(encodingUrl, urlString)
    }
    
    func testGooglePlaceAPIReturnsData() {
        
        // Given
        let urlString = googleAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
    
    func testGooglePlaceAPIDataCastToJson() {
        // Given
        let urlString = googleAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
        
        // check data is not nil
        XCTAssertNotNil(nextData)
        XCTAssertNil(nextError)
        
        guard let data = nextData else { return }
        
        // Check json is not nil
        let json = try? JSONSerialization.jsonObject(with: data)
        XCTAssertNotNil(json)
        
        // Check the first value is not nil
        let dictionary = json as? [String: Any]
        XCTAssertNotNil(dictionary)
    }
    
    func testGooglePlaceAPIJsonDataHasCandidates() {
        // Given
        let urlString = googleAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
        
        // check data is not nil
        XCTAssertNotNil(nextData)
        XCTAssertNil(nextError)
        
        guard let data = nextData,
            let json = try? JSONSerialization.jsonObject(with: data),
            let dictionary = json as? [String: Any]
        else { return }
        
        // check candidates
        let locationsCandidates = dictionary["candidates"] as? [Any]
        XCTAssertNotNil(locationsCandidates)
    }
    
    func testFetchLocationsOfPlaceFromGooglePlaceAPI() {
        // Given
        let place = "southbank centre"
        let urlString =
            "https://maps.googleapis.com/maps/api/place/findplacefromtext/" +
                "json?input=\(place)&inputtype=textquery" +
                "&fields=formatted_address,name,geometry" +
        "&key=\(Constants.GOOGLE_API_KEY.rawValue)"
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var nextData: Data?
        
        // When
        let encodingUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: encodingUrl) else {
            fatalError("URL can't be empty or have spacing")
        }
        httpClient.fetchData(url: url) { (success, error) in
            nextData = success
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
       
        guard let data = nextData,
            let json = try? JSONSerialization.jsonObject(with: data),
            let dictionary = json as? [String: Any],
            let locationsCandidates = dictionary["candidates"] as? [Any]
        else { return }

        let locationResponses = locationsCandidates as? [[String: AnyObject]]
        XCTAssertNotNil(locationResponses)
        
        let placeResponse = locationResponses?.first
        XCTAssertNotNil(placeResponse)
        
        guard let placeResult = placeResponse else {
            fatalError("Decoding error")
        }
        let name = placeResult["name"] as? String
        XCTAssertNotNil(name)
        
        let address = placeResult["formatted_address"] as? String
        XCTAssertNotNil(address)
        
        let geometry = placeResult["geometry"] as? [String: AnyObject]
        XCTAssertNotNil(geometry)
        
        let location = geometry?["location"] as? [String: AnyObject]
        XCTAssertNotNil(location)
        
        let latitude = location?["lat"] as? Double
        XCTAssertNotNil(latitude)
        
        let longitude = location?["lng"] as? Double
        XCTAssertNotNil(longitude)
    }

}
