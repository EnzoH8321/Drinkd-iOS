//
//  TopChoicesView.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/23/21.
//

import SwiftUI

struct TopChoicesView: View {
	var body: some View {
		GeometryReader { proxy in

			let globalHeight = proxy.frame(in: .global).height
			let globalWidth = proxy.frame(in: .global).width

			VStack(alignment: .center) {
				Group {
					ListCardView()
					ListCardView()
					ListCardView()
				}
				.frame(width: globalWidth - 20, height: globalHeight / 4)
			}
			.frame(width: globalWidth, height: globalHeight)

		}

	}
}

struct TopChoicesView_Previews: PreviewProvider {
	static var previews: some View {
		TopChoicesView()
	}
}
