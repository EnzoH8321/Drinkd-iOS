//
//  Extensions.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 8/20/25.
//

import Foundation
import SwiftUI
import CryptoKit

extension SubviewsCollection {
    // To push cards behind when its swiped and to make it appear as if its looping, we can rotate the array to achieve that
    func rotateFromLeft(by: Int) -> [SubviewsCollection.Element] {
        guard !isEmpty else { return []}
        let moveIndex = by % count
        let rotatedElements = Array(self[moveIndex...]) + Array(self[0..<moveIndex])

        // this will give the result like, if array given [1,2,3,4,5] and steps 2, the result will be [3,4,5,1,2]
        return rotatedElements
    }


}

extension [SubviewsCollection.Element] {
    func index(_ item: SubviewsCollection.Element) -> Int {
        firstIndex(where: { $0.id == item.id}) ?? 0
    }
}

extension NSString {
    /// Generates an MD5 hash of the string
    /// - Returns: The MD5 hash as a hexadecimal string (32 characters)
    func md5Hash() -> NSString {
        // Convert NSString to Swift String to access the utf8 property
        // Then convert the string to UTF-8 encoded data
        // This ensures consistent hashing regardless of string content
        let data = Data((self as String).utf8)

        // Compute the MD5 hash of the data using Apple's CryptoKit
        // Note: MD5 is cryptographically insecure and should only be used for non-security purposes
        // like cache key generation or checksums
        let hash = Insecure.MD5.hash(data: data)

        // Convert the hash bytes to a hexadecimal string representation
        // compactMap formats each byte as a 2-digit hex value (e.g., 0x0F becomes "0f")
        // joined() concatenates all hex values into a single string
        // Result is a 32-character lowercase hex string
        // Convert back to NSString for the return type
        return hash.compactMap { String(format: "%02x", $0) }.joined() as NSString
    }
}
