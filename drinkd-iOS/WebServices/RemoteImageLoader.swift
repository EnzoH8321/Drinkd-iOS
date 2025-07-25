//
//  ImageLoader.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/28/21.
//

import SwiftUI

struct RemoteImageLoader: View {
	private enum LoadState {
		case loading, success, failure
	}

	private class Loader: ObservableObject {
		var data = Data()
		var state = LoadState.loading

		init(url: String) {
			guard let parsedURL = URL(string: url) else {
				return 
			}
			
			URLSession.shared.dataTask(with: parsedURL) { data, response, error in
				if let data = data, data.count > 0 {
					self.data = data
					self.state = .success
				} else {
					self.state = .failure
				}

				DispatchQueue.main.async {
					self.objectWillChange.send()
				}
			}.resume()
		}
	}

	@StateObject private var loader: Loader
    let loading: Image
	let failure: Image
    let aspectRatio: ContentMode

	var body: some View {
		selectImage()
			.resizable()
            .aspectRatio(contentMode: aspectRatio)
	}

    init(url: String, aspectRatio: ContentMode = .fit, loading: Image = Image(systemName: "photo"), failure: Image = Image(systemName: "multiply.circle")) {

        self.aspectRatio = aspectRatio
		_loader = StateObject(wrappedValue: Loader(url: url))
		self.loading = loading
		self.failure = failure
	}

	private func selectImage() -> Image {
		switch loader.state {
		case .loading:
			return loading
		case .failure:
			return failure
		default:
			if let image = UIImage(data: loader.data) {
				return Image(uiImage: image)
			} else {
				return failure
			}
		}
	}
}
