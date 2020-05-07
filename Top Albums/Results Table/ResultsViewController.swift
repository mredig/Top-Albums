//
//  ResultsViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class ResultsViewController: UITableViewController {

	weak var mainCoordinator: MainCoordinator?

	var musicResults: [MusicResult] = [] {
		didSet {
			updateResults()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		registerCell()
		navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(showFilterTapped(_:)))
	}

	private func registerCell() {
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: .resultCellIdentifier)
	}

	private func updateResults() {
		tableView.reloadData()
	}

	@objc func showFilterTapped(_ sender: Any) {
		mainCoordinator?.showFilters()
	}
}

// MARK: - TableView Data stuff
extension ResultsViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		musicResults.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: .resultCellIdentifier, for: indexPath)

		cell.textLabel?.text = musicResults[indexPath.row].artistName
		return cell
	}
}

fileprivate extension String {
	static let resultCellIdentifier = "ResultCell"
}
