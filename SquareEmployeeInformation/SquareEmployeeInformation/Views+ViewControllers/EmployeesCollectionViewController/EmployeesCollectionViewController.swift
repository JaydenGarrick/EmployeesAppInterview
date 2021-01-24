//
//  ViewController.swift
//  SquareEmployeeInformation
//
//  Created by Jayden Garrick on 1/23/21.
//

import UIKit

protocol EmployeesResultable {
    func reload()
    func presentError(_ message: String)
    func navigateToDetailViewController(with viewModel: EmployeeDetailViewModel)
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
        
        // Presenter
        presenter = EmployeePresenter(self)
        presenter.fetchEmployees()
    }
    
}

// MARK: CollectionView Delegate + Datasource
extension EmployeesCollectionViewController: UICollectionViewDelegateFlowLayout
 {
    // HEADER
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return presenter.headerSizeFor(collectionView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return presenter.headerFor(collectionView, indexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItemsInSection
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return presenter.cellForRowAt(indexPath, inside: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return presenter.cellSize(for: collectionView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath, inside: collectionView)
    }
    
}

extension EmployeesCollectionViewController: EmployeesResultable {
    func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func presentError(_ message: String) {
        let alertController = UIAlertController(title: "Please try again...", message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] (_) in
            self?.presenter.fetchEmployees()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(retryAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true)
        }
    }
    
    func navigateToDetailViewController(with viewModel: EmployeeDetailViewModel) {
        /*
        Ideally I wouldn't be using storyboards, but to save time I'm doing it here
        I could use storyboard segue's, however I don't like that pattern so I'm
        instantiating here
        */
        guard let detailViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: Constants.detailViewController)
                as? EmployeeDetailViewController else {
            fatalError("Unable to retrieve Detail ViewController from Main.storyboard")
        }
        detailViewController.viewModel = viewModel
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
