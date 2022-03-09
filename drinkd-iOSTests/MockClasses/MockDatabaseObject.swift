//
//  MockDatabaseObject.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 1/12/22.
//

import Foundation


class MockDatabaseObject {
    var party = PartyHead(fakeNumber: PartyMain())
}

struct PartyHead: Codable {
    var fakeNumber: PartyMain
    
    enum CodingKeys: String, CodingKey {
        case fakeNumber = "11393"
    }
}

struct PartyMain: Codable {
    var partyID = "11393"
    var partyMaxVotes = 3
    var partyName = "Enzo Party"
    var partyTimeStamp = 1642015779029
    var partyURL = "https://api.yelp.com/v3/businesses/search?categories=bars&latitude=37.33233141&longitude=-122.0312186&limit=10"
    var topBars = TopBarsHead(fakeNumber: TopBarsMain())
}

struct TopBarsHead: Codable {
    var fakeNumber: TopBarsMain
    
    enum CodingKeys: String, CodingKey {
        case fakeNumber = "11393"
    }
}

struct TopBarsMain: Codable {
    var firstBar = Bar(id: "D4PT90tVAHWwIWAoXxT9Cw", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/LJveUTzCRTf37MxQocbedQ/o.jpg", score: 2, url: "https://www.yelp.com/biz/spiceklub-cupertino-cupertino-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
    
    var secondBar = Bar(id: "-gfhu2eud9pWiMP35imQRw", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/bZJiPvcYz-qVBrB8HxXKgg/o.jpg", score: 3, url: "https://www.yelp.com/biz/st-johns-bar-and-grill-sunnyvale-2?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
    
    var thirdBar = Bar(id: "MRlHo4kxMHRVj5iUyvxZQA", image_url: "https://s3-media2.fl.yelpcdn.com/bphoto/vMrdF6MDik_SSoFh11VCNg/o.jpg", score: 4, url: "https://www.yelp.com/biz/yard-house-san-jose-4?adjust_creative=X6-vs_4_PMvNnrncoQ9t9A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=X6-vs_4_PMvNnrncoQ9t9A")
}


struct Bar: Codable {
    var id: String
    var image_url: String
    var score: Int
    var url: String
}
