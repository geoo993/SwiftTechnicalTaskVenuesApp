//
//  EventogyVenuesURLSessionTests.swift
//  EventogyVenuesAppTests
//
//  Created by GEORGE QUENTIN on 23/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
// http://masilotti.com/testing-nsurlsession-input/
// http://masilotti.com/testing-nsurlsession-async/
import XCTest
import VenuesServices
import VenuesModel
import VenuesCore
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
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?
    private func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with request: URLRequest,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        if let _ = nextError {
            completion(nextData, nextResponse, NetworkError.dataTaskError)
        } else if let response = nextResponse as? HTTPURLResponse, 200...299 ~= response.statusCode {
            completion(nextData, response, nil)
        } else {
            completion(nextData, nextResponse, NetworkError.badResponse)
        }
        return nextDataTask
    }
}

class EventogyVenuesURLSessionTests: XCTestCase {
    
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
    
    func testFetchDataFromGoogleWithURL() {
        // Given
        let urlString = "www.google.com"
        
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
        let urlString = "www.google.com"
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

    func testFetchDataURLSessionRequestReturnsTheData() {
        // Given
        guard let url = URL(string: "www.google.com") else {
            fatalError("URL can't be empty")
        }
        let expectedData = "{}".data(using: String.Encoding.utf8)
        session.nextData = expectedData
        session.nextResponse = HTTPURLResponse(url: url, statusCode: 200)
        var actualData: Data?
        
        // When
        httpClient.fetchData(url: url) { (data, _) in
            actualData = data
        }
        
        // Then
        XCTAssertEqual(actualData, expectedData)
    }
    
    func testFetchDataURLSessionRequestReturnsANetworkError() {
        
        // Given
        session.nextError = NSError(domain: "error", code: 0, userInfo: nil)
        
        // When
        guard let url = URL(string: "www.google.com") else {
            fatalError("URL can't be empty")
        }
        var actualError: Error?
        
        httpClient.fetchData(url: url) { (_, error) in
            actualError = error
        }
        
        // Then
        XCTAssertNotNil(actualError)
    }
    
    func testFetchDataURLSessionReturnsAStatusCodeLessThan200ReturnsAnError() {
        // Given
        let url = URL(string: "www.google.com")!
        session.nextResponse = HTTPURLResponse(url: url,
                                               statusCode: 199, httpVersion: nil, headerFields: nil)
        
        // When
        var actualError: NetworkError?
        httpClient.fetchData(url: url) { (_, error) in
            actualError = error as? NetworkError
        }

        // Then
        XCTAssertNotNil(actualError)
    }
    
    func testFetchDataURLSessionReturnsAStatusCodeGreaterThan299ReturnsAnError() {
        // Given
        let url = URL(string: "www.google.com")!
        session.nextResponse = HTTPURLResponse(url: url,
                                               statusCode: 300, httpVersion: nil, headerFields: nil)
        var actualError: NetworkError?
        httpClient.fetchData(url: url) { (_, error) in
            actualError = error as? NetworkError
        }
        
        // Then
        XCTAssertNotNil(actualError)
    }
}

//EventogyVenuesGoogleAPIAppTests.defaultTestSuite.run()
