//*********************************************************
// URL+Validate.swift
// On The Map
//
// Created by Matthew Mueller on 5/3/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import Foundation

extension URL {
	static func validatedURL(urlString: String) -> URL? {
		if validate(urlString: urlString) {
			return nil
		}

		return URL(string: urlString)
	}
	
	static func validate(urlString: String) -> Bool {
		let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
		if let match = detector.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: (urlString as NSString).length)) {
			return (urlString as NSString).length == match.range.length
		} else {
			return false
		}
	}
}
