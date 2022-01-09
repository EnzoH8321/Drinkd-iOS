//
//  NetworkingTests.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 1/8/22.
//

import XCTest
@testable import drinkd_iOS
import CoreLocation

class NetworkingTests: XCTestCase {
    
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

   /*
    1. Must fill local restaurant + localrestaurants default array
    2. Must have id, maxvotes,timestamp, name, partyURL to non nil
    3. removesplashscreen must be true
    4. userdeniedlocationservices is false
    5. userlevel should be creator
    */
    func testInitialFetchWorks() throws {
        
        let dataModel = self.sut.model
     
        let userLevelCreator = XCTestExpectation(description: "User level is Creator")
        //Set Temp Location
        sut?.locationFetcher.lastKnownLocation = CLLocationCoordinate2D(latitude: 37.503731, longitude: -122.264931)
        
        fetchRestaurantsOnStartUp(viewModel: sut!) { result in
            
            switch(result) {
            case .success(_):
                XCTAssertTrue(!dataModel.localRestaurants.isEmpty)
                XCTAssertTrue(!dataModel.localRestaurantsDefault.isEmpty)
                XCTAssertTrue(dataModel.partyId != nil)
                XCTAssertTrue(dataModel.partyMaxVotes != nil)
                XCTAssertTrue(dataModel.partyTimestamp != nil)
                XCTAssertTrue(dataModel.partyURL != nil)
                XCTAssertTrue(dataModel.partyName != nil)
                XCTAssertTrue(self.sut.removeSplashScreen)
                XCTAssertTrue(!self.sut.userDeniedLocationServices)
                XCTAssert(<#T##expression: Bool##Bool#>)
                
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
        
        
        
        
    }
    
    
    
}
