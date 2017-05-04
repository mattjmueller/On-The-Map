//*********************************************************
// StudentLocation.swift
// On The Map
//
// Created by Matthew Mueller on 4/21/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import Foundation

struct StudentLocation {
	let objectId: String
	let uniqueKey: String
	let firstName: String
	let lastName: String
	let location: Location
	let sharedURL: URL?
	
	var fullName: String {
		return firstName + " " + lastName
	}
}

extension StudentLocation {
	
	init?(jsonDict: [String: Any]) {
		guard let objectId = jsonDict["objectId"] as? String else { print("No objectID"); return nil }
		guard let uniqueKey = jsonDict["uniqueKey"] as? String else { print("No uniqueKey"); return nil }
		guard let firstName = jsonDict["firstName"] as? String else { print("No firstName"); return nil }
		guard let lastName = jsonDict["lastName"] as? String else { print("No lastName"); return nil }
		guard let latitude = jsonDict["latitude"] as? Double else { print("No latitude"); return nil }
		guard let longitude = jsonDict["longitude"] as? Double else { print("No longitude"); return nil }
		guard let locationName = jsonDict["mapString"] as? String else { print("No locationName"); return nil }
		let sharedURL = (jsonDict["mediaURL"] as? String).flatMap { URL(string: $0) }
		
		self.objectId = objectId
		self.uniqueKey = uniqueKey
		self.firstName = firstName
		self.lastName = lastName
		self.location = Location(name: locationName, latitude: latitude, longitude: longitude)
		self.sharedURL = sharedURL
	}
	
	static func locationsFromJson(jsonArray: [[String:Any]]) -> [StudentLocation]? {
		return jsonArray.flatMap { StudentLocation(jsonDict: $0) }
	}
}

