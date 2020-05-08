//
//  ResultDetailViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/7/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class ResultDetailViewController: UIViewController {

	let musicResult: MusicResult
	let mainCoordinator: MainCoordinator

	init(musicResult: MusicResult, mainCoordinator: MainCoordinator) {
		self.musicResult = musicResult
		self.mainCoordinator = mainCoordinator
		super.init(nibName: nil, bundle: nil)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		fatalError("init(nibName:bundle:) has not been implemented")
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("Deinited result detailvc")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		view.backgroundColor = .white
    }


}
