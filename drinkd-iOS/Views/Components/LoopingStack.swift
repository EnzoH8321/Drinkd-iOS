//
//  LoopingStack.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 8/20/25.
//

import SwiftUI

//struct LoopingStack<Content: View>: View {
//    var visibleCardsCount: Int = 2
//    @ViewBuilder var content: Content
//    // View properties
//    @State private var rotation: Int = 0
//    var body: some View {
//        /// Starting with iOS 18 we can extract subview collection from a view content with the help of Group
//        Group(subviews: content) { collection in
//            let collection = collection.rotateFromLeft(by: rotation)
//            let count = collection.count
//
//            ZStack {
//                ForEach(collection) { view in
//                    // lets reverse the stack with zindex
//                    let index = collection.index(view)
//                    let zIndex = Double(count - index)
//
//                    StackableWrapper(index: index, count: count, visibleCardsCount: visibleCardsCount, rotation: $rotation) {
//                        view
//                    }
//                    .zIndex(zIndex)
//
//                }
//            }
//        }
//    }
//}

//#Preview {
//    LoopingStack()
//}
