//
//  MainCoordinator.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit
import NetworkHandler

class MainCoordinator: NSObject, Coordinator {
	// MARK: - Properties
	var childCoordinators: [Coordinator] = []
	let navigationController: UINavigationController

	let resultsViewController: ResultsViewController
	weak var resultDetailViewController: ResultDetailViewController?

	private let iTunesApi: iTunesAPIController = {
		let baseURLString = "https://rss.itunes.apple.com/api/v1/us/"
		let session: NetworkLoader
		if let mockBlockPointer = ProcessInfo.processInfo.decode(MockBlockPointer.self) {
			// Avoid arbitrary load vulnerability in production app
			#if DEBUG
			try? mockBlockPointer.load(cleanup: false)

			let mockingSession = NetworkMockingSession { request -> (Data?, Int, Error?) in
				guard let resource = mockBlockPointer.mockBlock?.resource(for: request) else { return (nil, 404, nil) }
				return (resource.data, resource.responseCode, nil)
			}

			session = mockingSession
			#else
			session = URLSession.shared
			#endif
		} else {
			session = URLSession.shared
		}
		return iTunesAPIController(baseURLString: baseURLString, session: session)
	}()


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
		let musicResultVM = MusicResultViewModel(musicResult: musicResult)
		let resultVC = ResultDetailViewController(musicResultVM: musicResultVM, coordinator: self)
		resultDetailViewController = resultVC
		navigationController.pushViewController(resultVC, animated: true)
	}

	func getImageLoader() -> ImageLoader {
		iTunesApi
	}
}

extension MainCoordinator: FiltersViewControllerCoordinator {
	var searchOptions: MediaType {
		iTunesApi.mediaSearch
	}
	var allowExplicitResults: Bool {
		iTunesApi.allowExplicitResults
	}

	func didFinishSelectingSearchFilters(on filtersViewController: FiltersViewController, searchFilter: MediaType, showExplicit: Bool) {
		guard iTunesApi.mediaSearch != searchFilter || iTunesApi.allowExplicitResults != showExplicit else { return }
		iTunesApi.mediaSearch = searchFilter
		iTunesApi.allowExplicitResults = showExplicit
		fetchResults()
	}
}

extension MainCoordinator: ResultDetailViewControllerCoordinator {
	func createSongPreviewCollectionVC() -> SongPreviewCollectionViewController {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0

		return SongPreviewCollectionViewController(collectionViewLayout: layout, coordinator: self)
	}

	func getSongPreviewLoader() -> SongPreviewLoader {
		iTunesApi
	}
}

extension MainCoordinator: SongPreviewCollectionViewControllerCoordinator {}

extension MainCoordinator: UINavigationControllerDelegate {}

extension MainCoordinator: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		.none
	}

	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		true
	}
}
