//*********************************************************
// StudentLocationService.swift
// On The Map
//
// Created by Matthew Mueller on 4/24/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import Foundation

enum StudentLocationServiceError: Error {
	case noUserSet
	case failedLocationUpdate
}

protocol StudentLocationService: class {
	var currentUser: UdacityStudent? { get set }
	var userHasLocation: Bool { get }
	func getStudentLocation(withUniqueKey uniqueKey: String, completionHandler: @escaping (Result<StudentLocation>) -> Void)
	func getStudentLocations(page: Int, perPage: Int, completionHandler: @escaping (Result<[StudentLocation]>) -> Void)
	func setMyLocation(_ location: Location, sharingURL urlString: String, completionHandler: @escaping (Result<Void>) -> Void)
}

class RestStudentLocationService: StudentLocationService, RestClient {
	var userHasLocation = false
	var currentUser: UdacityStudent? {
		didSet {
			guard let currentUser = currentUser else {
				userHasLocation = false
				return
			}
			
			getStudentLocation(withUniqueKey: currentUser.key) { result in
				switch result {
				case .Success:
					self.userHasLocation = true
				case .Failure:
					self.userHasLocation = false
				}
			}
		}
	}
	
	var defaultConfig = RestClientConfig(
		urlScheme: .HTTPS,
		host: "parse.udacity.com",
		apiBase: "/parse/classes",
		defaultheaders: [["X-Parse-Application-Id" : "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"],
		                 ["X-Parse-REST-API-Key" : "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"]]
	)
	
	func extractResponseDict(data: Data, completionHandler: @escaping (Result<[String : Any]>) -> Void) {
		guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
			return completionHandler(.Failure(RestError.invalidJSONObject))
		}
		
		guard let jsonDict = jsonObject as? [String:Any] else {
			return completionHandler(.Failure(RestError.invalidJSONDict))
		}
		
		completionHandler(.Success(jsonDict))
	}
	
	func getStudentLocations(page: Int, perPage: Int, completionHandler: @escaping (Result<[StudentLocation]>) -> Void) {
		let request: RestRequest<[StudentLocation]> = RestRequest(
			methodType: .GET,
			method: "/StudentLocation",
			parameters: [["limit" : perPage],
			             ["skip" : page],
			             ["order" : "-updatedAt"]],
			jsonData: nil,
			headers: [],
			modelFromResponseDict: { responseDict in
				guard let modelArray = self.parseStudentLocations(from: responseDict) else {
					return Result.Failure(RestError.invalidModelDict)
				}

				return Result.Success(modelArray)
			}
		)
		
		perform(request: request, completionHandler: completionHandler)
	}
	
	func setMyLocation(_ location: Location, sharingURL urlString: String, completionHandler: @escaping (Result<Void>) -> Void) {
		guard let currentUser = currentUser else {
			return completionHandler(.Failure(StudentLocationServiceError.noUserSet))
		}
		
		let request: RestRequest<Void> = RestRequest(
			methodType: userHasLocation ? .PUT : .POST,
			method: "/StudentLocation",
			parameters: [["Content-Type" : "application/json"]],
			jsonData: [
				"uniqueKey" : currentUser.key,
				"firstName" : currentUser.firstName,
				"lastName" : currentUser.lastName,
				"mapString" : location.name,
				"latitude" : location.latitude,
				"longitude" : location.longitude,
				"mediaURL" : urlString],
			headers: [],
			modelFromResponseDict: { responseDict in
				print("\nJson Response Dict\n \(responseDict)")
				
				guard responseDict["error"] == nil else {
					return .Failure(StudentLocationServiceError.failedLocationUpdate)
				}
				
				return .Success()
			}
		)
		
		perform(request: request, completionHandler: completionHandler)
	}
	
	func getStudentLocation(withUniqueKey uniqueKey: String, completionHandler: @escaping (Result<StudentLocation>) -> Void) {
		let request: RestRequest<StudentLocation> = RestRequest(
			methodType: .GET,
			method: "/StudentLocation",
			parameters: [["where" : "{\"uniqueKey\":\"\(uniqueKey)\"}"]],
			jsonData: nil,
			headers: [],
			modelFromResponseDict: { responseDict in
				guard let modelArray = self.parseStudentLocations(from: responseDict),
						modelArray.count == 1 else {
					return Result.Failure(RestError.invalidJSONDict)
				}
				
				return Result.Success(modelArray[0])
			}
		)
		
		perform(request: request, completionHandler: completionHandler)
	}
	
	private func parseStudentLocations(from array: [String:Any]) -> [StudentLocation]? {
		guard let StudentLocationArray = array["results"] as? [[String:Any]],
			let result = StudentLocation.locationsFromJson(jsonArray: StudentLocationArray) else {
				return nil
		}
		return result
	}
}


