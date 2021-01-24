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
