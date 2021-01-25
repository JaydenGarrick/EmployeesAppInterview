//
//  Employee.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import Foundation

struct EmployeeTopLevelJSON: Codable {
    let employees: [Employee]
}

enum EmployeeType: String, Codable, Equatable {
    case fullTime
    case partTime
    case contractor
    case unknown
    
    var description: String {
        switch self {
        case .fullTime:
            return "FT"
        case .partTime:
            return "PT"
        case .contractor:
            return "C"
        case .unknown:
            return "Unknown Employee Type"
        }
    }
}

struct Employee: Codable, Equatable {
    let uuid: UUID
    let fullName: String
    let phoneNumber: String?
    let emailAddress: String
    let biography: String?
    let smallPhotoURL: String?
    let largePhotoURL: String?
    let team: String
    let employeeType: EmployeeType
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case emailAddress = "email_address"
        case biography
        case smallPhotoURL = "photo_url_small"
        case largePhotoURL = "photo_url_large"
        case team
        case employeeType = "employee_type"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(UUID.self, forKey: .uuid)
        fullName = try values.decode(String.self, forKey: .fullName)
        phoneNumber = try values.decode(String?.self, forKey: .phoneNumber)
        emailAddress = try values.decode(String.self, forKey: .emailAddress)
        biography = try values.decode(String?.self, forKey: .biography)
        smallPhotoURL = try values.decode(String?.self, forKey: .smallPhotoURL)
        largePhotoURL = try values.decode(String?.self, forKey: .largePhotoURL)
        team = try values.decode(String.self, forKey: .team)
        
        // Custom Decoding for Enum Type
        let employeeTypeString = try values.decode(String?.self, forKey: .employeeType)
        let _employeeType: EmployeeType
        switch employeeTypeString {
        case "FULL_TIME":
            _employeeType = .fullTime
        case "PART_TIME":
            _employeeType = .partTime
        case "CONTRACTOR":
            _employeeType = .contractor
        default:
            _employeeType = .unknown
        }
        employeeType = _employeeType
    }
}
