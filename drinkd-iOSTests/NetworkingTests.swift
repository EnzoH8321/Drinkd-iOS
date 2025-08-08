//
//  NetworkingTests.swift
//  drinkd-iOSTests
//
//  Created by Enzo Herrera on 8/8/25.
//

import Testing
import drinkd_iOS

@Suite("Networking Tests")
struct NetworkingTests {

    var partyVM: PartyViewModel

    init() {
        
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
