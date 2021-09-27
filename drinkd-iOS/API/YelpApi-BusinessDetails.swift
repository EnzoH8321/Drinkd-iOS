//
//  YelpApi-BusinessDetails.swift
//  drinkd-iOS
//
//  Created by Enzo Herrera on 9/22/21.
//

import SwiftUI

//Main Query
struct YelpApiBusinessSearch: Codable {
	let business: [YelpApiBusinessSearchProperties]
}

//Business Search
struct YelpApiBusinessSearchProperties: Codable {
	let id: String
	let alias: String
	let name: String
	let image_url: String
	let is_closed: Bool
	let url: String
	let review_count: Int
	let categories: [YelpApiBusinessDetails_Categories]
	let rating: Double
	let coordinates: YelpApiBusinessDetails_Coordinates
	let transactions: [String]
	let price: String
	let location: YelpApiBusinessDetails_Location
	let phone: String
	let display_phone: String
	let distance: Double
}


//Business Details
struct YelpApiBusinessDetails: Codable {
	let id: String
	let alias: String
	let name: String
	let image_url: String
	let is_claimed: Bool
	let is_closed: Bool
	let url: String
	let phone: String
	let display_phone: String
	let review_count: Int
	let categories: [YelpApiBusinessDetails_Categories]
	let rating: Double
	let location: YelpApiBusinessDetails_Location
	let coordinates: YelpApiBusinessDetails_Coordinates
	let photos: [String]
	let price: String
	let hours: [YelpApiBusinessDetails_Hours]
	let transactions: [String]
	let special_hours: [YelpApiBusinessDetails_SpecialHours]
}

struct YelpApiBusinessDetails_Categories: Codable {
	let alias: String
	let title: String
}

struct YelpApiBusinessDetails_Location: Codable {
	let address1: String
	let address2: String
	let address3: String
	let city: String
	let zip_code: String
	let country: String
	let state: String
	let display_address: [String]
	let cross_streets: String
}

struct YelpApiBusinessDetails_Coordinates: Codable {
	let latitude: Double
	let longitude: Double
}

struct YelpApiBusinessDetails_Hours: Codable {
	let open: [YelpApiBusinessDetails_Hours_Open]
	let hours_type: String
	let is_open_now: Bool
}

struct YelpApiBusinessDetails_Hours_Open: Codable {
	let is_overnight: Bool
	let start: String
	let end: String
	let day: Int
}

struct YelpApiBusinessDetails_SpecialHours: Codable {
	let date: String
	let is_closed: Bool?
	let start: String
	let end: String
	let is_overnight: Bool
}
