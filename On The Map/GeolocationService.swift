//*********************************************************
// GeolocationService.swift
// On The Map
//
// Created by Matthew Mueller on 5/3/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import Foundation
import CoreLocation

protocol GeolocationService: class {
	func locationForString(_ placeName: String, completionHandler: @escaping (Result<Location>) -> Void)
}

enum GeolocationServiceError: Error {
	case noResultReturned
	case ambiguousResult
	case noCoordiantes
}

extension CLGeocoder: GeolocationService {
	func locationForString(_ placeName: String, completionHandler: @escaping (Result<Location>) -> Void) {
		geocodeAddressString(placeName) { placemarks, error in
			guard error == nil else {
				let nsError = error! as NSError
				if nsError.domain == "kCLErrorDomain" && nsError.code == 8 {
					return completionHandler(.Failure(GeolocationServiceError.noResultReturned))
				} else {
					return completionHandler(.Failure(error!))
				}
			}
			
			guard let placemarks = placemarks, placemarks.count > 0 else {
				return completionHandler(.Failure(GeolocationServiceError.noResultReturned))
			}
			
			guard placemarks.count == 1 else {
				return completionHandler(.Failure(GeolocationServiceError.ambiguousResult))
			}
			
			let placemark = placemarks[0]
			guard let coordinate = placemark.location?.coordinate else {
				return completionHandler(.Failure(GeolocationServiceError.noCoordiantes))
			}
			
			let locationResult = Location(
				name: placemark.name ?? placeName,
				latitude: coordinate.latitude,
				longitude: coordinate.longitude)
			
			completionHandler(.Success(locationResult))
		}
	}
}
