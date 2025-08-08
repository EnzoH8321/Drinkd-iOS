////
////  Model_Methods_Tests.swift
////  drinkd-iOSTests
////
////  Created by Enzo Herrera on 1/11/22.
////
//
//import XCTest
//@testable import drinkd_iOS
//
//class Model_Methods_Tests: XCTestCase {
//
//    var sut: drinkdModel!
//    
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//        try super.setUpWithError()
//        sut = drinkdModel()
//        
//    }
//    
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        try super.tearDownWithError()
//        sut = nil
//    }
//    
//    //Utility
//    private func addLocalRestaurants() {
//        guard let data = try? getData(fromJSON: "MockYelpBusinessSearchProperties") else {
//            XCTFail("Could not get data")
//            return
//        }
//        guard let decode = try? JSONDecoder().decode(YelpApiBusinessSearchProperties.self, from: data) else {
//            XCTFail("Could not decode")
//            return
//        }
//        
//        sut.appendDeliveryOptions(in: [decode, decode, decode, decode, decode, decode, decode, decode, decode])
//    }
//    
//    //Start
//    func test_setPersonalUserAndID() throws {
//        sut.setPersonalUserAndID(forName: "Enzo", forID: 5)
//        
//        XCTAssertEqual(sut.personalUserName, "Enzo")
//        XCTAssertEqual(sut.personalUserID, 5)
//    }
//    
//    func test_clearAllRestaurants() throws {
//        sut.clearAllRestaurants()
//        
//        XCTAssertEqual(sut.localRestaurants.count, 0)
//        XCTAssertEqual(sut.localRestaurantsDefault.count, 0)
//    }
//    
//    func test_appendDeliveryOptions() throws {
//        guard let data = try? getData(fromJSON: "MockYelpBusinessSearchProperties") else {
//            XCTFail("Could not get data")
//            return
//        }
//        guard let decode = try? JSONDecoder().decode(YelpApiBusinessSearchProperties.self, from: data) else {
//            XCTFail("Could not decode")
//            return
//        }
//        
//        sut.appendDeliveryOptions(in: [decode])
//        
//        XCTAssertEqual(sut.localRestaurants.count, 1)
//        XCTAssertEqual(sut.localRestaurantsDefault.count, 1)
//    }
//    
//    //Tests func call when there are no cards in deck
//    func test_appendDeliveryOptions_counterAtZero_counterSetToLocalRestaurantCount() throws {
//        
//        self.addLocalRestaurants()
//       
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        
//       //When called and counter is at 0, counter should equal the length of the local restaurants array - 1
//        XCTAssertEqual(sut.counter, sut.localRestaurants.count - 1)
//       
//    }
//    
//    func test_appendDeliveryOptions_counterAtZero_toggleSetToFalse() throws {
//        self.addLocalRestaurants()
//       
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        sut.appendCardsToDecklist()
//        
//        XCTAssertEqual(sut.toggleRefresh, false)
//    }
//    
//    func test_removeCardFromDeck() throws {
//        sut.removeCardFromDeck()
//        sut.removeCardFromDeck()
//        sut.removeCardFromDeck()
//        
//        XCTAssertEqual(sut.currentCardIndex, 6)
//    }
//    
//    func test_createParty() throws {
//        
//        sut.createParty(setVotes: 5, setName: "BillyParty", setURL: "www.Test.com")
//        
//        XCTAssertEqual(sut.partyMaxVotes, 5)
//        XCTAssertEqual(sut.partyURL, "www.Test.com")
//        XCTAssertEqual(sut.partyName, "BillyParty")
//        XCTAssertEqual(sut.isPartyLeader, true)
//        XCTAssertNotNil(sut.partyId)
//        XCTAssertNotNil(sut.partyTimestamp)
//        
//    }
//    
//    func test_joinParty() throws {
//        sut.setFriendsPartyId(code: "34545")
//        sut.joinParty(getVotes: 5, getURL: "www.Test.com")
//        
//        XCTAssertNotNil(sut.friendPartyId)
//        XCTAssertEqual(sut.partyMaxVotes, 5)
//        XCTAssertEqual(sut.partyURL, "www.Test.com")
//    }
//    
//    func test_setPartyId() throws {
//        sut.setPartyId()
//        
//        XCTAssertNotNil(sut.partyId)
//    }
//    
//    func test_addScoreToCard() throws {
//        
//        guard let data = try? getData(fromJSON: "MockYelpBusinessSearchProperties") else {
//            XCTFail("Could not get data")
//            return
//        }
//        guard let decode = try? JSONDecoder().decode(YelpApiBusinessSearchProperties.self, from: data) else {
//            XCTFail("Could not decode")
//            return
//        }
//        
//        sut.appendDeliveryOptions(in: [decode, decode, decode, decode, decode, decode, decode, decode, decode, decode, decode, decode])
//        
//        sut.addScoreToCard(points: 5)
//        
//        XCTAssertEqual(sut.currentScoreOfTopCard, 5)
//        XCTAssertEqual(sut.topBarList.count, 1)
//    }
//    
//    func test_appendTopThreeRestaurants() throws {
//        let testArray = [(key: "St John\'s Bar & Grill", value: drinkd_iOS.FireBaseTopChoice(id: "-gfhu2eud9pWiMP35imQRw", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/bZJiPvcYz-qVBrB8HxXKgg/o.jpg", score: 5, url: "https://www.yelp.com/biz/st-johns-bar-and-grill-sunnyvale-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "7996")), (key: "Yard House", value: drinkd_iOS.FireBaseTopChoice(id: "MRlHo4kxMHRVj5iUyvxZQA", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/vMrdF6MDik_SSoFh11VCNg/o.jpg", score: 4, url: "https://www.yelp.com/biz/yard-house-san-jose-4?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "7996")), (key: "SpiceKlub - Cupertino", value: drinkd_iOS.FireBaseTopChoice(id: "D4PT90tVAHWwIWAoXxT9Cw", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/LJveUTzCRTf37MxQocbedQ/o.jpg", score: 3, url: "https://www.yelp.com/biz/spiceklub-cupertino-cupertino-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A", key: "7996"))]
//        
//        sut.appendTopThreeRestaurants(in: testArray)
//        
//        if (testArray.count  == 1) {
//            XCTAssertEqual(sut.firstChoice.name, "St John\'s Bar & Grill")
//            XCTAssertEqual(sut.firstChoice.score, 5)
//            XCTAssertEqual(sut.firstChoice.url, "https://www.yelp.com/biz/st-johns-bar-and-grill-sunnyvale-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
//            XCTAssertEqual(sut.firstChoice.image_url, "https://s3-media2.fl.yelpcdn.com/bphoto/bZJiPvcYz-qVBrB8HxXKgg/o.jpg")
//        }
//        
//        if (testArray.count == 2) {
//            XCTAssertEqual(sut.secondChoice.name, "Yard House")
//            XCTAssertEqual(sut.secondChoice.score, 4)
//            XCTAssertEqual(sut.secondChoice.url, "https://www.yelp.com/biz/yard-house-san-jose-4?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
//            XCTAssertEqual(sut.secondChoice.image_url, "https://s3-media2.fl.yelpcdn.com/bphoto/vMrdF6MDik_SSoFh11VCNg/o.jpg")
//        }
//        
//        if (testArray.count == 3) {
//            XCTAssertEqual(sut.thirdChoice.name, "SpiceKlub - Cupertino")
//            XCTAssertEqual(sut.thirdChoice.score, 3)
//            XCTAssertEqual(sut.thirdChoice.url, "https://www.yelp.com/biz/spiceklub-cupertino-cupertino-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
//            XCTAssertEqual(sut.thirdChoice.image_url, "https://s3-media2.fl.yelpcdn.com/bphoto/LJveUTzCRTf37MxQocbedQ/o.jpg")
//        }
//        
//       
//    }
//    
//    func test_leaveParty() throws {
//        sut.leaveParty()
//        
//        XCTAssertEqual(sut.currentlyInParty, false)
//        XCTAssertEqual(sut.firstChoice.image_url, "")
//        XCTAssertEqual(sut.firstChoice.score, 0)
//        XCTAssertEqual(sut.firstChoice.url, "")
//        XCTAssertEqual(sut.firstChoice.name, "")
//    }
//    
//    func test_findDeviceType() throws {
//        sut.findDeviceType(device: .ipad)
//        
//        XCTAssertEqual(sut.isPhone, false)
//    }
//
//}
//
//
