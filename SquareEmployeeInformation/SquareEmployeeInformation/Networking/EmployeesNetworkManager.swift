//
//  EmployeesNetworkManager.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import Foundation

/*
 I am a sucker for dependency injection, so singletons aren't my favorite
 I am adding this just as a simple debugging tool to switch between the given
 URLs and made it a singleton to keep this feature simple
 */
class URLManager {
    static let shared = URLManager() ; private init() {}
    var url = "https://s3.amazonaws.com/sq-mobile-interview/employees.json"
    
    enum URLResponseType {
        case good
        case empty
        case malformedJSON
    }
    
    func updateURLTo(type: URLResponseType) {
        switch type {
        case .good:
            url = "https://s3.amazonaws.com/sq-mobile-interview/employees.json"
        case .empty:
            url = "https://s3.amazonaws.com/sq-mobile-interview/employees_empty.json"
        case .malformedJSON:
            url = "https://s3.amazonaws.com/sq-mobile-interview/employees_empty.json"
        }
    }
}

typealias EmployeesBackendResponse = (Result<[Employee], EmployeesNetworkError>) -> Void

enum EmployeesNetworkError: Error {
    case badURL
    case networkError(NetworkError)
}

protocol EmployeesFetchable {
    func fetchEmployees(completion: @escaping EmployeesBackendResponse)
}

class EmployeesNetworkManager: EmployeesFetchable {
        
    var networkClient: NetworkRequestRetrievable
    var logger: Loggable
    
    init(
        networkClient: NetworkRequestRetrievable = NetworkManager(),
        logger: Loggable = Logger()
    ) {
        self.networkClient = networkClient
        self.logger = logger
    }
    
    func fetchEmployees(completion: @escaping EmployeesBackendResponse) {
        let urlString = URLManager.shared.url
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        logger.logEvent("🛰 Making request to \(url.absoluteString)")
        networkClient.jsonRequest(
            url: url,
            type: EmployeeTopLevelJSON.self,
            httpMethod: .get) { [weak self] (result) in
            switch result {
            case .success(let topLevelJSON):
                self?.logger.logEvent("✅ Successfully fetched employees, total employees: \(topLevelJSON.employees.count)")
                completion(.success(topLevelJSON.employees))
            case .failure(let networkError):
                self?.logger.logEvent("❌ Unable to fetch employees: \(networkError.localizedDescription)")
                completion(.failure(.networkError(networkError)))
                return
            }
        }
    }
        
}
