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

		let barItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(showFilterTapped(_:)))
		barItem.accessibilityIdentifier = "ResultsViewController.MoreOptionsButton"
		navigationItem.rightBarButtonItem = barItem

		let titleView = TitleView()
		titleView.text = "Top Results"
		navigationItem.titleView = titleView
		updateTitle()
	}

	private func registerCell() {
		tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: .resultCellIdentifier)
	}

	private func resetHeightCache() {
		heightCache.removeAll()
	}

	private func updateTitle() {
		navigationItem.title = coordinator?.getTitle()
	}

	private func updateResults() {
		resetHeightCache()
		tableView.reloadData()
		updateTitle()
	}

	// MARK: - User Interactions
	@objc func showFilterTapped(_ sender: UIBarButtonItem) {
		coordinator?.showFilters(via: sender)
	}

	@objc func pullToRefresh(_ sender: UIRefreshControl) {
		coordinator?.fetchResults()
	}
}

// MARK: - TableView Data stuff
extension ResultsViewController {

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if let height = heightCache[indexPath] {
			return height
		}
		guard let prototypeCell = prototypeResultCell else { return 44 }
		prototypeCell.prepareForReuse()
		let musicResultVM = MusicResultViewModel(musicResult: musicResults[indexPath.row])
		configureResultCell(prototypeCell, withMusicResult: musicResultVM)
		let size = prototypeCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		heightCache[indexPath] = size.height;
		return size.height
	}

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		100
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
		let musicResultVM = MusicResultViewModel(musicResult: musicResults[indexPath.row])

		imageLoadingOperations[musicResultVM.normalArtworkURL]?.cancel()
	}

	private func configureResultCell(_ cell: ResultTableViewCell, withMusicResult musicResultVM: MusicResultViewModel) {
		cell.artistName = musicResultVM.artistName
		cell.albumName = musicResultVM.name

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

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let musicResult = musicResults[indexPath.row]

		coordinator?.showDetail(for: musicResult)
	}
}

fileprivate extension String {
	static let resultCellIdentifier = "ResultCell"
}
