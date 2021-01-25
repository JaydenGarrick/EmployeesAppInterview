//
//  EmployeePresenterMocks.swift
//  SquareEmployeeInformationTests
//
//  Created by Jayden Garrick on 1/24/21.
//

import XCTest
@testable import SquareEmployeeInformation


extension EmployeePresenterTests {
    // MARK: - MockView
    class MockView: EmployeesResultable {
        var viewModel: EmployeeDetailViewModel? = nil
        var errorsPresented: [String: Bool] = [:]
        var reloaded: Bool = false
        
        func reload() {
            reloaded = true
        }
        
        func presentError(_ message: String) {
            errorsPresented[message] = true
        }
        
        func navigateToDetailViewController(with viewModel: EmployeeDetailViewModel) {
            self.viewModel = viewModel
        }
    }
    
    // MARK: - NetworkMock
    class NetworkMock: EmployeesFetchable {
        var completeWithError: Bool = false
        var hasDecodingError: Bool = false
        var shouldHaveMalformedData: Bool = false
        var shouldCompleteWithEmptyEmployees = false
        var firstEmployee: Employee? = nil
        
        func fetchEmployees(completion: @escaping EmployeesBackendResponse) {
            if shouldCompleteWithEmptyEmployees {
                completion(.success([]))
                return
            }
            
            if completeWithError {
                completion(.failure(EmployeesNetworkError.unknownError("Forced Failure")))
            } else {
                let decoder = JSONDecoder()
                let resource = shouldHaveMalformedData ? "MalformedData" : "SuccessfulEmployeesReturn"
                do {
                    let bundle = Bundle(for: EmployeePresenterTests.self)
                    if let path = bundle.path(forResource: resource, ofType: "json"),
                       let data = try String(contentsOfFile: path).data(using: .utf8) {
                        let topLevelJSON = try decoder.decode(EmployeeTopLevelJSON.self, from: data)
                        firstEmployee = topLevelJSON.employees.first
                        completion(.success(topLevelJSON.employees))
                    }
                } catch {
                    hasDecodingError = true
                    completion(.failure(.networkError(.unableToDecode)))
                }
            }
        }
    }
    
    // MARK: - MarkImageManager
    class MockImageManager: ImageFetchable {
        var completeWithError: Bool = false
        var unableToDecodeImage: Bool = false
        
        func fetchImage(with urlString: String,
                        completion: @escaping (Result<UIImage, ImageError>) -> Void)
        {
            if completeWithError {
                completion(.failure(ImageError.unknownError("Forced Failure")))
            } else {
                guard let image = UIImage(systemName: "pencil") else {
                    unableToDecodeImage = true
                    completion(.failure(.unknownError("Unable to find pencil image")))
                    return
                }
                completion(.success(image))
            }
        }
    }
    
    class MockLogger: Loggable {
        var eventLogged: [String: Bool] = [:]
        
        func logEvent(_ event: String) {
            eventLogged[event] = true
        }
    }
    
    class MockURLHandler: URLHandlerable {
        var canOpen: Bool = true
        var urlOpened: Bool = false
        func canOpenURL(_ url: URL) -> Bool {
            return canOpen
        }
        
        func open(_ url: URL) {
            urlOpened = true
        }
    }
    
    class MockCollectionView {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: UICollectionViewLayout())
        
        enum Constants {
            static let cellIdentifier = "EmployeeCollectionViewCellIdentifier"
            static let cellName = "EmployeeCollectionViewCell"
            static let headerName = "EmployeeCollectionViewHeader"
            static let headerIdentifier = "EmployeeCollectionViewHeaderIdentifier"
        }
        
        init() {
            collectionView.register(UINib(nibName: Constants.cellName, bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
            collectionView.register(UINib(nibName: Constants.headerName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.headerIdentifier)
        }
        
    }
    
}
