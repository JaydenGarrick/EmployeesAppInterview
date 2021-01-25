//
//  HomeCoordinator.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/25/21.
//

import UIKit

protocol EmployeeInformationNavigator: class {
    func goToDetailViewWith(_ viewModel: EmployeeDetailViewModel)
    func presentError(_ message: String)
}

class EmployeeInformationCoordinator: NSObject, ChildCoordinator {
    // MARK: - Properties
    var parentCoordinator: ParentCoordinator?
    private let navigationController: UINavigationController
    var rootViewController: UIViewController {
        return navigationController
    }
    let employeesCollectionViewController: EmployeesCollectionViewController = {
        // Retrieve the EmployeesCollectionViewController from Main.storyboard
        guard let employeesCollectionViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: Constants.employeesCollectionViewController)
                as? EmployeesCollectionViewController else {
            fatalError("Unable to retrieve Detail ViewController from Main.storyboard")
        }
        return employeesCollectionViewController
    }()
    
    // MARK: - Constants
    enum Constants {
        static let employeesCollectionViewController = "EmployeesCollectionViewController"
        static let detailViewController = "EmployeeDetailViewController"
    }

    // MARK: - Initialization
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        navigationController.delegate = self
        navigationController.pushViewController(employeesCollectionViewController, animated: true)
    }
    
}

// MARK: EmployeeInformationNavigator
extension EmployeeInformationCoordinator: EmployeeInformationNavigator {
    func goToDetailViewWith(_ viewModel: EmployeeDetailViewModel) {
        /*
        Ideally I wouldn't be using storyboards, but to save time I'm doing it here.
        I could use storyboard segue's, however I don't like that pattern so I'm
        instantiating the VC here
        */
        guard let detailViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: Constants.detailViewController)
                as? EmployeeDetailViewController else {
            fatalError("Unable to retrieve Detail ViewController from Main.storyboard")
        }
        detailViewController.viewModel = viewModel
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    func presentError(_ message: String) {
        let alertController = UIAlertController(title: "Please try again...", message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] (_) in
            self?.employeesCollectionViewController.presenter.fetchEmployees()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(retryAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async { [weak self] in
            self?.navigationController.present(alertController, animated: true)
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension EmployeeInformationCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let employeeCollectionViewController = viewController as? EmployeesCollectionViewController {
            employeeCollectionViewController.presenter.navigator = self
        }
    }
}
