////
////  Networking_Methods_Tests.swift
////  drinkd-iOSTests
////
////  Created by Enzo Herrera on 1/11/22.
////
//
//import XCTest
//@testable import drinkd_iOS
//import CoreLocation
//
//class Networking_Methods_Tests: XCTestCase {
//    
//    
//    var sut: PartyViewModel!
//    var networking: MockNetworkingClass!
//    
//    
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//        try super.setUpWithError()
//        sut = PartyViewModel()
//        networking = MockNetworkingClass()
//        
//    }
//    
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        try super.tearDownWithError()
//        sut = nil
//        networking = nil
//        
//    }
//    
//    func test_fetchRestaurantsOnStartUp_WithValidLocation() throws {
//        
//        let expectation = XCTestExpectation(description:"Got Data Back Successfully")
//        
//        sut.locationFetcher.lastKnownLocation = CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118)
//        networking.fetchRestaurantsOnStartUp(viewModel: sut) { result in
//            
//            switch(result) {
//            case .success(_):
//                
//                
//                
//                expectation.fulfill()
//            case .failure(let failure):
//                switch(failure) {
//                    
//                case .serializationError:
//                    XCTFail("SERIALIZATION ERROR")
//                case .decodingError:
//                    XCTFail("DECODING ERROR")
//                case .noUserLocationFoundError:
//                    XCTFail("NO USER LOCATION FOUND ERROR")
//                case .invalidURLError:
//                    XCTFail("INVALID URL ERROR")
//                case .noURLFoundError:
//                    XCTFail("NO URL FOUND ERROR")
//                case .generalNetworkError:
//                    XCTFail("GENERAL NETWORK ERROR")
//                case .databaseRefNotFoundError:
//                    XCTFail("DATABASE REF NOT FOUND ERROR")
//                }
//            }
//        }
//        
//        wait(for: [expectation], timeout: 1)
//        XCTAssertTrue(self.sut.model.localRestaurants.count > 0)
//        XCTAssertTrue(self.sut.model.localRestaurantsDefault.count > 0)
//                        XCTAssertNotNil(self.sut.partyURL)
//        XCTAssertEqual(self.sut.removeSplashScreen, true)
//        XCTAssertEqual(self.sut.userDeniedLocationServices, false)
//    }
//    
//    func test_fetchUsingCustomLocation_WithValidLocation() throws {
//        
//        let expectation = XCTestExpectation(description:"Got Data Back Successfully")
//        
//        networking.fetchUsingCustomLocation(viewModel: sut, longitude: -122.03118 , latitude: 37.33182) { result in
//            
//            switch(result) {
//            case .success(_):
//                expectation.fulfill()
//                
//            case .failure(let failure):
//                switch(failure) {
//                    
//                case .serializationError:
//                    XCTFail("SERIALIZATION ERROR")
//                case .decodingError:
//                    XCTFail("DECODING ERROR")
//                case .noUserLocationFoundError:
//                    XCTFail("NO USER LOCATION FOUND ERROR")
//                case .invalidURLError:
//                    XCTFail("INVALID URL ERROR")
//                case .noURLFoundError:
//                    XCTFail("NO URL FOUND ERROR")
//                case .generalNetworkError:
//                    XCTFail("GENERAL NETWORK ERROR")
//                case .databaseRefNotFoundError:
//                    XCTFail("DATABASE REF NOT FOUND ERROR")
//                }
//            }
//        }
//        
//        wait(for: [expectation], timeout: 2)
//        XCTAssertTrue(self.sut.model.localRestaurants.count > 0)
//        XCTAssertTrue(self.sut.model.localRestaurantsDefault.count > 0)
//        XCTAssertNotNil(self.sut.partyURL)
//        XCTAssertTrue(self.sut.removeSplashScreen == true)
//        XCTAssertTrue(self.sut.userDeniedLocationServices == false)
//    }
//    
//    func test_fetchRestaurantsAfterJoiningParty() throws {
//        
//        let expectation = XCTestExpectation(description:"Got Data Back Successfully")
//        
//        sut.locationFetcher.lastKnownLocation = CLLocationCoordinate2D(latitude: 37.33182, longitude: -122.03118)
//        
//        self.sut.model.setPartyURL(toURL: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=37.33182&longitude=-122.03118&limit=10")
//        
//        networking.fetchRestaurantsAfterJoiningParty(viewModel: sut) { result in
//            switch(result) {
//                
//            case .success(_):
//                
//                expectation.fulfill()
//                
//            case .failure(let failure):
//                switch(failure) {
//                    
//                case .serializationError:
//                    XCTFail("SERIALIZATION ERROR")
//                case .decodingError:
//                    XCTFail("DECODING ERROR")
//                case .noUserLocationFoundError:
//                    XCTFail("NO USER LOCATION FOUND ERROR")
//                case .invalidURLError:
//                    XCTFail("INVALID URL ERROR")
//                case .noURLFoundError:
//                    XCTFail("NO URL FOUND ERROR")
//                case .generalNetworkError:
//                    XCTFail("GENERAL NETWORK ERROR")
//                case .databaseRefNotFoundError:
//                    XCTFail("DATABASE REF NOT FOUND ERROR")
//                }
//            }
//        }
//        wait(for: [expectation], timeout: 3)
//        XCTAssertTrue(self.sut.model.localRestaurants.count > 0)
//        XCTAssertTrue(self.sut.model.localRestaurantsDefault.count > 0)
//    }
//    
//    func test_calculateTopThreeRestaurants_withValidData() throws {
//        
//        let expectation = XCTestExpectation(description:"Top Three Restaurants received successfully")
//        
//        self.sut.model.createParty(setVotes: 5, setName: "enzo", setURL: "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=37.33182&longitude=-122.03118&limit=10")
//        
//
//        networking.calculateTopThreeRestaurants(viewModel: sut) { result in
//            
//            switch(result) {
//                
//            case .success(_):
//                
//                expectation.fulfill()
//                
//            case .failure(let failure):
//                switch(failure) {
//                    
//                case .serializationError:
//                    XCTFail("SERIALIZATION ERROR")
//                case .decodingError:
//                    XCTFail("DECODING ERROR")
//                case .noUserLocationFoundError:
//                    XCTFail("NO USER LOCATION FOUND ERROR")
//                case .invalidURLError:
//                    XCTFail("INVALID URL ERROR")
//                case .noURLFoundError:
//                    XCTFail("NO URL FOUND ERROR")
//                case .generalNetworkError:
//                    XCTFail("GENERAL NETWORK ERROR")
//                case .databaseRefNotFoundError:
//                    XCTFail("DATABASE REF NOT FOUND ERROR")
//                }
//            }
//            
//        }
//        
//        wait(for: [expectation], timeout: 1)
//        XCTAssertEqual(self.sut.model.firstChoice.name, "Yard House")
//        XCTAssertEqual(self.sut.model.firstChoice.score, 4)
//        XCTAssertEqual(self.sut.model.firstChoice.image_url, "https://s3-media2.fl.yelpcdn.com/bphoto/vMrdF6MDik_SSoFh11VCNg/o.jpg")
//        XCTAssertEqual(self.sut.model.firstChoice.url, "https://www.yelp.com/biz/yard-house-san-jose-4?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
//        
//        XCTAssertEqual(self.sut.model.secondChoice.name, "St John's Bar & Grill")
//        XCTAssertEqual(self.sut.model.secondChoice.score, 3)
//        XCTAssertEqual(self.sut.model.secondChoice.image_url, "https://s3-media2.fl.yelpcdn.com/bphoto/bZJiPvcYz-qVBrB8HxXKgg/o.jpg")
//        XCTAssertEqual(self.sut.model.secondChoice.url, "https://www.yelp.com/biz/st-johns-bar-and-grill-sunnyvale-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
//        
//        XCTAssertEqual(self.sut.model.thirdChoice.name, "SpiceKlub - Cupertino")
//        XCTAssertEqual(self.sut.model.thirdChoice.score, 2)
//        XCTAssertEqual(self.sut.model.thirdChoice.image_url,  "https://s3-media2.fl.yelpcdn.com/bphoto/LJveUTzCRTf37MxQocbedQ/o.jpg")
//        XCTAssertEqual(self.sut.model.thirdChoice.url, "https://www.yelp.com/biz/spiceklub-cupertino-cupertino-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
//    }
//    
//    func test_submitRestaurant_WithValidData() throws {
//        let firstTopBar = networking.mockDB.party.fakeNumber.topBars.fakeNumber.firstBar
//        networking.submitRestaurantScore(viewModel: sut)
//        
//        //Based on the TopBarsMain firstbar property in the MockDatabaseObject
//        XCTAssertEqual(firstTopBar.score, 2)
//        XCTAssertEqual(firstTopBar.url, "https://www.yelp.com/biz/spiceklub-cupertino-cupertino-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
//        XCTAssertEqual(firstTopBar.image_url, "https://s3-media2.fl.yelpcdn.com/bphoto/LJveUTzCRTf37MxQocbedQ/o.jpg")
//        XCTAssertEqual(firstTopBar.id, "D4PT90tVAHWwIWAoXxT9Cw")
//    }
//}
