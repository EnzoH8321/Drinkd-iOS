//
//  NetworkingTestsAsMember.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 1/10/22.
//

import XCTest
@testable import drinkd_iOS
import CoreLocation

class NetworkingTestsAsMember: XCTestCase {
    
    var sut: drinkdViewModel!
    
    override class func setUp() {
        
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = drinkdViewModel()
        createAndJoinParty()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        sut = nil
    }
    
    func testFetchingRestaurantsAfterJoiningParty() throws {
        let expectation = XCTestExpectation(description: "Restaurants Fetched Successfully")
        

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
    
    
}

extension NetworkingTestsAsMember {
    
    func mockJoinParty() {
        let creatorPartyCode = self.sut.model.partyId!
        
        self.sut.JoinExistingParty(getCode: creatorPartyCode)
        self.sut.forModelSetUsernameAndId(username: "Enzo", id: 345345344)
        fetchRestaurantsAfterJoiningParty(viewModel: sut) { result in
            
            switch(result) {
                
            case .success(_):
                
                if (self.sut == nil) {return}
                print("PARTY URL FINAL -> \(self.sut.model.partyURL)")
                
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
    
    func createAndJoinParty() {
        
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
                
                self.mockJoinParty()
                
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
}
