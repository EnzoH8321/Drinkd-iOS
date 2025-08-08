//
//  NetworkingTests.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 8/8/25.
//

import Testing
@testable import drinkd_iOS

@Suite("Networking Tests")
class NetworkingTests {

    var partyVM: PartyViewModel

    init() {
        self.partyVM = PartyViewModel()
    }

    deinit {

    }

    //    @Test func <#test function name#>() async throws {
    //        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    //    }


    private func setupVM() {
        let partyVM = PartyViewModel()
        self.partyVM = partyVM
    }

    private func teadDownVM() {
        self.partyVM = PartyViewModel()
    }

}
