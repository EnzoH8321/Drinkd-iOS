//
//  NetworkingTestsAsMember.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 1/10/22.
//

import XCTest
@testable import drinkd_iOS
import CoreLocation
import Firebase

class NetworkingTestsAsMember: XCTestCase {
    
    var sut: drinkdViewModel!
    
    override class func setUp() {
        
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = drinkdViewModel()
        let expectation = XCTestExpectation(description: "Restaurants Fetched Successfully")
        
        createAndJoinParty {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        removeMockParty()
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
    
    func testCalculateTopThreeRestaurants() throws {
        
        let expectation = XCTestExpectation(description: "Top Three Restaurants Successfully Received")
        let firstChoice = self.sut.model.firstChoice
        let secondChoice = self.sut.model.secondChoice
        let thirdChoice = self.sut.model.thirdChoice
        
        XCTAssertNotEqual(firstChoice.name, "")
        XCTAssertNotEqual(firstChoice.score, 0)
        XCTAssertNotEqual(firstChoice.url, "")
        XCTAssertNotEqual(firstChoice.image_url, "")
        /*
         var name: String = ""
         var score: Int = 0
         var url: String = ""
         var image_url: String = ""
         
         */
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
    
    func createAndJoinParty(completionHandler: @escaping () -> Void) {
        
        sut.locationFetcher.lastKnownLocation = CLLocationCoordinate2D(latitude: 37.503731, longitude: -122.264931)
        
        let testURL = "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=37.33233141&longitude=-122.0312186&limit=10"
        
        fetchRestaurantsOnStartUp(viewModel: self.sut) { result in
            switch(result) {
                
            case .success(_):
                
//                if (self.sut == nil) {return}
                
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
                
                completionHandler()
                
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
    
    
    //TODO: Kinda hacky, fix later
    func removeMockParty() {
        
        if let friendPartyID = self.sut.model.friendPartyId {
            self.sut.model.setUserLevelToCreator()
            let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(friendPartyID)")
            localReference.removeValue()
        } else {
            print("PARTY ID -> \(self.sut.model.partyId)")
            print("FRIEND ID -> \(self.sut.model.friendPartyId)")
            print("ID -> \(self.sut.model)")
            let localReference = Database.database(url: "https://drinkd-dev-default-rtdb.firebaseio.com/").reference(withPath: "parties/\(self.sut.model.partyId!)")
            localReference.removeValue()
        }
        
        

    }
}
