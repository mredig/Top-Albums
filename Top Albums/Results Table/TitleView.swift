//
//  TitleView.swift
//  Top Albums
//
//  Created by Michael Redig on 5/7/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class TitleView: UIView {

	private let symbol = UIImage(systemName: "music.note.list")?.withRenderingMode(.alwaysOriginal)

	private let label = UILabel()

	var text: String? {
		get { label.text }
		set { label.text = newValue }
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	private func commonInit() {
		let imageView = UIImageView(image: symbol)
		let stackView = UIStackView(arrangedSubviews: [imageView, label])
		stackView.alignment = .fill
		stackView.distribution = .fill
		stackView.axis = .horizontal

		addSubview(stackView)
		constrain(subview: stackView)
	}
}
