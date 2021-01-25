//
//  AppCoordinator.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/25/21.
//

import UIKit

class AppCoordinator: ParentCoordinator {

    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return startupNavigationController
    }

    private let window: UIWindow
    private let startupNavigationController: UINavigationController = UINavigationController()

    init(window: UIWindow) {
        self.window = window
        window.rootViewController = rootViewController
    }

    func start() {
        showEmployees()
        window.makeKeyAndVisible()
    }

    private func showEmployees() {
        let employeeListCoordinator = EmployeeInformationCoordinator(startupNavigationController)
        childCoordinators.append(employeeListCoordinator)
        employeeListCoordinator.parentCoordinator = self
        employeeListCoordinator.start()
    }
}
