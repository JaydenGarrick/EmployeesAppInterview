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
        var reloaded: Bool = false
        
        func reload() {
            reloaded = true
        }
    }
    
    // MARK: - MockNavigator
    class MockNavigator: EmployeeInformationNavigator {
        var viewModel: EmployeeDetailViewModel? = nil
        var errorsPresented: [String: Bool] = [:]
        
        func goToDetailViewWith(_ viewModel: EmployeeDetailViewModel) {
            self.viewModel = viewModel
        }
        
        func presentError(_ message: String) {
            errorsPresented[message] = true
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
    
    // MARK: - MockLogger
    class MockLogger: Loggable {
        var eventLogged: [String: Bool] = [:]
        
        func logEvent(_ event: String) {
            eventLogged[event] = true
        }
    }
    
    // MARK: - MockURLHandler
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
    
    // MARK: - MockCollectionView
    class MockCollectionView: Dequeuable {
        var frame: CGRect
        var shouldReturnGenericCell: Bool = false
        
        init(_ frame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)) {
            self.frame = frame
        }
        
        func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
            return shouldReturnGenericCell ?
                UICollectionViewCell() :
                EmployeeCollectionViewCell.instanceFromNib()
        }
        
        func dequeueReusableSupplementaryView(ofKind elementKind: String, withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionReusableView {
            return UICollectionReusableView()
        }
        
        func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
            return EmployeeCollectionViewCell.instanceFromNib()
        }
        
    }
    
}

// Helper method
extension EmployeeCollectionViewCell {
    // Stuff like this is why I typically prefer doing programatic UI 🤪
    static func instanceFromNib() -> UICollectionViewCell {
        return UINib(nibName: "EmployeeCollectionViewCell", bundle: Bundle(for: EmployeeCollectionViewCell.self)).instantiate(withOwner: nil, options: nil).first as? EmployeeCollectionViewCell ?? UICollectionViewCell()
    }
}
