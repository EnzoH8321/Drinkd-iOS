//
//  StackableCardView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 8/20/25.
//

import SwiftUI
// Allows you to stack views & adds animations
struct StackableWrapper<Content: View>: View {
    @Environment(PartyViewModel.self) var viewModel

    var index: Int
    var count: Int
    var visibleCardsCount: Int
    @Binding var rotation: Int
    @ViewBuilder var content: Content
    // Interaction Properties
    @State private var offset: CGFloat = .zero
    // Useful to calculate the end result when dragging is finished (to push into the next card)
    @State private var viewSize: CGSize = .zero
    var body: some View {

        // Visible cards offset and scaling
        // Customize to suit requirements
        let extraOffset =  min(CGFloat(index) * 20, CGFloat(visibleCardsCount) * 20 )
        let scale = 1 - min(CGFloat(index) * 0.07, CGFloat(visibleCardsCount) * 0.07 )

        // now 3d rotation when swiping the card
        let rotationDegree: CGFloat = -30
        let rotation = max(min(-offset / viewSize.width, 1), 0) * rotationDegree

        content
            .onGeometryChange(for: CGSize.self, of: { proxy in
                proxy.size
            }, action: {
                viewSize = $0
            })
            .offset(x: extraOffset)
            .scaleEffect(scale, anchor: .trailing)
        // animate index effects
            .animation(.smooth(duration: 0.25, extraBounce: 0), value: index)
            .offset(x: offset)
            .rotation3DEffect(.init(degrees: rotation), axis: (0, 1, 0), anchor: .center, perspective: 0.5)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        // Only allows left side interaction
                        // -value.translation.width - Negates the drag distance.
                        // Takes the larger of the negated drag or zero:
                        let xOffset = -max(-value.translation.width, 0)
                        offset = xOffset
                    }).onEnded({ value in

                        viewModel.currentScoreOfTopCard = 0
                        let xVelocity = max(-value.velocity.width / 5 , 0)
                        /*
                         Slow drag: Must drag past 65% of screen to trigger
                         Fast left swipe: Can trigger even with shorter distance (velocity helps)
                         Right swipe or slow left: Card snaps back to center
                         */
                        if (-offset + xVelocity) > (viewSize.width * 0.65) {
                            pushToNextCard()
                        } else {
                            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                                offset = .zero
                            }
                        }


                    }),
                // Only activate gesture for the top most card
                isEnabled: index == 0 && count > 1
            )
    }

    private func pushToNextCard() {
        // first we need to move the card with the value of its view width so that the z index effect wont be visible and appears as if its receding behind
        withAnimation(.smooth(duration: 0.25, extraBounce: 0).logicallyComplete(after: 0.15), completionCriteria: .logicallyComplete) {
            offset = -viewSize.width
        } completion: {
            // once the card has been moved, we can update its zindex and reset its offset value
            rotation += 1
            withAnimation(.smooth(duration: 0.25, extraBounce: 0)) {
                offset = .zero
            }
        }
    }
}

//#Preview {
//    StackableCardView()
//}
