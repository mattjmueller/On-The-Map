//*********************************************************
// UdacityService.swift
// On The Map
//
// Created by Matthew Mueller on 4/27/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import Foundation

enum UdacityServiceError: Error {
	case invalidLogin(message: String)
	case failedLogin(message: String)
	case failedLogout
}

protocol UdacityService: class {
	func login(username: String, password: String, completionHandler: @escaping (Result<UdacityStudent>) -> Void)
	func logout()
}

class RestUdacityService: UdacityService, RestClient {
	var defaultConfig = RestClientConfig(
		urlScheme: .HTTPS,
		host: "www.udacity.com",
		apiBase: "/api",
		defaultheaders: []
	)
	
	func extractResponseDict(data: Data, completionHandler: @escaping (Result<[String : Any]>) -> Void) {
		let range = Range(5..<data.count)
		let newData = data.subdata(in: range)
		
		guard let jsonObject = try? JSONSerialization.jsonObject(with: newData, options: .allowFragments) else {
			return completionHandler(.Failure(RestError.invalidJSONObject))
		}
		
		guard let jsonDict = jsonObject as? [String:Any] else {
			return completionHandler(.Failure(RestError.invalidJSONDict))
		}
		
		completionHandler(.Success(jsonDict))
	}
	
	private func getStudent(userId: String, completionHandler: @escaping (Result<UdacityStudent>) -> Void) {
		let request: RestRequest<UdacityStudent> = RestRequest(
			methodType: .GET,
			method: "/users/\(userId)",
			parameters: [],
			jsonData: nil,
			headers: [],
			modelFromResponseDict: { responseDict in
				if let errorString = responseDict["error"] as? String {
					return .Failure(UdacityServiceError.failedLogin(message: errorString))
				}
				
				guard let modelDict = responseDict["user"] as? [String:Any],
						let model = UdacityStudent(jsonDict: modelDict) else {
					return .Failure(RestError.invalidModelDict)
				}

				return .Success(model)
			}
		)
		
		perform(request: request, completionHandler: completionHandler)
	}
	
	func login(username: String, password: String, completionHandler: @escaping (Result<UdacityStudent>) -> Void) {
		let request: RestRequest<String> = RestRequest(
			methodType: .POST,
			method: "/session",
			parameters: [],
			jsonData: ["udacity": ["username": username,
			                       "password": password]],
			headers: [["Accept" : "application/json"],
			          ["Content-Type" : "application/json"]],
			modelFromResponseDict: { responseDict in
				if let errorString = responseDict["error"] as? String {
					return .Failure(UdacityServiceError.failedLogin(message: errorString))
				}

				guard let accountDict = responseDict["account"] as? [String:Any],
					let userKey = accountDict["key"] as? String else {
					return .Failure(UdacityServiceError.failedLogin(message: "no user info found in response"))
				}
				
				return .Success(userKey)
			}
		)
		
		let compose = perform • getStudent
		compose(request) { result in
			switch result {
			case .Success(let user):
				completionHandler(.Success(user))
			case .Failure(let error):
				/* There seems to be a cookie created regardless of if
				login succeeds. Make sure not to leave this behind if
				login fails. */
				
				self.logout()
				completionHandler(.Failure(error))
			}
		}
	}
	
	func logout() {
		guard let xsrfCookie = getXsrfCookie() else {
			return
		}
		
		let request: RestRequest<Void> = RestRequest(
			methodType: .DELETE,
			method: "/session",
			parameters: [],
			jsonData: nil,
			headers: [["X-XSRF-TOKEN" : xsrfCookie.value]],
			modelFromResponseDict: { responseDict in
				guard let _ = responseDict["session"] as? [String:Any] else {
					return .Failure(UdacityServiceError.failedLogout)
				}

				return .Success()
			}
		)
		
		perform(request: request, completionHandler: {_ in})
	}
	
	private func getXsrfCookie() -> HTTPCookie? {
		var xsrfCookie: HTTPCookie? = nil
		let sharedCookieStorage = HTTPCookieStorage.shared
		for cookie in sharedCookieStorage.cookies! {
			if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
		}
		return xsrfCookie
	}
}
