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
    let transitionManager: CellTransitionManager = CellTransitionManager()
    
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
        imageManager: ImageFetchable = ImageManager()
    ) {
        self.view = view
        self.networkManager = networkManager
        self.logger = logger
        self.imageManager = imageManager
    }
    
    // CollectionView
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
                    cell.setImage(image)
                case .failure(let error):
                    self?.logger.logEvent("🖼 Unable to fetch image for \(employee.smallPhotoURL ?? "No Image")\nError: \(error.localizedDescription)")
                    cell.setImage(UIImage(systemName: "photo.fill")!)
                }
            }
        } else {
            // Typically I wouldn't force unwrap here, 
            cell.setImage(UIImage(systemName: "photo.fill")!)
        }
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
    
    // MARK: - Actions
    func fetchEmployees() {
        networkManager.fetchEmployees { [weak self] (result) in
            switch result {
            case .success(let employees):
                self?.employees = employees
                if employees.isEmpty {
                    self?.view.presentError("Employees came back empty...")
                } else {
                    self?.view.reload()
                }
            case .failure(let error):
                self?.view.presentError("Error Retrieving Employees: \(error.localizedDescription)")
            }
        }
    }
    
}
