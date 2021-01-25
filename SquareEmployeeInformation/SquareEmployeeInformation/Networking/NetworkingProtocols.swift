//
//  NetworkingProtocols.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import Foundation

// MARK: - HTTPMethod
enum HTTPMethod: String {
    case get
    case put
    case post
    case delete
    case patch
}

// MARK: - Networking General Errors
enum NetworkError: Error {
    case unknownError(message: String)
    case unableToDecode
    case missingData
}

// MARK: Network Protocols
protocol NetworkRequestRetrievable {
    
    /// JSONRequest with no Headers
    /// - Parameters:
    ///   - url: The URL you are using for your endpoint
    ///   - type: The type you are trying to decode from the endpoint. Must conform to Decodable
    ///   - httpMethod: The HTTP method used
    ///   - completion: Completes with either your return type (type) or a NetworkError inside a `Result` type
    func jsonRequest<ReturnType: Decodable>(url: URL,
                                 type: ReturnType.Type,
                                 httpMethod: HTTPMethod,
                                 completion: @escaping (Result<ReturnType, NetworkError>) -> Void)
    
    
    /// JSONRequest with Headers
    /// - Parameters:
    ///   - url: url description
    ///   - type: type description
    ///   - httpMethod: httpMethod description
    ///   - headers: headers description
    ///   - completion: completion description
    func jsonRequest<ReturnType: Decodable>(url: URL,
                                 type: ReturnType.Type,
                                 httpMethod: HTTPMethod,
                                 headers: [String: String],
                                 completion: @escaping (Result<ReturnType, NetworkError>) -> Void)
    
}
