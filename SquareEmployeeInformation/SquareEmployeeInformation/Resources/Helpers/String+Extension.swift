//
//  String+Extension.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import Foundation

extension String {
    func formatWith(mask: String) -> String {
        let numbers = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for character in mask where index < numbers.endIndex {
            if character == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(character) // just append a mask character
            }
        }
        return result
    }
}
