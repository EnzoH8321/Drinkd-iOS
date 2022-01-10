//
//  NetworkingTestsPreParty.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 1/10/22.
//

import XCTest
@testable import drinkd_iOS
import CoreLocation

class NetworkingTestsPreParty: XCTestCase {
    
    var sut: drinkdViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = drinkdViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        sut = nil
    }

    func testInitialFetchWorksWithValidData() throws {
        
        let expectation = XCTestExpectation(description: "Data Received Successfully")
        
        //Set Temp Location
        sut.locationFetcher.lastKnownLocation = CLLocationCoordinate2D(latitude: 37.503731, longitude: -122.264931)
        
        fetchRestaurantsOnStartUp(viewModel: self.sut) { result in
            
            switch(result) {
                
            case .success(_):
                
                expectation.fulfill()
                
            case .failure(let failure):
                switch(failure) {
                case .databaseRefNotFoundError:
                    XCTFail("DB REF NOT FOUND")
                case .serializationError:
                    XCTFail("SERIALIZATION ERROR")
                case .decodingError:
                    XCTFail("DECODING ERROR")
                case .noUserLocationFoundError:
                    XCTFail("NO USER LOCATION ERROR")
                case .invalidURLError:
                    XCTFail("INVALID URL ERROR")
                case .noURLFoundError:
                    XCTFail("NO URL FOUND ERROR")
                case .generalNetworkError:
                    XCTFail("GENERAL NETWORK ERROR")
                }
            }
            
        }
        wait(for: [expectation], timeout: 3)
        XCTAssertTrue(self.sut.model.localRestaurants.count > 0)
        XCTAssertTrue(self.sut.model.localRestaurantsDefault.count > 0)
        XCTAssertTrue(self.sut.model.partyURL != nil)
        XCTAssertTrue(self.sut.removeSplashScreen)
        XCTAssertTrue(!self.sut.userDeniedLocationServices)
        XCTAssertTrue(self.sut.isPartyLeader == false)
    }
    
    func testCustomLocationWorksWithValidData() throws {
        
        if (self.sut.model.currentlyInParty) {
            throw XCTSkip("Requires User to Not Be in A Party")
        }
        
        let expectation = XCTestExpectation(description: "Data Received Successfully")
        
        //Set Temp Location
        let latitude = 37.503731
        let longitude = -122.264931
        
        fetchUsingCustomLocation(viewModel: self.sut, longitude: longitude, latitude: latitude) { result in
            
            switch(result) {
                
            case .success(_):
                
                expectation.fulfill()
                
            case .failure(let failure):
                switch(failure) {
                case .databaseRefNotFoundError:
                    XCTFail("DB REF NOT FOUND")
                case .serializationError:
                    XCTFail("SERIALIZATION ERROR")
                case .decodingError:
                    XCTFail("DECODING ERROR")
                case .noUserLocationFoundError:
                    XCTFail("NO USER LOCATION ERROR")
                case .invalidURLError:
                    XCTFail("INVALID URL ERROR")
                case .noURLFoundError:
                    XCTFail("NO URL FOUND ERROR")
                case .generalNetworkError:
                    XCTFail("GENERAL NETWORK ERROR")
                }
            }
            
        }
        wait(for: [expectation], timeout: 3)
        XCTAssertTrue(self.sut.model.localRestaurants.count > 0)
        XCTAssertTrue(self.sut.model.localRestaurantsDefault.count > 0)
        XCTAssertTrue(self.sut.model.partyURL != nil)
        XCTAssertTrue(self.sut.removeSplashScreen)
        XCTAssertTrue(!self.sut.userDeniedLocationServices)
        XCTAssertTrue(self.sut.isPartyLeader == false)
    }

}
