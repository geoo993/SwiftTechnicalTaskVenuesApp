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

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    func resume() {
        resumeWasCalled = true
    }
}

class MockURLSession: URLSessionProtocol {
    var nextDataTask = MockURLSessionDataTask()
    private (set) var lastURL: URL?
    private var nextData: Data?
    private var nextError: Error?
    private func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with request: URLRequest,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        completion(nextData, successHttpURLResponse(request: request), nextError)
        return nextDataTask
    }
}

class EventogyVenuesGoogleAPIAppTests: XCTestCase {
   
    let googleAPIUrl =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/" +
            "json?input=southbank centre&inputtype=textquery" +
            "&fields=formatted_address,name,geometry" + "&key=\(Constants.GOOGLE_API_KEY.rawValue)"
    var httpClient: HttpClient!
    let session = MockURLSession()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        httpClient = HttpClient(session: session)
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
    func testFetchDataFromGooglePlaceAPIWithURL() {
        // Given
        let urlString = googleAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        // When
        guard let url = URL(string: urlString) else {
            fatalError("URL can't be empty")
        }
        httpClient.fetchData(url: url) { (success, response) in
            // Return data
        }
        
        // Then
        XCTAssert(session.lastURL == url)
    }
    func testURLSessionResume() {
        // Given
        let urlString = googleAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let dataTask = MockURLSessionDataTask()
        session.nextDataTask = dataTask
        
        // When
        guard let url = URL(string: urlString) else {
            fatalError("URL can't be empty")
        }
        httpClient.fetchData(url: url) { (success, response) in
            // Return data
        }
        
        // Then
        XCTAssert(dataTask.resumeWasCalled)
    }
    func testURLSessionRequestReturnData() {
        
        // Given
        let urlString = googleAPIUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        httpClient = HttpClient() // use URLSession.shared
        
        
        let dataExpectation = expectation(description: "Wait for \(urlString) to load.")
        var data: Data?
        
        // When
        guard let url = URL(string: "http://masilotti.com") else {
            fatalError("URL can't be empty")
        }
        httpClient.fetchData(url: url) { (success, response) in
            data = success
            dataExpectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(data)
        
    }
    /*
    func testFetchLocationsFromGooglePlaceAPI() {
        // Given
        let place = "southbank centre"
        let parameters = ["name":"", "address":"", "latitude": 0.0, "longitude":0.0] as [String : Any]
        let urlString =
            "https://maps.googleapis.com/maps/api/place/findplacefromtext/" +
                "json?input=\(place)&inputtype=textquery" +
                "&fields=formatted_address,name,geometry" +
        "&key=\(Constants.GOOGLE_API_KEY.rawValue)"
        
        // When
        let encodingUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: encodingUrl)
        
        // Then
        XCTAssertNotEqual(encodingUrl, urlString)
        
        XCTAssertNotNil(url)
        
        guard let safeUrl = url else { return }
        
        print(url, encodingUrl, urlString)
        
        URLSession.shared
            .dataTask(with: safeUrl) { (dataresult, response, error) in
            
            // check that we have no errors
            XCTAssertNil(error)
            
            // check data is not nil
            XCTAssertNotNil(dataresult)
            guard let data = dataresult else { return }
            
            // Check json is not nil
            let json = try? JSONSerialization.jsonObject(with: data)
            XCTAssertNotNil(json)
            
            // Check the first value is not nil
            let dictionary = json as? [String: Any]
            XCTAssertNotNil(dictionary)
            
            guard let safeDictionary = dictionary else { return }
            
            // check candidates
            let locationsCandidates = safeDictionary["candidates"] as? [Any]
            XCTAssertNotNil(locationsCandidates)
            
            guard let locationsResponse = locationsCandidates else { return }
            print(locationsResponse)
//
//            var places = [VenuesModel.Place]()
//            guard let locationResponses = locationsResponse as? [[String: AnyObject]] else { return }
//            for placeResponse in locationResponses {
//                guard let name = placeResponse["name"] as? String,
//                    let address = placeResponse["formatted_address"] as? String,
//                    let geometry = placeResponse["geometry"] as? [String: AnyObject],
//                    let location = geometry["location"] as? [String: AnyObject],
//                    let latitude = location["lat"] as? Double,
//                    let longitude = location["lng"] as? Double
//                    else { //completion(NetworkResult.error("JSON decoding error of of locations.")); return
//                        return
//                }
//                var locationData = this.placePlaceholder
//                locationData["name"] = name
//                locationData["address"] = address
//                locationData["latitude"] = latitude
//                locationData["longitude"] = longitude
//                places.append(Place(data: locationData))
//            }
        }.resume()
        
        
        // Then
        //XCTAssert(toFirstCapitalLetter == "My first word")
    }
 */
}

//EventogyVenuesGoogleAPIAppTests.defaultTestSuite.run()
