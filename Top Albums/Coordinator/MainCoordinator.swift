//
//  MainCoordinator.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class MainCoordinator: NSObject, Coordinator {
	// MARK: - Properties
	var childCoordinators: [Coordinator] = []
	let navigationController: UINavigationController

	let resultsViewController: ResultsViewController
	weak var resultDetailViewController: ResultDetailViewController?

	let itunesApi = iTunesAPIController()

	var isResultsLoadInProgress: Bool {
		itunesApi.isResultsLoadInProgress
	}

	// MARK: - Lifecycle
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
		resultsViewController = ResultsViewController()
		super.init()
		resultsViewController.mainCoordinator = self
		navigationController.delegate = self

		stylizeNavController()
	}

	convenience override init() {
		self.init(navigationController: UINavigationController())
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

	func showDetail(for musicResult: MusicResult) {
		guard resultDetailViewController == nil else { return }
		let resultVC = ResultDetailViewController(musicResult: musicResult, mainCoordinator: self)
		resultDetailViewController = resultVC
		navigationController.pushViewController(resultVC, animated: true)
		navigationController.hidesBarsOnTap = true
	}

	func getImageLoader() -> ImageLoader {
		itunesApi
	}
}

extension MainCoordinator: UINavigationControllerDelegate {

	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		guard let fromController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
		if fromController == resultDetailViewController {
			navigationController.hidesBarsOnTap = false
		}
	}

	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {

	}
}
