//
//  ViewController.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import UIKit

protocol EmployeesResultable: class {
    func reload()
}

final class EmployeesCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    var presenter: EmployeePresenter!
    
    // Constants
    enum Constants {
        static let cellIdentifier = "EmployeeCollectionViewCellIdentifier"
        static let cellName = "EmployeeCollectionViewCell"
        static let headerName = "EmployeeCollectionViewHeader"
        static let headerIdentifier = "EmployeeCollectionViewHeaderIdentifier"
        static let title = "Employees"
        static let detailViewController = "EmployeeDetailViewController"
    }
    
    // MARK: - ViewLifecycle + Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
        
    private func initialSetup() {
        // CollectionView
        collectionView.register(UINib(nibName: Constants.cellName, bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.register(UINib(nibName: Constants.headerName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.headerIdentifier)        

        // NavBar
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = Constants.title
        #if DEBUG
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        #endif
        
        // Presenter
        presenter = EmployeePresenter(self, collectionView: collectionView)
        presenter.fetchEmployees()
    }
    
}

// MARK: CollectionView Delegate + Datasource
extension EmployeesCollectionViewController: UICollectionViewDelegateFlowLayout
 {
    // HEADER
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return presenter.headerSize()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return presenter.headerFor(indexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItemsInSection
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return presenter.cellForRowAt(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return presenter.cellSize(for: collectionView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath)
    }
    
}

extension EmployeesCollectionViewController: EmployeesResultable {
    func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}
