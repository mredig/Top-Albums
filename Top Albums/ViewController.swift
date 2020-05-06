//
//  ViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		view.backgroundColor = .systemRed

		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(label)

		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])


		label.text = "test"
	}


}

