//*********************************************************
// Storyboard+State.swift
// On The Map
//
// Created by Matthew Mueller on 5/2/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit
import CoreLocation

// This technique for targeted dependency injection was
// developed by Matteo Manferdini and is part of his
// course at http://iosfoundations.com.

fileprivate class State {
	let udacityService = RestUdacityService()
	let studentLocationService = RestStudentLocationService()
	let geolocationService = CLGeocoder()
}

protocol ManagesLogin: class {
	weak var udacityService: UdacityService! { get set }
}

protocol AccessesStudentLocations: class {
	weak var studentLocationService: StudentLocationService! { get set }
}

protocol UsesGeolocation: class {
	weak var geolocationService: GeolocationService! { get set }
}

fileprivate let globalState = State()

extension UIStoryboard {
	private var state: State {
		return globalState
	}

	func configure(_ viewController: UIViewController) {
		if let navigationController = viewController as? UINavigationController {
			navigationController.viewControllers.first.map(configure)
		}
		
		if let tabBarController = viewController as? UITabBarController {
			tabBarController.viewControllers?.first.map(configure)
			tabBarController.delegate = self
		}
		
		if let loginViewController = viewController as? ManagesLogin {
			loginViewController.udacityService = state.udacityService
		}
		
		if let locationsViewController = viewController as? AccessesStudentLocations {
			locationsViewController.studentLocationService = state.studentLocationService
		}
		
		if let geolocatingViewController = viewController as? UsesGeolocation {
			geolocatingViewController.geolocationService = state.geolocationService
		}
	}
}

extension UIStoryboard: UITabBarControllerDelegate {
	public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		configure(viewController)
		return true
	}
}

class InjectingSegue: UIStoryboardSegue {
	override func perform() {
		destination.storyboard?.configure(destination)
		super.perform()
	}
}






