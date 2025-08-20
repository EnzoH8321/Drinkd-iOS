//
//  Extensions.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 8/20/25.
//

import Foundation
import SwiftUI

extension SubviewsCollection {
    // To push cards behind when its swiped and to make it appear as if its looping, we can rotate the array to achieve that
    func rotateFromLeft(by: Int) -> [SubviewsCollection.Element] {
        guard !isEmpty else { return []}
        let moveIndex = by % count
        let rotatedElements = Array(self[moveIndex...]) + Array(self[0..<moveIndex])

        // this will give the result like,
        // if array given [1, 2, 3,4,5] and steps 2, the result will be [3,4,5,1,2]
        return rotatedElements
    }


}

extension [SubviewsCollection.Element] {
    func index(_ item: SubviewsCollection.Element) -> Int {
        firstIndex(where: { $0.id == item.id}) ?? 0
    }
}
