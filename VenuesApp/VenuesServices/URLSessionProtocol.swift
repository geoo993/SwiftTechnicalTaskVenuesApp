//
//  URLSessionProtocol.swift
//  VenuesServices
//
//  Created by GEORGE QUENTIN on 23/05/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//



public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest,
                  completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}
extension URLSession: URLSessionProtocol {
    public func dataTask(with request: URLRequest,
                         completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completion) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}




public protocol URLSessionDataTaskProtocol {
    func resume()
}
extension URLSessionDataTask: URLSessionDataTaskProtocol {}
