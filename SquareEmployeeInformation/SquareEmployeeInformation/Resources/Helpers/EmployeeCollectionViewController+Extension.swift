//
//  EmployeeCollectionViewController+Extension.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import UIKit

extension EmployeesCollectionViewController {
    @objc func addTapped() {
        let alertController = UIAlertController(title: "Switch Network", message: nil, preferredStyle: .actionSheet)
        let goodEndpointAction = UIAlertAction(title: "Good Endpoint", style: .default) { [weak self] (_) in
            self?.presenter.resetEndpointTo(.good)
            self?.presenter.fetchEmployees()
        }
        let emptyEndpointAction = UIAlertAction(title: "Empty Endpoint", style: .default) { [weak self] (_) in
            self?.presenter.resetEndpointTo(.empty)
            self?.presenter.fetchEmployees()
        }
        let malformedEndpointAction = UIAlertAction(title: "Malformed Endpoint", style: .default) { [weak self] (_) in
            self?.presenter.resetEndpointTo(.malformedJSON)
            self?.presenter.fetchEmployees()
        }
        alertController.addAction(goodEndpointAction)
        alertController.addAction(emptyEndpointAction)
        alertController.addAction(malformedEndpointAction)
        
        present(alertController, animated: true)
    }
}
