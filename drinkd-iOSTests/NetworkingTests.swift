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
//        createMockParty()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
//        removeMockParty()
        sut = nil
    }
    
    func createMockParty() {
        
        sut.locationFetcher.lastKnownLocation = CLLocationCoordinate2D(latitude: 37.503731, longitude: -122.264931)
        
        let testURL = "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=37.33233141&longitude=-122.0312186&limit=10"
                
        fetchRestaurantsOnStartUp(viewModel: self.sut) { result in
            switch(result) {
                
            case .success(_):
                
                if (self.sut == nil) {return}
                
                self.sut.model.createParty(setVotes: 5, setName: "Enzo", setURL: testURL)

                //Drags Card
                self.sut.updateRestaurantList()
                self.sut.whenCardIsDraggedFromView()
                self.sut.setCurrentTopCardScoreToZero()
                self.sut.emptyTopBarList()
                self.sut.model.removeCardFromDeck()
                //Tapped Star
                self.sut.whenStarIsTapped(getPoints: 3)
                //Tap Submit Button
                self.sut.model.addScoreToCard(points: 3)
                
                submitRestaurantScore(viewModel: self.sut)
                
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
    
    func removeMockParty() {
        leaveParty(viewModel: sut)
    }
    
    /*
     1. Must fill local restaurant + localrestaurants default array
     2. Must have id, maxvotes,timestamp, name, partyURL to non nil
     3. removesplashscreen must be true
     4. userdeniedlocationservices is false
     5. userlevel should be creator
     */
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
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(self.sut.model.localRestaurants.count > 0)
        XCTAssertTrue(self.sut.model.localRestaurantsDefault.count > 0)
        XCTAssertTrue(self.sut.model.partyURL != nil)
        XCTAssertTrue(self.sut.removeSplashScreen)
        XCTAssertTrue(!self.sut.userDeniedLocationServices)
        XCTAssertTrue(self.sut.isPartyLeader == false)
        
        
    }
    
    func testCustomLocationWorksWithValidData() throws {
        
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
    
    func testFetchRestaurantsWorksWithValidData() throws {
        let expectation = XCTestExpectation(description: "Restaurants Fetched Successfully")
        
        let testURL = "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=37.33233141&longitude=-122.0312186&limit=10"
        
        sut.model.createParty(setVotes: 5, setName: "Enzo", setURL: testURL)
        
        fetchRestaurantsAfterJoiningParty(viewModel: self.sut) { result in
            
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
        
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(self.sut.model.localRestaurants.count > 0)
        XCTAssertTrue(self.sut.model.localRestaurantsDefault.count > 0)
    }
    
    //    func testCalculateTopThreeRestaurantsWithValidData() throws {
    //
    //        let expectation = XCTestExpectation(description: "Top Three Restaurants Fetched Successfully")
    //
    //
    //
    //        sut.model.createParty(setVotes: 5, setName: "Enzo", setURL: testURL)
    //
    //    }
    
    
}

