//
//  URLOpenableProtocols.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import UIKit

// Methods to be able to mock UIApplication.shared dependency
protocol URLHandlerable {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL)
}
extension UIApplication: URLHandlerable {
    func open(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
