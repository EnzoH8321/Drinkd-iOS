//
//  FirebaseTopChoices.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 10/7/21.
//

import SwiftUI

struct ThreeTopChoices {
	var first: FirebaseRestaurantInfo?
	var second: FirebaseRestaurantInfo?
	var third: FirebaseRestaurantInfo?
}

struct FirebaseRestaurantInfo: Equatable, Comparable {
	static func < (lhs: FirebaseRestaurantInfo, rhs: FirebaseRestaurantInfo) -> Bool {
		if (lhs.score == rhs.score) {
			return	lhs.name > rhs.name
		} else {
			return	lhs.score > rhs.score
		}
	}

	var name: String = ""
	var score: Int = 0
	var url: String = ""
	var image_url: String = ""
}

struct FireBaseMaster: Codable {
	var models: [String: FireBaseTopChoicesArray]

	private struct RestaurantNameKey : CodingKey {
		var stringValue: String
		init?(stringValue: String) {
			self.stringValue = stringValue
		}
		//We know value will not be an int so†an just return safely
		var intValue: Int?
		init?(intValue: Int) { return nil }
	}
	//  Decode
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: RestaurantNameKey.self)

		var models: [String: FireBaseTopChoicesArray] = [:]
		for key in container.allKeys {
			if let key = RestaurantNameKey(stringValue: key.stringValue) {
				let model = try container.decode(FireBaseTopChoicesArray.self, forKey: key)
				models[key.stringValue] = model
			}
		}
		self.models = models
	}
}



struct FireBaseTopChoice: Codable {
	let id: String
	let image_url: String
	var score: Int
	let url: String
	let key: String

	private enum CodingKeys: CodingKey {
		case id
		case image_url
		case score
		case url
	}
	//init
	init(id: String, image_url: String, score: Int, url: String, key: String) {
		self.id = id
		self.image_url = image_url
		self.score = score
		self.url = url
		self.key = key
	}
	//decode
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		guard let key = container.codingPath.first?.stringValue else {
			throw NSError(domain: "Key not found", code: 0, userInfo: nil)
		}

		self.id = try container.decode(String.self, forKey: .id)
		self.image_url = try container.decode(String.self, forKey: .image_url)
		self.score = try container.decode(Int.self, forKey: .score)
		self.url = try container.decode(String.self, forKey: .url)
		self.key = key
	}
}

struct FireBaseTopChoicesArray: Codable {
	var models = [String: FireBaseTopChoice]()

	private struct RestaurantNameKey : CodingKey {
		var stringValue: String
		init?(stringValue: String) {
			self.stringValue = stringValue
		}
		//We know value will not be an int so we can just return safely
		var intValue: Int?
		init?(intValue: Int) { return nil }
	}

	//  Init
	init(_ models: [String: FireBaseTopChoice]) {
		self.models = models
	}


	//  Decode
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: RestaurantNameKey.self)

		var models: [String: FireBaseTopChoice] = [:]
		for key in container.allKeys {
			if let key = RestaurantNameKey(stringValue: key.stringValue) {
				let model = try container.decode(FireBaseTopChoice.self, forKey: key)
				models[key.stringValue] = model
			}
		}
		self.models = models
	}
}


struct FireBaseMessageArray: Codable {
	var messages: [FireBaseMessage]
}

struct FireBaseMessage: Codable, Identifiable {
	var id: String
	var username: String
	var personalId: Int
	var message: String
	var timestamp: Int
	var timestampString: String
}


