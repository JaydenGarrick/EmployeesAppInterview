//
//  EmployeeDetailViewController.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import UIKit

protocol EmployeeDetailable {
    func updateHighResImage(_ image: UIImage)
}

struct EmployeeDetailViewModel {
    let employee: Employee
    let lowResImage: UIImage
}

final class EmployeeDetailViewController: UIViewController {
    
    // MARK: - Properties
    // Presenter
    var presenter: EmployeeDetailViewPresenter!
    
    // SOT
    var viewModel: EmployeeDetailViewModel!
        
    // UI Elements
    @IBOutlet weak var employeeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!    

    // ViewLifecycle + Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func initialSetup() {
        // Presenter
        presenter = EmployeeDetailViewPresenter(self, viewModel.employee)
        
        // UI
        nameLabel.text = viewModel.employee.fullName
        titleLabel.text = viewModel.employee.team
        biographyLabel.text = viewModel.employee.biography ?? "(No biography)"
        employeeImageView.image = viewModel.lowResImage
        
        // Fetch High Res Image
        presenter.updateImageToHighRes()
    }
    
}

// MARK: - EmployeeDetailable
extension EmployeeDetailViewController: EmployeeDetailable {
    func updateHighResImage(_ highResImage: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.employeeImageView.image = highResImage
        }
    }
}
