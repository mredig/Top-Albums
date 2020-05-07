//
//  MainCoordinator.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
	// MARK: - Properties
	var childCoordinators: [Coordinator] = []
	let navigationController: UINavigationController

	let resultsViewController: ResultsViewController

	let itunesApi = iTunesAPIController()

	var isResultsLoadInProgress: Bool {
		itunesApi.isResultsLoadInProgress
	}

	// MARK: - Lifecycle
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
		resultsViewController = ResultsViewController()
		resultsViewController.mainCoordinator = self

		stylizeNavController()
	}

	private func stylizeNavController() {
		// FIXME: Remove if not used
	}

	func start() {
		navigationController.pushViewController(resultsViewController, animated: false)
		fetchResults()
	}

	// MARK: - Interface
	func showFilters() {
		print("show filters invoked")
	}

	func fetchResults() {
		itunesApi.fetchResults { result in
			switch result {
			case .success(let results):
				DispatchQueue.main.async {
					self.resultsViewController.musicResults = results
				}
			case .failure(let error):
				NSLog("Error fetching results: \(error)")
			}
		}
	}
}
