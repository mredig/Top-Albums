//
//  ResultsViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

protocol ResultsViewControllerCoordinator: AnyObject {
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
	private var imageLoadingOperations: [URL: ImageLoadOperation] = [:]

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

		navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(showFilterTapped(_:)))

		let titleView = TitleView()
		titleView.text = "Music Results"
		navigationItem.titleView = titleView
	}

	private func registerCell() {
		tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: .resultCellIdentifier)
	}

	private func resetHeightCache() {
		heightCache.removeAll()
	}

	private func updateResults() {
		resetHeightCache()
		tableView.reloadData()
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
		configureResultCell(prototypeCell, withMusicResult: musicResults[indexPath.row])
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
		configureResultCell(resultCell, withMusicResult: musicResults[indexPath.row])

		return resultCell
	}

	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let musicResult = musicResults[indexPath.row]
		imageLoadingOperations[musicResult.artworkUrl100]?.cancel()
	}

	private func configureResultCell(_ cell: ResultTableViewCell, withMusicResult musicResult: MusicResult) {
		cell.artistName = musicResult.artistName
		cell.albumName = musicResult.name

		guard cell !== prototypeResultCell else { return }
		let imageLoadOp = coordinator?.getImageLoader().fetchImage(for: musicResult, attemptHighRes: false, completion: { [weak self] result in
			DispatchQueue.main.async {
				self?.imageLoadingOperations[musicResult.artworkUrl100] = nil
				do {
					let imageData = try result.get()
					let image = UIImage(data: imageData)
					cell.albumArt = image
				} catch {
					print("Error fetching image for \(musicResult.name)-\(musicResult.artistName ?? ""): \(error)")
				}
			}
		})
		imageLoadingOperations[musicResult.artworkUrl100]?.cancel()
		imageLoadingOperations[musicResult.artworkUrl100] = imageLoadOp
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let musicResult = musicResults[indexPath.row]

		coordinator?.showDetail(for: musicResult)
	}
}

fileprivate extension String {
	static let resultCellIdentifier = "ResultCell"
}
