//
//  SongPreviewView.swift
//  Top Albums
//
//  Created by Michael Redig on 5/12/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class SongPreviewView: UIView {

	var title: String? {
		get { titleLabel.text }
		set { titleLabel.text = newValue }
	}

	var artist: String? {
		get { artistLabel.text }
		set { artistLabel.text = newValue }
	}

	var progress: Float {
		get { progressView.progress }
		set { progressView.progress = newValue }
	}

	var backingColor: UIColor? {
		get { coloredBackground.backgroundColor }
		set { coloredBackground.backgroundColor = newValue } 
	}

	private let titleLabel = UILabel()
	private let artistLabel = UILabel()
	private let progressView = UIProgressView()
	private let coloredBackground = UIView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	private func commonInit() {
		configureLayout()
		configureViews()
	}

	private func configureLayout() {
		// tie break hugging and compression
		artistLabel.setContentHuggingPriority(.init(252), for: .vertical)
		artistLabel.setContentCompressionResistancePriority(.init(751), for: .vertical)
		titleLabel.setContentCompressionResistancePriority(.init(751), for: .vertical)
		let titleStack = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
		titleStack.axis = .vertical
		titleStack.alignment = .fill
		titleStack.distribution = .fill
		titleStack.spacing = 0
		titleStack.translatesAutoresizingMaskIntoConstraints = false
		titleStack.clipsToBounds = false

		coloredBackground.backgroundColor = .secondarySystemBackground
		coloredBackground.addSubview(titleStack)
		coloredBackground.translatesAutoresizingMaskIntoConstraints = false

		progressView.translatesAutoresizingMaskIntoConstraints = false
		coloredBackground.addSubview(progressView)
		translatesAutoresizingMaskIntoConstraints = false

		addSubview(coloredBackground)
		NSLayoutConstraint.activate([
			titleStack.topAnchor.constraint(equalTo: coloredBackground.topAnchor, constant: 8),
			titleStack.bottomAnchor.constraint(equalTo: coloredBackground.bottomAnchor, constant: -8),
			titleStack.leadingAnchor.constraint(equalTo: coloredBackground.leadingAnchor, constant: 8),
			titleStack.trailingAnchor.constraint(equalTo: coloredBackground.trailingAnchor, constant: -8),

			coloredBackground.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			coloredBackground.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
			coloredBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
			coloredBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

			progressView.leadingAnchor.constraint(equalTo: coloredBackground.leadingAnchor),
			progressView.trailingAnchor.constraint(equalTo: coloredBackground.trailingAnchor),
			progressView.bottomAnchor.constraint(equalTo: coloredBackground.bottomAnchor),
		])
	}

	private func configureViews() {
		progressView.progress = 0
		progressView.progressViewStyle = .bar
		progressView.accessibilityIdentifier = "SongProgressView"
		coloredBackground.layer.cornerRadius = 10
		coloredBackground.layer.cornerCurve = .continuous
		coloredBackground.clipsToBounds = true

		titleLabel.font = UIFont.systemFont(ofSize: 17)
		titleLabel.textColor = .label
		artistLabel.font = UIFont.systemFont(ofSize: 12)
		artistLabel.textColor = .secondaryLabel
		artistLabel.clipsToBounds = false

	}

}
