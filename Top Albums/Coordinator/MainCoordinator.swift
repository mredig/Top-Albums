//
//  MainCoordinator.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit
import NetworkHandler

class MainCoordinator: NSObject, CoordinatorBase {
	// MARK: - Properties
	private static let feedBaseURLString = "https://rss.itunes.apple.com/api/v1/us/"

	var childCoordinators: [CoordinatorBase] = []

	let masterNavController: UINavigationController
	let detailNavControllerGenerator: () -> UINavigationController
	var detailNavController: UINavigationController
	let splitViewController: UISplitViewController

	var splitShouldCollapse = true

	let resultsViewController: ResultsViewController

	private let iTunesApi: iTunesAPIController = {
		let session: NetworkLoader
		if let mockBlockPlist = UIPasteboard.general.data(forPasteboardType: MockBlock.pasteboardTypeString) {
			UIPasteboard.general.setData(Data(), forPasteboardType: MockBlock.pasteboardTypeString)
			// Avoid arbitrary load vulnerability in production app
			#if DEBUG
			do {
				let mockBlock = try PropertyListDecoder().decode(MockBlock.self, from: mockBlockPlist)
				let mockingSession = NetworkMockingSession { request -> (Data?, Int, Error?) in
					guard let resource = mockBlock.resource(for: request) else { return (nil, 404, nil) }
					return (resource.data, resource.responseCode, nil)
				}

				session = mockingSession
			} catch {
				print("Error loading mockblock: \(error)")
				session = URLSession.shared
			}
			#else
			session = URLSession.shared
			#endif
		} else {
			session = URLSession.shared
		}
		return iTunesAPIController(baseURLString: MainCoordinator.feedBaseURLString, session: session)
	}()


	// MARK: - Lifecycle
	init(masterNavController: UINavigationController = LargeTitleNavigationController(),
		 detailNavControllerGenerator: @escaping () -> UINavigationController = { LargeTitleNavigationController() },
		 splitViewController: UISplitViewController = UISplitViewController()) {
		self.masterNavController = masterNavController
		self.detailNavControllerGenerator = detailNavControllerGenerator
		self.detailNavController = detailNavControllerGenerator()
		self.splitViewController = splitViewController

		resultsViewController = ResultsViewController()
		super.init()
		resultsViewController.coordinator = self

		splitViewController.delegate = self
	}

	func start() {
		setupMasterVC()
		setupDetailVC(with: nil)

		splitViewController.viewControllers = [masterNavController, detailNavController]

		fetchResults()
	}

	private func setupMasterVC() {
		masterNavController.pushViewController(resultsViewController, animated: false)
	}

	private func setupDetailVC(with musicResult: MusicResult?) {
		let detailNavController = detailNavControllerGenerator()
		let newDetailVC: UIViewController
		if let result = musicResult {
			// show result
			let musicResultVM = MusicResultViewModel(musicResult: result)
			let resultVC = ResultDetailViewController(musicResultVM: musicResultVM, coordinator: self)
			newDetailVC = resultVC
		} else {
			//show dummy placeholder
			newDetailVC = PlaceholderViewController()
		}
		detailNavController.pushViewController(newDetailVC, animated: false)
		splitViewController.showDetailViewController(detailNavController, sender: nil)
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

		masterNavController.present(filterVC, animated: true)
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
		setupDetailVC(with: musicResult)
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
		UIDevice.current.orientation == UIDeviceOrientation.portrait ? .none : .popover
	}

	func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
		true
	}
}

extension MainCoordinator: UISplitViewControllerDelegate {
	func splitViewController(_ splitViewController: UISplitViewController,
							 collapseSecondary secondaryViewController: UIViewController,
							 onto primaryViewController: UIViewController) -> Bool {
		splitShouldCollapse
	}

	func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode {
		svc.displayMode == .allVisible ? .primaryHidden : .allVisible
	}
}
