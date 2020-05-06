//
//  AppDelegate.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

		let root = UINavigationController()

		root.viewControllers = [ResultsViewController()]
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = root
		window?.makeKeyAndVisible()

		return true
	}

}

