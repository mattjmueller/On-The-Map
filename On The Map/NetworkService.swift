//*********************************************************
// NetworkService.swift
// On The Map
//
// Created by Matthew Mueller on 4/22/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

enum NetworkError: Error {
	case requestFailed
	case noData
}

struct NetworkService {
	func performRequest(_ request: URLRequest, completionHandler: @escaping (Result<Data>) -> Void) {
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				return completionHandler(.Failure(error!))
			}
			
			/* GUARD: Was there any data returned? */
			guard let data = data else {
				return completionHandler(.Failure(NetworkError.noData))
			}
			
			completionHandler(.Success(data))
		}.resume()
	}
}
