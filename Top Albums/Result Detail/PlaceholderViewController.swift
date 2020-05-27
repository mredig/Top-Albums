//
//  PlaceholderViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/27/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class PlaceholderViewController: UIViewController {

	private static let placeholderText = "Select a result"

	override func viewDidLoad() {
		super.viewDidLoad()

		let placeholderLabel = UILabel()
		placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
		placeholderLabel.text = Self.placeholderText
		placeholderLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
		placeholderLabel.textColor = .secondaryLabel
		view.addSubview(placeholderLabel)

		NSLayoutConstraint.activate([
			placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			view.trailingAnchor.constraint(equalTo: placeholderLabel.trailingAnchor, constant: 20),
		])
	}
}
