//
//  EmployeePresenter.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import UIKit

fileprivate typealias Constants = EmployeesCollectionViewController.Constants

final class EmployeePresenter {
    
    // Dependencies
    let networkManager: EmployeesFetchable
    let logger: Loggable
    let imageManager: ImageFetchable
    let urlHandler: URLHandlerable
    let collectionView: Dequeuable
    
    // Source of Truth
    var employees: [Employee] = []
    
    // View and Navigation
    weak var view: EmployeesResultable?
    weak var navigator: EmployeeInformationNavigator?
    
    var numberOfItemsInSection: Int {
        return employees.count
    }
    
    // MARK: - Initialization
    init(
        _ view: EmployeesResultable,
        collectionView: Dequeuable,
        networkManager: EmployeesFetchable = EmployeesNetworkManager(),
        logger: Loggable = Logger(),
        imageManager: ImageFetchable = ImageManager(),
        urlHandler: URLHandlerable = UIApplication.shared
    ) {
        self.view = view
        self.collectionView = collectionView
        self.networkManager = networkManager
        self.logger = logger
        self.imageManager = imageManager
        self.urlHandler = urlHandler
    }
    
    // MARK: - CollectionView Decorations
    func cellForRowAt(_ indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? EmployeeCollectionViewCell else {
            navigator?.presentError("Unable to load cells")
            logger.logEvent("⚠️ Unable to dequeue EmployeeCollectionViewCell")
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
    
    func headerFor(indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmployeesCollectionViewController.Constants.headerIdentifier, for: indexPath)
        return headerView
    }
    
    func headerSize() -> CGSize {
        if employees.isEmpty {
            logger.logEvent("Headerview is showing")
            return CGSize(width: collectionView.frame.width, height: 300)
        } else {
            logger.logEvent("Header view is NOT showing")
            return .zero
        }
    }
    
    // MARK: - Actions
    func didSelectItem(at indexPath: IndexPath) {
        var image = UIImage(systemName: "photo.fill")!
        if let cell = collectionView.cellForItem(at: indexPath) as? EmployeeCollectionViewCell {
            image = cell.employeeImageView.image ?? UIImage(systemName: "photo.fill")!
        }
        
        let employee = employees[indexPath.row]
        let viewModel = EmployeeDetailViewModel(employee: employee, lowResImage: image)
        navigator?.goToDetailViewWith(viewModel)
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
        networkManager.fetchEmployees { [weak self] (result) in
            switch result {
            case .success(let employees):
                self?.employees = employees
                self?.logger.logEvent("Successfully fetched employees")
                if employees.isEmpty {
                    self?.navigator?.presentError("Employees came back empty...")
                }
                self?.view?.reload()
            case .failure(let error):
                self?.employees.removeAll()
                self?.navigator?.presentError("Error Retrieving Employees: \(error.localizedDescription)")
                self?.logger.logEvent("Error Retrieving Employees: \(error.localizedDescription)")
                self?.view?.reload()
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
            navigator?.presentError("Can't send email to \(email) on this device")
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
            navigator?.presentError("Can't make call to \(number) on this device")
        }
    }
}
