//
//  ViewModel_Methods_Tests.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 3/8/22.
//

import XCTest
@testable import drinkd_iOS

class ViewModel_Methods_Tests: XCTestCase {
    
    var sut: drinkdViewModel!
    var model: drinkdModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = drinkdViewModel()
        model = drinkdModel()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        sut = nil
        model = nil
    }
    
    private func addLocalRestaurants() {
        guard let data = try? getData(fromJSON: "MockYelpBusinessSearchProperties") else {
            XCTFail("Could not get data")
            return
        }
        guard let decode = try? JSONDecoder().decode(YelpApiBusinessSearchProperties.self, from: data) else {
            XCTFail("Could not decode")
            return
        }
        
        sut.model.appendDeliveryOptions(in: [decode, decode, decode, decode, decode, decode, decode, decode, decode])
    }
    
    //Start
    func test_updateRestaurantList() throws {
        sut.updateRestaurantList()
        sut.updateRestaurantList()
        
        XCTAssertEqual(sut.model.counter, 7)
    }
    
    func test_createNewParty() throws {
        sut.createNewParty(setVotes: 5, setName: "Enzo")
        
        XCTAssertEqual(sut.partyMaxVotes, 5)
        XCTAssertEqual(sut.partyName, "Enzo")
        XCTAssertEqual(sut.currentlyInParty, true)
    }
    //TODO: Mock the Firebase DB
    func test_joinExistingParty() throws {
        sut.JoinExistingParty(getCode: "TestingPartyCode")
        
        XCTAssertTrue(sut.queryPartyError, "Query party should show true")
    }
    
    func test_whenCardIsDraggedFromView() {
        sut.whenCardIsDraggedFromView()
        
        XCTAssertEqual(sut.currentCardIndex, 8)
    }
    
    func test_whenStarIsTapped() {
        sut.whenStarIsTapped(getPoints: 5)
        
        XCTAssertEqual(sut.currentScoreOfTopCard, 5)
        XCTAssertEqual(sut.topBarList["9"]?.score, 5)
    }
    
}
