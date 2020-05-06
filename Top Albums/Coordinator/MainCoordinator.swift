//
//  MainCoordinator.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
	var childCoordinators: [Coordinator] = []
	let navigationController: UINavigationController

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func start() {
		let vc = ResultsViewController(mainCoordinator: self)
		navigationController.pushViewController(vc, animated: false)
	}

	func showFilters() {
		print("show filters invoked")
	}
}
