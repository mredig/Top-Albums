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

	init(mainCoordinator: MainCoordinator?) {
		self.mainCoordinator = mainCoordinator
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: #selector(showFilterTapped(_:)))
	}

	@objc func showFilterTapped(_ sender: Any) {
		mainCoordinator?.showFilters()
	}

}

