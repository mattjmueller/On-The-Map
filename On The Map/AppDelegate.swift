//*********************************************************
// AppDelegate.swift
// On The Map
//
// Created by Matthew Mueller on 4/19/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		if let rootViewController = window?.rootViewController {
			rootViewController.storyboard?.configure(rootViewController)
		}
		return true
	}
}

