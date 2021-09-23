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

			List {
				Group {
					ListCardView()
					ListCardView()
					ListCardView()
				}
				.frame(height: globalHeight / 4)
			}
		}
	}
}

struct TopChoicesView_Previews: PreviewProvider {
	static var previews: some View {
		TopChoicesView()
	}
}
