//
//  EmployeeDetailViewPresenter.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import UIKit

class EmployeeDetailViewPresenter {
    // MARK: - Properties
    
    // view
    var view: EmployeeDetailable
    var employee: Employee
    let imageManager: ImageFetchable
    let logger: Loggable
    
    // MARK: - Initialization
    init(
        _ view: EmployeeDetailable,
        _ employee: Employee,
        imageManager: ImageFetchable = ImageManager(),
        logger: Loggable = Logger()
    ) {
        self.view = view
        self.employee = employee
        self.imageManager = imageManager
        self.logger = logger
    }
    
    // MARK: - Actions
    func updateImageToHighRes() {
        // Check to see if the employee has a large image URL
        if let largeImageURL = employee.largePhotoURL {
            imageManager.fetchImage(with: largeImageURL) { [weak self] (result) in
                switch result {
                case .success(let image):
                    self?.view.updateHighResImage(image)
                case .failure(let error):
                    self?.logger.logEvent("⚠️ Failure Fetching High Res Image: \(error.localizedDescription)")
                }
            }
        } else {
            logger.logEvent("⚠️ \(employee.fullName) has no large image URL")
            self.view.updateHighResImage(UIImage(systemName: "photo.fill")!)
        }
    }
}
