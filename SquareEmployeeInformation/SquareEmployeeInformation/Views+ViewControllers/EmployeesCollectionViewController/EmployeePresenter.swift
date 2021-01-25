//
//  EmployeePresenter.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import UIKit

final class EmployeePresenter {
    
    // Dependencies
    let networkManager: EmployeesFetchable
    let logger: Loggable
    let imageManager: ImageFetchable
    let urlHandler: URLHandlerable
    
    // Source of Truth
    var employees: [Employee] = []
    
    // View
    var view: EmployeesResultable
    
    var numberOfItemsInSection: Int {
        return employees.count
    }
    
    // MARK: - Initialization
    init(
        _ view: EmployeesResultable,
        networkManager: EmployeesFetchable = EmployeesNetworkManager(),
        logger: Loggable = Logger(),
        imageManager: ImageFetchable = ImageManager(),
        urlHandler: URLHandlerable = UIApplication.shared
    ) {
        self.view = view
        self.networkManager = networkManager
        self.logger = logger
        self.imageManager = imageManager
        self.urlHandler = urlHandler
    }
    
    // MARK: - CollectionView Decorations
    func cellForRowAt(_ indexPath: IndexPath,
                      inside collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmployeesCollectionViewController.Constants.cellIdentifier,
                                                            for: indexPath) as? EmployeeCollectionViewCell else {
            view.presentError("Unable to load cells")
            logger.logEvent("⚠️ Unable to load cells inside \(#function)")
            return UICollectionViewCell()
        }
        let employee = employees[indexPath.row]
        cell.employee = employee
        
        if let imageURL = employee.smallPhotoURL {
            imageManager.fetchImage(with: imageURL) { [weak self] (result) in
                switch result {
                case .success(let image):
                    self?.logger.logEvent("✅ Successfully fetched image at \(employee.smallPhotoURL ?? "")")
                    cell.setImage(image)
                case .failure(let error):
                    self?.logger.logEvent("⚠️ Unable to fetch image for \(employee.smallPhotoURL ?? "No Image")\nError: \(error.localizedDescription)")
                    cell.setImage(UIImage(systemName: "photo.fill")!)
                }
            }
        } else {
            // Typically I wouldn't force unwrap here,
            cell.setImage(UIImage(systemName: "photo.fill")!)
            logger.logEvent("Small image URL is null")
        }
        cell.delegate = self
        return cell
    }
    
    func cellSize(for collectionView: UICollectionView) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 115)
    }
    
    func headerFor(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmployeesCollectionViewController.Constants.headerIdentifier, for: indexPath)
        return headerView
    }
    
    func headerSizeFor(_ collectionView: UICollectionView) -> CGSize {
        if employees.isEmpty {
            logger.logEvent("Headerview is showing")
            return CGSize(width: collectionView.frame.width, height: 300)
        } else {
            logger.logEvent("Header view is NOT showing")
            return .zero
        }
    }
    
    // MARK: - Actions
    func didSelectItem(at indexPath: IndexPath,
                       inside collectionView: UICollectionView) {
        var image = UIImage(systemName: "photo.fill")!
        if let cell = collectionView.cellForItem(at: indexPath) as? EmployeeCollectionViewCell {
            image = cell.employeeImageView.image ?? UIImage(systemName: "photo.fill")!
        }
        
        let employee = employees[indexPath.row]
        let viewModel = EmployeeDetailViewModel(employee: employee, lowResImage: image)
        view.navigateToDetailViewController(with: viewModel)
    }
    
    func resetEndpointTo(_ type: URLManager.URLResponseType) {
        switch type {
        case .good:
            logger.logEvent("Updating backend to be the good response")
            URLManager.shared.updateURLTo(type: .good)
        case .empty:
            logger.logEvent("Updating backend to be the empty response")
            URLManager.shared.updateURLTo(type: .empty)
        case .malformedJSON:
            logger.logEvent("Updating backend to be the malformed response")
            URLManager.shared.updateURLTo(type: .malformedJSON)
        }
    }
    
    func fetchEmployees() {
        employees = []
        networkManager.fetchEmployees { [weak self] (result) in
            switch result {
            case .success(let employees):
                self?.employees = employees
                self?.logger.logEvent("Successfully fetched employees")
                if employees.isEmpty {
                    self?.view.presentError("Employees came back empty...")
                    self?.view.reload()
                } else {
                    self?.view.reload()
                }
            case .failure(let error):
                self?.view.presentError("Error Retrieving Employees: \(error.localizedDescription)")
                self?.logger.logEvent("Error Retrieving Employees: \(error.localizedDescription)")
                self?.view.reload()
            }
        }
    }
    
}

// MARK: - EmployeeCollectionViewCellDelegate
extension EmployeePresenter: EmployeeCollectionViewCellDelegate {
    func emailButtonTapped(with email: String) {
        logger.logEvent("Attempting to open email app for \(email)")
        if let url = URL(string: "mailto://\(email)"), urlHandler.canOpenURL(url) {
            urlHandler.open(url)
        } else {
            view.presentError("Can't send email to \(email) on this device")
        }
    }
    
    func phoneNumberButtonTapped(with number: String?) {
        guard let number = number else {
            logger.logEvent("No number associated with employee")
            return
        }
        logger.logEvent("Attempting to call \(number)")
        if let url = URL(string: "tel://\(number)"), urlHandler.canOpenURL(url) {
            urlHandler.open(url)
        } else {
            view.presentError("Can't make call to \(number) on this device")
        }
    }
}
