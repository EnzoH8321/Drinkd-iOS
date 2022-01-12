//
//  Networking_Methods_Tests.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 1/11/22.
//

import XCTest
@testable import drinkd_iOS
import CoreLocation

class Networking_Methods_Tests: XCTestCase {
    
    
    var sut: drinkdViewModel!
    var networking: MockNetworkingClass!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = drinkdViewModel()
        networking = MockNetworkingClass()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        sut = nil
        networking = nil
    }
    
    func test_fetchRestaurantsOnStartUp_WithValidLocation() throws {
        
        let expectation = XCTestExpectation(description:"Got Data Back Successfully")
        
        sut.locationFetcher.lastKnownLocation = CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118)
        networking.fetchRestaurantsOnStartUp(viewModel: sut) { result in
            
            switch(result) {
            case .success(_):
               
                XCTAssertTrue(self.sut.model.localRestaurants.count > 0)
                XCTAssertTrue(self.sut.model.localRestaurantsDefault.count > 0)
//                XCTAssertNotNil(self.sut.partyURL)
                XCTAssertEqual(self.sut.removeSplashScreen, true)
                XCTAssertEqual(self.sut.userDeniedLocationServices, false)
                
                expectation.fulfill()
            case .failure(let failure):
                switch(failure) {
                    
                case .serializationError:
                    XCTFail("SERIALIZATION ERROR")
                case .decodingError:
                    XCTFail("DECODING ERROR")
                case .noUserLocationFoundError:
                    XCTFail("NO USER LOCATION FOUND ERROR")
                case .invalidURLError:
                    XCTFail("INVALID URL ERROR")
                case .noURLFoundError:
                    XCTFail("NO URL FOUND ERROR")
                case .generalNetworkError:
                    XCTFail("GENERAL NETWORK ERROR")
                case .databaseRefNotFoundError:
                    XCTFail("DATABASE REF NOT FOUND ERROR")
                }
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchUsingCustomLocation_WithValidLocation() throws {
        
        let expectation = XCTestExpectation(description:"Got Data Back Successfully")
        
        networking.fetchUsingCustomLocation(viewModel: sut, longitude: 37.33182 , latitude: -122.03118) { result in
            
            switch(result) {
            case .success(_):
               
               
            expectation.fulfill()
                
            case .failure(let failure):
                switch(failure) {
                
                case .serializationError:
                    XCTFail("SERIALIZATION ERROR")
                case .decodingError:
                    XCTFail("DECODING ERROR")
                case .noUserLocationFoundError:
                    XCTFail("NO USER LOCATION FOUND ERROR")
                case .invalidURLError:
                    XCTFail("INVALID URL ERROR")
                case .noURLFoundError:
                    XCTFail("NO URL FOUND ERROR")
                case .generalNetworkError:
                    XCTFail("GENERAL NETWORK ERROR")
                case .databaseRefNotFoundError:
                    XCTFail("DATABASE REF NOT FOUND ERROR")
                }
            }
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
}
