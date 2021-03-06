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
	let coordinator = MainCoordinator()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

		coordinator.start()
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = coordinator.splitViewController
		window?.makeKeyAndVisible()

		return true
	}

}

