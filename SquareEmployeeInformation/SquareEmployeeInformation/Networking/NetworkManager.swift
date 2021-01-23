//
//  NetworkManager.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import Foundation

// MARK: - Protocols to manage dependencies
protocol URLSessionRetrievable {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}
extension URLSession: URLSessionRetrievable {}

protocol JSONDecodable {
    func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get set }
}
protocol JSONEncodable {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}
extension JSONDecoder: JSONDecodable {}
extension JSONEncoder: JSONEncodable {}


class NetworkManager: NetworkRequestRetrievable {
    
    // MARK: - Properties
    let urlSession: URLSessionRetrievable
    let logger: Loggable
    var jsonDecoder: JSONDecodable
    let jsonEncoder: JSONEncodable
    
    init(urlSession: URLSessionRetrievable = URLSession.shared,
                  logger: Loggable = Logger(),
                  jsonDecoder: JSONDecodable = JSONDecoder(),
                  jsonEncoder: JSONEncodable = JSONEncoder()) {
        self.urlSession = urlSession
        self.logger = logger
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
    }
    
    func jsonRequest<ReturnType: Decodable>(
        url: URL,
        type: ReturnType.Type,
        httpMethod: HTTPMethod,
        completion: @escaping (Result<ReturnType, NetworkError>) -> Void
    ) {
        // DataRequest
        var dataRequest = URLRequest(url: url)
        dataRequest.httpMethod = httpMethod.rawValue
        
        // DataTask
        urlSession.dataTask(with: dataRequest) { [weak self] (data, response, error) in
            if let error = error {
                self?.logger.logEvent("Error: \(error.localizedDescription)")
                completion(.failure(.unknownError(message: error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                self?.logger.logEvent("Error retrieving data")
                completion(.failure(.missingData))
                return
            }
            do {
                guard let returnValue = try self?.jsonDecoder.decode(ReturnType.self, from: data) else {
                    self?.logger.logEvent("Unable to retain 'self' in \(#function)")
                    completion(.failure(.unknownError(message: "Unable to retain self")))
                    return
                }
                completion(.success(returnValue))
            } catch(let error) {
                self?.logger.logEvent("Unknown error: \(error.localizedDescription)")
                completion(.failure(.unableToDecode))
                return
            }
        }.resume()
    }
    
    func jsonRequest<ReturnType: Decodable>(
        url: URL,
        type: ReturnType.Type,
        httpMethod: HTTPMethod,
        headers: [String : String],
        completion: @escaping (Result<ReturnType, NetworkError>) -> Void
    ) {
        // DataRequest
        var dataRequest = URLRequest(url: url)
        dataRequest.httpMethod = httpMethod.rawValue
        for (key, value) in headers {
            dataRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // DataTask
        urlSession.dataTask(with: dataRequest) { [weak self] (data, response, error) in
            guard let self = self else {
                completion(.failure(.unknownError(message: "Unable to retain self")))
                return
            }
            
            if let error = error {
                self.logger.logEvent("Error: \(error.localizedDescription)")
                completion(.failure(.unknownError(message: error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                self.logger.logEvent("Error retrieving data")
                completion(.failure(.missingData))
                return
            }
            
            do {
                let returnValue = try self.jsonDecoder.decode(ReturnType.self, from: data)
                completion(.success(returnValue))
            } catch(let error) {
                self.logger.logEvent("Unknown error: \(error.localizedDescription)")
                completion(.failure(.unknownError(message: error.localizedDescription)))
                return
            }
        }.resume()
    }
    
    
}
