//
//  ResultsViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

protocol ResultsViewControllerDelegate: AnyObject {
	func showFilters(via barButtonItem: UIBarButtonItem)
	func fetchResults()
	func getImageLoader() -> ImageLoader
	func showDetail(for musicResult: MusicResult)
}

class ResultsViewController: UITableViewController, LoadingIndicatorDisplaying {

	// MARK: - Properties
	weak var controller: ResultsViewControllerDelegate?
	var musicResults: [MusicResult] = [] {
		didSet {
			updateResults()
		}
	}

	// MARK: - Subviews
	var loadingIndicatorContainerView: UIView?

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

	private func updateResults() {
		tableView.reloadData()
	}

	// MARK: - User Interactions
	@objc func showFilterTapped(_ sender: UIBarButtonItem) {
		controller?.showFilters(via: sender)
	}

	@objc func pullToRefresh(_ sender: UIRefreshControl) {
		controller?.fetchResults()
	}
}

// MARK: - TableView Data stuff
extension ResultsViewController {

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		// image height set to 76 + 8 padding top and bottom
		76 + 16
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		musicResults.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: .resultCellIdentifier, for: indexPath)
		guard let resultCell = cell as? ResultTableViewCell else { return cell }
		resultCell.imageLoader = controller?.getImageLoader()
		resultCell.musicResult = musicResults[indexPath.row]

		return resultCell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let musicResult = musicResults[indexPath.row]

		controller?.showDetail(for: musicResult)
	}
}

fileprivate extension String {
	static let resultCellIdentifier = "ResultCell"
}
