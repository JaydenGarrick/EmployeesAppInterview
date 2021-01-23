//
//  Logging.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import Foundation
import os

protocol Loggable {
    func logEvent(_ event: String)
}

struct Logger: Loggable {
    func logEvent(_ event: String) {
        #if DEBUG
        print("Event: \(event)")
        #endif
        os_log("Event: %@", event)
    }
}
