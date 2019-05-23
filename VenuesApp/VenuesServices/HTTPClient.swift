//
//  HTTPClient.swift
//  VenuesServices
//
//  Created by GEORGE QUENTIN on 23/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//
public enum NetworkError: Error {
    case dataTaskError
    case badResponse
    case jsonDecodingError
}

public class HttpClient {
    public typealias NetworkRequestResult = ( _ data: Data?, _ error: Error?) -> Void
    private let session: URLSessionProtocol
    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    public func fetchData(url: URL, networkRequest: @escaping NetworkRequestResult) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            if let _ = error {
                networkRequest(nil, NetworkError.dataTaskError)
            } else if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                networkRequest(data, nil)
            } else {
                networkRequest(nil, NetworkError.badResponse)
            }
        }
        task.resume()
    }
}
