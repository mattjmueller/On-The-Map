//*********************************************************
// UdacityStudent.swift
// On The Map
//
// Created by Matthew Mueller on 4/27/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import Foundation

struct UdacityStudent {
	let key: String
	let firstName: String
	let lastName: String
}

extension UdacityStudent {
	init?(jsonDict: [String: Any]) {
		guard let key = jsonDict["key"] as? String else { print("No key"); return nil }
		guard let firstName = jsonDict["first_name"] as? String else { print("No firstName"); return nil }
		guard let lastName = jsonDict["last_name"] as? String else { print("No lastName"); return nil }
		
		self.key = key
		self.firstName = firstName
		self.lastName = lastName
	}
}
