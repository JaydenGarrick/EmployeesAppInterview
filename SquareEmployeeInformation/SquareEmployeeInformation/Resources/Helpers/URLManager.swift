//
//  URLManager.swift
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
            url = "https://s3.amazonaws.com/sq-mobile-interview/employees_malformed.json"
        }
    }
}
