//
//  ResultsViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit
import NetworkHandler

protocol ResultsViewControllerCoordinator: AnyObject {
	func getTitle() -> String
	func showFilters(via barButtonItem: UIBarButtonItem)
	func fetchResults()
	func getImageLoader() -> ImageLoader
	func showDetail(for musicResult: MusicResult)
}

class ResultsViewController: UITableViewController, LoadingIndicatorDisplaying {

	private let barButtonSystemName = "ellipsis"
	private let topTitleViewString = "Top Results"

	private let cellHeightFallbackValue: CGFloat = 44
	private let cellEstimatedHeight: CGFloat = 100

	private static let accessibilityIDBarButton = "ResultsViewController.MoreOptionsButton"

	// MARK: - Properties
	weak var coordinator: ResultsViewControllerCoordinator?
	var musicResults: [MusicResult] = [] {
		didSet {
			updateResults()
		}
	}
	private var imageLoadingOperations: [URL: NetworkLoadingTask] = [:]

	// MARK: - Subviews
	var loadingIndicatorContainerView: UIView?
	private lazy var prototypeResultCell = {
		tableView.dequeueReusableCell(withIdentifier: .resultCellIdentifier) as? ResultTableViewCell
	}()
	private var heightCache = [IndexPath: CGFloat]()

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		registerCell()

		let barItem = UIBarButtonItem(image: UIImage(systemName: barButtonSystemName), style: .done, target: self, action: #selector(showFilterTapped(_:)))
		barItem.accessibilityIdentifier = Self.accessibilityIDBarButton
		navigationItem.rightBarButtonItem = barItem

		let titleView = TitleView()
		titleView.text = topTitleViewString
		navigationItem.titleView = titleView
		updateTitle()

		view.backgroundColor = .secondarySystemBackground
		// Hides table view rows when empty
		tableView.tableFooterView = UIView()
	}

	private func registerCell() {
		tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: .resultCellIdentifier)
	}

	private func resetCaches() {
		heightCache.removeAll()
		imageLoadingOperations.forEach { $0.value.cancel() }
		imageLoadingOperations.removeAll()
	}

	private func updateTitle() {
		navigationItem.title = coordinator?.getTitle()
	}

	private func updateResults() {
		resetCaches()
		tableView.reloadData()
		updateTitle()
	}

	// MARK: - User Interactions
	@objc func showFilterTapped(_ sender: UIBarButtonItem) {
		coordinator?.showFilters(via: sender)
	}
}

// MARK: - TableView Data stuff
extension ResultsViewController {

	/// Used for both row height and actually assigning cell content
	private func configureResultCell(_ cell: ResultTableViewCell, withMusicResult musicResultVM: MusicResultViewModel) {
		cell.artistName = musicResultVM.artistName
		cell.albumName = musicResultVM.name

		// don't start a network operation for the prototype cell
		guard cell !== prototypeResultCell else { return }
		let imageLoadOp = coordinator?.getImageLoader().fetchImage(for: musicResultVM, attemptHighRes: false, completion: { [weak self] result in
			DispatchQueue.main.async {
				self?.imageLoadingOperations[musicResultVM.normalArtworkURL] = nil
				do {
					let imageData = try result.get()
					let image = UIImage(data: imageData)
					cell.albumArt = image
				} catch {
					print("Error fetching image for \(musicResultVM.name)-\(musicResultVM.artistName ?? ""): \(error)")
				}
			}
		})
		imageLoadingOperations[musicResultVM.normalArtworkURL]?.cancel()
		imageLoadingOperations[musicResultVM.normalArtworkURL] = imageLoadOp
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		// use a cached prototype cell to determine the exact height of a given cell. Cache that value for future lookups.
		if let height = heightCache[indexPath] {
			return height
		}
		guard let prototypeCell = prototypeResultCell else { return cellHeightFallbackValue }
		prototypeCell.prepareForReuse()
		let musicResultVM = MusicResultViewModel(musicResult: musicResults[indexPath.row])
		configureResultCell(prototypeCell, withMusicResult: musicResultVM)
		let size = prototypeCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		heightCache[indexPath] = size.height;
		return size.height
	}

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		cellEstimatedHeight
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		musicResults.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: .resultCellIdentifier, for: indexPath)
		guard let resultCell = cell as? ResultTableViewCell else { return cell }
		let musicResultVM = MusicResultViewModel(musicResult: musicResults[indexPath.row])
		configureResultCell(resultCell, withMusicResult: musicResultVM)

		return resultCell
	}

	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// cancel in progress network operations if the cell scrolls offscreen before finishing
		guard indexPath.row < musicResults.count else { return }
		let musicResultVM = MusicResultViewModel(musicResult: musicResults[indexPath.row])

		imageLoadingOperations[musicResultVM.normalArtworkURL]?.cancel()
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let musicResult = musicResults[indexPath.row]

		coordinator?.showDetail(for: musicResult)
	}
}

fileprivate extension String {
	static let resultCellIdentifier = "ResultCell"
}
