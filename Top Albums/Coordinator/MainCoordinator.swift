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

	private let iTunesApi = iTunesAPIController()

	// MARK: - Lifecycle
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
		resultsViewController = ResultsViewController()
		super.init()
		resultsViewController.coordinator = self
		navigationController.delegate = self
	}

	convenience override init() {
		self.init(navigationController: UINavigationController())
	}

	func start() {
		navigationController.pushViewController(resultsViewController, animated: false)
		fetchResults()
	}
}

// MARK: - Interface
extension MainCoordinator: ResultsViewControllerCoordinator {
	func getTitle() -> String {
		let mediaTypeVM = MediaTypeViewModel(mediaType: iTunesApi.mediaSearch)
		return mediaTypeVM.fullString
	}

	func showFilters(via barButtonItem: UIBarButtonItem) {
		let filterVC = FiltersViewController(controller: self)
		filterVC.modalPresentationStyle = .popover
		filterVC.popoverPresentationController?.barButtonItem = barButtonItem
		filterVC.popoverPresentationController?.delegate = self

		navigationController.present(filterVC, animated: true)
	}

	func fetchResults() {
		resultsViewController.showLoadingIndicator()
		iTunesApi.fetchResults { result in
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
		let resultVC = ResultDetailViewController(musicResult: musicResult, coordinator: self)
		resultDetailViewController = resultVC
		navigationController.pushViewController(resultVC, animated: true)
		navigationController.hidesBarsOnTap = true
	}

	func getImageLoader() -> ImageLoader {
		iTunesApi
	}
}

extension MainCoordinator: FiltersViewControllerDelegate {
	var searchOptions: MediaType {
		get { iTunesApi.mediaSearch }
		set { iTunesApi.mediaSearch = newValue }
	}
	var allowExplicitResults: Bool {
		get { iTunesApi.allowExplicitResults }
		set { iTunesApi.allowExplicitResults = newValue }
	}

	func didFinishSelectingSearchFilters(on filtersViewController: FiltersViewController, searchFilter: MediaType, showExplicit: Bool) {
		guard iTunesApi.mediaSearch != searchFilter || iTunesApi.allowExplicitResults != showExplicit else { return }
		iTunesApi.mediaSearch = searchFilter
		iTunesApi.allowExplicitResults = showExplicit
		fetchResults()
	}
}

extension MainCoordinator: ResultDetailViewControllerDelegate {}

extension MainCoordinator: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		guard let fromController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
		if fromController == resultDetailViewController {
			navigationController.hidesBarsOnTap = false
		}
	}
}

extension MainCoordinator: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		.none
	}

	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		true
	}
}
