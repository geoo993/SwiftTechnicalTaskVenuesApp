//
//  HTTPClient.swift
//  VenuesServices
//
//  Created by GEORGE QUENTIN on 23/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

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
            networkRequest(data, error)
        }
        task.resume()
    }
}
