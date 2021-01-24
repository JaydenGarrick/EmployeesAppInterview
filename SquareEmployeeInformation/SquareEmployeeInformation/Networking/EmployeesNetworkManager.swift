//
//  EmployeesNetworkManager.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import Foundation

typealias EmployeesBackendResponse = (Result<[Employee], EmployeesNetworkError>) -> Void

enum EmployeesNetworkError: Error {
    case badURL
    case networkError(NetworkError)
}

protocol EmployeesFetchable {
    func fetchEmployees(completion: @escaping EmployeesBackendResponse)
}

class EmployeesNetworkManager: EmployeesFetchable {
    
    enum Constants {
        static let baseURL = "https://s3.amazonaws.com/sq-mobile-interview/employees.json"
//        static let baseURL = "https://s3.amazonaws.com/sq-mobile-interview/employees_empty.json"
//        static let baseURL = "https://s3.amazonaws.com/sq-mobile-interview/employees_malformed.json"

    }
        
    var networkClient: NetworkRequestRetrievable
    var logger: Loggable
    
    init(
        _ networkClient: NetworkRequestRetrievable = NetworkManager(),
        _ logger: Loggable = Logger()
    ) {
        self.networkClient = networkClient
        self.logger = logger
    }
    
    func fetchEmployees(completion: @escaping EmployeesBackendResponse) {
        guard let url = URL(string: Constants.baseURL) else {
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
