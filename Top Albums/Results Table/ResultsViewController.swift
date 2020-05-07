//
//  ResultsViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class ResultsViewController: UITableViewController {

	// MARK: - Properties
	weak var mainCoordinator: MainCoordinator?

	lazy var refreshControlIndicator: UIRefreshControl = {
		let refreshCtrl = UIRefreshControl()
		refreshCtrl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
		refreshCtrl.attributedTitle = NSAttributedString(string: " ")
		return refreshCtrl
	}()

	var musicResults: [MusicResult] = [] {
		didSet {
			updateResults()
		}
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		registerCell()

		navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(showFilterTapped(_:)))

		let titleView = TitleView()
		titleView.text = "Music Results"
		navigationItem.titleView = titleView

		refreshControl = refreshControlIndicator
		if mainCoordinator?.isResultsLoadInProgress == true {
			refreshControl?.beginRefreshing()
		}
	}

	private func registerCell() {
		tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: .resultCellIdentifier)
	}

	private func updateResults() {
		refreshControl?.endRefreshing()
		tableView.reloadData()
	}

	// MARK: - User Interactions
	@objc func showFilterTapped(_ sender: Any) {
		mainCoordinator?.showFilters()
	}

	@objc func pullToRefresh(_ sender: UIRefreshControl) {
		mainCoordinator?.fetchResults()
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
		resultCell.imageLoader = mainCoordinator?.getImageLoader()
		resultCell.musicResult = musicResults[indexPath.row]

		return resultCell
	}
}

fileprivate extension String {
	static let resultCellIdentifier = "ResultCell"
}
