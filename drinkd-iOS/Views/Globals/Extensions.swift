//
//  Extensions.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 12/22/21.
//

import Foundation
import SwiftUI

extension Text {
    func addBottomPadding() -> some View {
        return self.padding(16).fixedSize(horizontal: false, vertical: true)
    }
}
