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

	private let itunesApi = iTunesAPIController()

	var isResultsLoadInProgress: Bool {
		itunesApi.isResultsLoadInProgress
	}

	var searchOptions: MediaType {
		get { itunesApi.mediaSearch }
		set { itunesApi.mediaSearch = newValue }
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
	func showFilters(via barButtonItem: UIBarButtonItem?) {
		let filterVC = FiltersViewController(mainCoordinator: self)
		filterVC.delegate = self
		filterVC.modalPresentationStyle = .popover
		filterVC.popoverPresentationController?.barButtonItem = barButtonItem
		filterVC.popoverPresentationController?.delegate = self

		navigationController.present(filterVC, animated: true)
	}

	func fetchResults() {
		resultsViewController.showLoadingIndicator()
		itunesApi.fetchResults { result in
			switch result {
			case .success(let results):
				DispatchQueue.main.async {
					self.resultsViewController.musicResults = results
				}
			case .failure(let error):
				NSLog("Error fetching results: \(error)")
			}
			self.resultsViewController.dismissLoadingIndicator()
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


extension MainCoordinator: UIPopoverPresentationControllerDelegate, FiltersViewControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		.none
	}

	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		true
	}

	func didFinishSelectingSearchFilters(on filtersViewController: FiltersViewController, searchFilter: MediaType) {
		itunesApi.mediaSearch = searchFilter
		fetchResults()
	}
}
