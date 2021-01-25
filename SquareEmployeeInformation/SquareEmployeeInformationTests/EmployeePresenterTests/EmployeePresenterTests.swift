//
//  EmployeeListTests.swift
//  SquareEmployeeInformationTests
//
//  Created by Jayden Garrick on 1/24/21.
//

import XCTest
@testable import SquareEmployeeInformation

class EmployeePresenterTests: XCTestCase {
    
    // Mocks
    var mockView: MockView!
    var mockNetworkClient: NetworkMock!
    var mockImageFetchable: MockImageManager!
    var mockLogger: MockLogger!
    var mockURLHandler: MockURLHandler!
    var mockCollectionView: MockCollectionView!
    
    // System Under Test
    var sut: EmployeePresenter!
    
    // MARK: - Setup/TearDown
    override func setUp() {
        mockView = MockView()
        mockNetworkClient = NetworkMock()
        mockImageFetchable = MockImageManager()
        mockLogger = MockLogger()
        mockURLHandler = MockURLHandler()
        mockCollectionView = MockCollectionView()
        
        sut = EmployeePresenter(
            mockView,
            collectionView: mockCollectionView,
            networkManager: mockNetworkClient,
            logger: mockLogger,
            imageManager: mockImageFetchable,
            urlHandler: mockURLHandler
        )
    }
    
    override func tearDown() {
        mockView = nil
        mockNetworkClient = nil
        mockImageFetchable = nil
        mockLogger = nil
        mockURLHandler = nil
        mockCollectionView = nil
        
        sut = nil
    }
    
    // MARK: - CollectionView Helpers
    func test_employeeSelection_correctEmployee() {
        // Given
        mockNetworkClient.completeWithError = false
        mockNetworkClient.shouldCompleteWithEmptyEmployees = false
        mockNetworkClient.shouldHaveMalformedData = false
        
        // When
        sut.fetchEmployees()
        sut.didSelectItem(at: IndexPath(item: 0, section: 0))
        
        // Then
        let firstEmployee = sut.employees.first
        XCTAssertNotNil(mockNetworkClient.firstEmployee)
        XCTAssertEqual(mockView.viewModel?.employee, firstEmployee)
    }
    
    func test_emptyState_shouldShowHeader() {
        // Given
        mockNetworkClient.shouldCompleteWithEmptyEmployees = true
        
        // When
        sut.fetchEmployees()
        
        // Then
        let headerSize = sut.headerSize()
        let expectedSize = CGSize(width: mockCollectionView.frame.width, height: 300)
        XCTAssertEqual(headerSize, expectedSize)
    }
    
    func test_defaultState_shouldNotShowHeader() {
        // Given
        mockNetworkClient.shouldCompleteWithEmptyEmployees = false
        mockNetworkClient.shouldHaveMalformedData = false
        mockNetworkClient.completeWithError = false
        
        // When
        sut.fetchEmployees()
        
        // Then
        let headerSize = sut.headerSize()
        XCTAssertEqual(headerSize, .zero)
    }
    
    // MARK: - Employee Fetching
    func test_fetchSuccess_numberOfResults() {
        // Given
        mockNetworkClient.completeWithError = false
        mockNetworkClient.shouldCompleteWithEmptyEmployees = false
        mockNetworkClient.shouldHaveMalformedData = false
        
        // When
        sut.fetchEmployees()
        
        // Then
        let expectedNumberOfItems = 11
        XCTAssertEqual(sut.numberOfItemsInSection, expectedNumberOfItems)
        XCTAssertFalse(mockNetworkClient.hasDecodingError)
    }
    
    func test_fetchSuccess_reloadCalled() {
        // Given
        mockNetworkClient.completeWithError = false
        mockNetworkClient.shouldCompleteWithEmptyEmployees = false
        mockNetworkClient.shouldHaveMalformedData = false
        mockView.reloaded = false
        
        // When
        sut.fetchEmployees()
        
        // Then
        XCTAssertTrue(mockView.reloaded)
        XCTAssertFalse(mockNetworkClient.hasDecodingError)
    }
    
    func test_fetchFailed_errorLogged() {
        // Given
        mockNetworkClient.completeWithError = true
        mockNetworkClient.shouldCompleteWithEmptyEmployees = false
        
        // When
        sut.fetchEmployees()
        
        // Then
        let expectedErrorMessage = "Error Retrieving Employees: \(EmployeesNetworkError.unknownError("Forced Failure").localizedDescription)"
        XCTAssertTrue(mockLogger.eventLogged[expectedErrorMessage, default: false])
        XCTAssertTrue(mockView.errorsPresented[expectedErrorMessage, default: false])
    }
    
    func test_fetchCameBackEmpty_errorPresented() {
        // Give
        mockNetworkClient.shouldCompleteWithEmptyEmployees = true
        
        // When
        sut.fetchEmployees()
        
        // Then
        let expectedErrorMessage = "Employees came back empty..."
        XCTAssertTrue(mockView.errorsPresented[expectedErrorMessage, default: false])
        XCTAssertTrue(sut.employees.isEmpty)
    }
    
    // MARK: - ImageManager
    func test_fetchImageFailure_fallbackImageLogged() {
        // Given
        mockImageFetchable.completeWithError = true
        mockNetworkClient.completeWithError = false
        mockNetworkClient.shouldCompleteWithEmptyEmployees = false
        mockNetworkClient.shouldHaveMalformedData = false
        
        // When
        sut.fetchEmployees()
        let _ = sut.cellForRowAt(IndexPath(item: 0, section: 0))
        
        // Then
        let expectedLog = "⚠️ Unable to fetch image for \(mockNetworkClient.firstEmployee?.smallPhotoURL ?? "No Image")\nError: \(ImageError.unknownError("Forced Failure").localizedDescription)"
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: false])
    }
    
    func test_fetchImageSuccess_successLogged() {
        // Given
        mockImageFetchable.completeWithError = false
        mockNetworkClient.completeWithError = false
        mockNetworkClient.shouldCompleteWithEmptyEmployees = false
        mockNetworkClient.shouldHaveMalformedData = false
        
        // When
        sut.fetchEmployees()
        let _ = sut.cellForRowAt(IndexPath(item: 0, section: 0))
        
        // Then
        let expectedLog = "✅ Successfully fetched image at \(mockNetworkClient.firstEmployee?.smallPhotoURL ?? "")"
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: false])
    }
    
    func test_fetchImage_imageURLIsNil() {
        // Given
        mockImageFetchable.completeWithError = false
        mockNetworkClient.completeWithError = false
        mockNetworkClient.shouldCompleteWithEmptyEmployees = false
        mockNetworkClient.shouldHaveMalformedData = false

        // When
        sut.fetchEmployees()
        // Get the second employee who in the JSON has `photo_url_small" : null`
        let _ = sut.cellForRowAt(IndexPath(item: 1, section: 0))
        
        // Then
        let expectedLog = "Small image URL is null"
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: false])
    }
    
    // MARK: - URLFetcher
    
    // Calls
    func test_URLFetcher_canOpenCall() {
        // Given
        mockURLHandler.canOpen = true
        mockURLHandler.urlOpened = false
        
        // When
        sut.phoneNumberButtonTapped(with: "")
        
        // Then
        XCTAssertTrue(mockURLHandler.urlOpened)
    }
    
    
    func test_URLFetcher_callNilLogged() {
        // Given
        mockURLHandler.canOpen = true
        mockURLHandler.urlOpened = false
        
        // When
        sut.phoneNumberButtonTapped(with: nil)
        
        // Then
        let expectedLog = "No number associated with employee"
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: true])
    }
    
    func test_URLFetcher_canNotOpenCallMessagePresented() {
        // Given
        mockURLHandler.canOpen = false
        
        // When
        sut.phoneNumberButtonTapped(with: "")
        
        // Then
        let expectedMessage = "Can't make call to \("") on this device"
        XCTAssertTrue(mockView.errorsPresented[expectedMessage, default: false])
    }
    
    // Email
    func test_URLFetcher_canOpenEmail() {
        // Given
        mockURLHandler.canOpen = true
        mockURLHandler.urlOpened = false
        
        // When
        sut.emailButtonTapped(with: "")
        
        // Then
        XCTAssertTrue(mockURLHandler.urlOpened)
    }
    
    func test_URLFetcher_canNotOpenEmailMessagePresented() {
        // Given
        mockURLHandler.canOpen = false
        mockURLHandler.urlOpened = false
        
        // When
        sut.emailButtonTapped(with: "")
        
        // Then
        let expectedMessage = "Can't send email to \("") on this device"
        XCTAssertTrue(mockView.errorsPresented[expectedMessage, default: false])
    }
    
    // MARK: - URL Switcher
    func test_backendURLChanges_urlIsUpdatedToGoodEndpoint() {
        // Given
        let urlType: URLManager.URLResponseType = .good
        
        // When
        sut.resetEndpointTo(urlType)

        // Then
        let expectedURL = "https://s3.amazonaws.com/sq-mobile-interview/employees.json"
        let expectedLog = "Updating backend to be the good response"
        XCTAssertEqual(expectedURL, URLManager.shared.url)
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: false])
    }
    
    func test_backendURLChanges_urlIsUpdatedToEmptyEndpoint() {
        // Given
        let urlType: URLManager.URLResponseType = .empty
        
        // When
        sut.resetEndpointTo(urlType)

        // Then
        let expectedURL = "https://s3.amazonaws.com/sq-mobile-interview/employees_empty.json"
        let expectedLog = "Updating backend to be the empty response"
        XCTAssertEqual(expectedURL, URLManager.shared.url)
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: false])
    }

    func test_backendURLChanges_urlIsUpdatedToMalformedEndpoint() {
        // Given
        let urlType: URLManager.URLResponseType = .malformedJSON
        
        // When
        sut.resetEndpointTo(urlType)
        
        // Then
        let expectedURL = "https://s3.amazonaws.com/sq-mobile-interview/employees_malformed.json"
        let expectedLog = "Updating backend to be the malformed response"
        XCTAssertEqual(expectedURL, URLManager.shared.url)
        XCTAssertTrue(mockLogger.eventLogged[expectedLog, default: false])
    }

}
