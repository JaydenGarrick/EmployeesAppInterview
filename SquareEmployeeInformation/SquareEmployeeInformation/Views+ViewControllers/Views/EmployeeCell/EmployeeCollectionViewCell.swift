//
//  EmployeeCollectionViewCell.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import UIKit

protocol EmployeeCollectionViewCellDelegate: class {
    func emailButtonTapped(with email: String)
    func phoneNumberButtonTapped(with number: String?)
}

final class EmployeeCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    
    // Dependency
    var employee: Employee! {
        didSet {
            setupView()
        }
    }
    
    // UI Elements
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var employeeImageView: UIImageView!
    @IBOutlet weak var teamLabel: UILabel!
    
    // Delegate
    weak var delegate: EmployeeCollectionViewCellDelegate?
    
    // MARK: - Setup
    func setupView() {
        nameLabel.text = employee.fullName
        emailButton.setTitle(employee.emailAddress, for: .normal)
        phoneNumberButton.setTitle(employee.phoneNumber?.formatWith(mask: "(XXX) XXX-XXXX"), for: .normal)
        phoneNumberButton.isHidden = (employee.phoneNumber == nil)
        teamLabel.text = "\(employee.team) (\(employee.employeeType.description))"
    }
    
    func setImage(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.employeeImageView.image  = image
        }
    }
    
    // MARK: - Actions
    @IBAction func emailButtonTapped(_ sender: Any) {
        delegate?.emailButtonTapped(with: employee.emailAddress)
    }
    
    @IBAction func phoneNumberButtonTapped(_ sender: Any) {
        delegate?.phoneNumberButtonTapped(with: employee.phoneNumber)
    }
    
    // MARK: - CellReuse
    override func prepareForReuse() {
        employeeImageView.image = UIImage(systemName: "photo.fill")
        super.prepareForReuse()
    }
    
}
